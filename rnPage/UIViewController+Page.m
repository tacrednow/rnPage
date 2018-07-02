//
//  UIViewController+Page.m
//  sxsiosapp
//
//  Created by rednow on 2018/4/26.
//  Copyright © 2018年 mshare. All rights reserved.
//

#import "UIViewController+Page.h"
#import "REDSwizzle.h"
#import "UIViewController+Page_internal.h"
#import "UIGestureRecognizer+Category.h"
#import "UIView+Frame.h"
#import "dynamicItem.h"

#define Nav_Height (([UIScreen mainScreen].bounds.size.height == 812) ? (88) : (64))
#define SCREEN_Width [UIScreen mainScreen].bounds.size.width
#define SCREEN_Height [UIScreen mainScreen].bounds.size.height

static float rn_originY = 0;
static float rn_tabbarH = 0;

@interface RNTitleScrollView()<UIScrollViewDelegate> {
    float titleTopEdge;
    float titleLeftRightEdge;
    float titleLineBottomEdge;
    float titleInset;
}

@property (nonatomic) BOOL bothPan;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;
@property (nonatomic) BOOL hasScreenEdgePan;

@end

@implementation RNTitleScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        titleTopEdge=10;
        titleLeftRightEdge=30;
        _titleLineWidth=20;
        _titleWidthRate=2;
        titleInset = 15;
        self.bothPan = YES;
    }
    return self;
}

- (void)layoutView:(RNPageUIType)type{
    //清除之前的subview
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    self.titleLabelArray=[[NSMutableArray alloc]init];

    self.pageUIType = type;
    self.delegate=self;
    self.showsHorizontalScrollIndicator=NO;
    self.backgroundColor = [UIColor whiteColor];
    
    CGRect frame=CGRectMake(titleInset, 0, 1, 1);
    for (int i=0; i<self.vcArray.count; i++) {
        UILabel *title;
        UIViewController *vc = self.vcArray[i];
        if (_page ==i) {
            title =  [self titleLabelCopy:self.selectedTitle];
        }else{
            title =  [self titleLabelCopy:self.unselectedTitle];
        }
        if (vc.title) {
            title.text=vc.title;
        }else{
            title.text=[NSString stringWithFormat:@"%d", i];
        }
        title.frame=CGRectMake(CGRectGetMaxX(frame), titleTopEdge, frame.size.width, frame.size.height);
        title.textAlignment=NSTextAlignmentCenter;
        [title sizeToFit];
        title.frame=CGRectMake(title.frame.origin.x, titleTopEdge, title.frame.size.width+titleLeftRightEdge, self.selectedTitle.frame.size.height+5);
        [self addSubview:title];
        frame=title.frame;
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tiltePressed:)];
        title.userInteractionEnabled=YES;
        [title addGestureRecognizer:tap];
        
        [self.titleLabelArray addObject:title];
        if (_page ==i) {
            [self addSubview:self.titleLine];
            _titleLineWidth=self.titleLine.frame.size.width;
            self.titleLine.frame = CGRectMake(title.center.x - self.titleLine.rn_width/2, self.rn_height-self.titleLine.rn_height-titleLineBottomEdge, _titleLineWidth, self.titleLine.rn_height);
        }
    }
    
    CGFloat bgWidth = self.frame.size.width - 2*titleInset;
    if (type & RNPageUIOnNav) {
        if (type & RNPageUITitleCenter) {
            self.rn_width = CGRectGetMaxX(frame) + titleInset;
        }
        self.rootVC.navigationItem.titleView = self;
        self.backgroundColor = [UIColor clearColor];
        bgWidth = CGRectGetMaxX(frame) - titleInset;
    }

    if (CGRectGetMaxX(frame) < bgWidth) {
        if (type & RNPageUITitleCenter) {
            float rate=bgWidth/(CGRectGetMaxX(frame)-titleInset);
            frame=CGRectMake(titleInset, 0, 1, 1);
            for (int i=0; i<self.titleLabelArray.count; i++) {
                UILabel *title=self.titleLabelArray[i];
                title.frame=CGRectMake(CGRectGetMaxX(frame), titleTopEdge, title.frame.size.width * rate, title.frame.size.height);
                frame=title.frame;
                if (_page ==i) {
                    self.titleLine.frame = CGRectMake(title.center.x - self.titleLine.rn_width/2, self.rn_height-self.titleLine.rn_height-titleLineBottomEdge, _titleLineWidth, self.titleLine.rn_height);
                }
            }
        }
    }

    self.contentSize=CGSizeMake(CGRectGetMaxX(frame)+titleInset, self.rn_height);
}

-(UIImageView *)titleLine{
    if (!_titleLine) {
        self.titleLine=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _titleLineWidth, 2)];
        self.titleLine.backgroundColor=self.selectedTitle.textColor;
        self.titleLine.clipsToBounds=YES;
    }
    return _titleLine;
}

-(void)tiltePressed:(UITapGestureRecognizer *)tap{
    for (int i=0; i<self.titleLabelArray.count; i++) {
        UILabel *label=self.titleLabelArray[i];
        if ([label isEqual:tap.view]) {
            UIViewController *vc=self.vcArray[i];
            if (![self.rootVC.rn_currectVC isEqual:vc]) {
                for (UIViewController *child in self.rootVC.childViewControllers) {
                    [child.view removeFromSuperview];
                    [child removeFromParentViewController];
                }
                _page = i;
                [self changeTitleView];
                float originY = self.rootVC.rn_currectVC.view.rn_y;
                float height = self.rootVC.rn_currectVC.view.rn_height;
                self.rootVC.rn_currectVC = vc;
                [self.rootVC addViewController:vc];
                self.rootVC.rn_currectVC.view.rn_y = originY;
                self.rootVC.rn_currectVC.view.rn_height = height;

                //通知rn_delegate已经切换ChildViewController
                if ([self.rn_delegate respondsToSelector:@selector(didChangeChildViewController:)]) {
                    [self.rn_delegate didChangeChildViewController:vc];
                }
            }
        }
    }
}

-(void)changeTitleView{
    //替换title
    CGRect frame=CGRectZero;
    for (int i=0; i<self.titleLabelArray.count; i++) {
        UILabel *label=self.titleLabelArray[i];
        
        UILabel *labelNew;
        if (_page ==i) {
            labelNew =  [self titleLabelCopy:self.selectedTitle];
        }else{
            labelNew =  [self titleLabelCopy:self.unselectedTitle];
        }
        
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tiltePressed:)];
        labelNew.userInteractionEnabled=YES;
        [labelNew addGestureRecognizer:tap];
        
        labelNew.text=label.text;
        labelNew.textAlignment=NSTextAlignmentCenter;
        labelNew.frame=CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
        [self.titleLabelArray replaceObjectAtIndex:i withObject:labelNew];
        frame=labelNew.frame;
        [label.superview addSubview:labelNew];
        [label removeFromSuperview];
        
        //titleScrollView自动正确位移
        if (_page ==i) {
            if (CGRectGetMinX(label.frame)<self.contentOffset.x) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.contentOffset=CGPointMake(CGRectGetMinX(label.frame), 0);
                }];
            }else if (CGRectGetMaxX(label.frame)>(self.contentOffset.x+self.frame.size.width)){
                [UIView animateWithDuration:0.3 animations:^{
                    self.contentOffset=CGPointMake(CGRectGetMinX(label.frame)+label.frame.size.width-self.frame.size.width, 0);
                }];
            }
            self.titleLine.frame = CGRectMake(labelNew.center.x - self.titleLine.rn_width/2, self.rn_height-self.titleLine.rn_height-titleLineBottomEdge, _titleLineWidth, self.titleLine.rn_height);
        }
    }
    
}

-(UILabel *)titleLabelCopy:(UILabel *)oldLabel{
    UILabel *newLabel;
    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:oldLabel];
    newLabel = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
    newLabel.clipsToBounds=YES;
    newLabel.layer.cornerRadius=oldLabel.layer.cornerRadius;
    newLabel.layer.borderWidth=oldLabel.layer.borderWidth;
    newLabel.layer.borderColor=oldLabel.layer.borderColor;
    return newLabel;
}

@end


@interface UIViewController() <UIGestureRecognizerDelegate>

@property (nonatomic) NSInteger superSubInterval;

@end


@implementation UIViewController (Page)

//#ifdef __IPHONE_11_0
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        REDSwizzleMethod([self class],
                         @selector(viewDidLoad),
                         [self class],
                         @selector(rn_viewDidLoad));
        REDSwizzleMethod([self class],
                         @selector(viewDidAppear:),
                         [self class],
                         @selector(rn_viewDidAppear:));
        REDSwizzleMethod([self class],
                         @selector(viewWillDisappear:),
                         [self class],
                         @selector(rn_viewWillDisappear:));
    });
}
//#endif

- (void)rn_viewDidLoad{
    RNTitleScrollView *scroll = [[RNTitleScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    scroll.rootVC = self;
    self.rn_navigationBar = scroll;
    [self rn_viewDidLoad];
}

- (void)rn_viewDidAppear:(BOOL)animated{
    if (self.rn_vcArray.count > 0) {
        if (self.navigationController.navigationBar.translucent) {
            if (self.rn_navigationBar.pageUIType & RNPageUINavClear) {
                rn_originY = 0;
            }else{
                rn_originY = Nav_Height;
            }
        }
    }
    [self rn_viewDidAppear:animated];
}

- (void)rn_viewWillDisappear:(BOOL)animated{
    self.rn_animator = nil;
    self.rn_navigationBar.itemBehavior=nil;
    [self rn_viewWillDisappear:animated];
}

- (void)readyPage:(NSArray *)vcArray{
    if (!self.rn_pan) {
        self.rn_pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizer:)];
        [self.view addGestureRecognizer:self.rn_pan];
        self.rn_pan.delegate = self;
    }
    self.view.userInteractionEnabled = YES;
    self.rn_vcArray = [[NSMutableArray alloc] initWithArray:vcArray];
    self.rn_currectVC = self.rn_vcArray.firstObject;
}

- (void) rn_layoutViews:(RNPageUIType)type{
    if (self.navigationController.navigationBar.translucent) {
        if (type & RNPageUINavClear) {
            rn_originY = 0;
        }else{
            rn_originY = Nav_Height;
        }
    }
    
    if (self.tabBarController.tabBar.translucent && !self.hidesBottomBarWhenPushed) {
        rn_tabbarH = self.tabBarController.tabBar.rn_height;
    }else{
        rn_tabbarH = 0;
    }
    
    if (!self.rn_headerView) {
        self.rn_headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    }
    [self.rn_headerView removeFromSuperview];
    self.rn_headerView.rn_y = self.rn_navigationBar.currectViewOriginY + rn_originY;
    self.rn_headerView.rn_width = [UIScreen mainScreen].bounds.size.width;
    [self.view addSubview:self.rn_headerView];
    
    NSLog(@"TEST:%f",self.rn_headerView.rn_y);
    
    self.rn_navigationBar.frame = CGRectMake(0, CGRectGetMaxY(self.rn_headerView.frame), [UIScreen mainScreen].bounds.size.width, 44);
    self.rn_navigationBar.vcArray = [[NSMutableArray alloc] initWithArray:self.rn_vcArray];
    self.rn_navigationBar.selectedTitle = self.rn_selectedTitle;
    self.rn_navigationBar.unselectedTitle = self.rn_unselectedTitle;
    [self.rn_navigationBar layoutView:type];

    if (!(type & RNPageUIOnNav)) {
        [self.rn_navigationBar removeFromSuperview];
        [self.view addSubview:self.rn_navigationBar];
        self.automaticallyAdjustsScrollViewInsets = YES;
    }

    for (UIViewController *vc in self.childViewControllers) {
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
    [self addViewController:self.rn_vcArray.firstObject];
}

-(void)rn_reloadData{
//    [self.rn_headerView layoutIfNeeded];

    [self.view layoutIfNeeded];
    self.rn_navigationBar.frame = CGRectMake(0, CGRectGetMaxY(self.rn_headerView.frame), [UIScreen mainScreen].bounds.size.width, 44);
//    if (!(self.rn_navigationBar.pageUIType & RNPageUIOnNav)) {
//        if (@available(iOS 11.0, *)) {
//            self.rn_currectVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.rn_navigationBar.frame), SCREEN_Width, SCREEN_Height - CGRectGetMaxY(self.rn_navigationBar.frame));
//        }else{
//            self.automaticallyAdjustsScrollViewInsets = NO;
//            self.rn_currectVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.rn_navigationBar.frame), SCREEN_Width, SCREEN_Height-CGRectGetMaxY(self.rn_navigationBar.frame)-rn_tabbarH);
//        }
//    }else{
//        if (@available(iOS 11.0, *)) {
//            self.rn_currectVC.view.rn_x = 0;
//        }else{
//            self.automaticallyAdjustsScrollViewInsets = NO;
//            self.rn_currectVC.view.frame = CGRectMake(0, rn_originY, SCREEN_Width, SCREEN_Height-rn_originY-rn_tabbarH);
//        }
//    }

}

-(void)addViewController:(UIViewController *)vc{
    [self addChildViewController:vc];
    if (!(self.rn_navigationBar.pageUIType & RNPageUIOnNav)) {
        if (@available(iOS 11.0, *)) {
            vc.view.frame = CGRectMake(0, CGRectGetMaxY(self.rn_navigationBar.frame), SCREEN_Width, SCREEN_Height - CGRectGetMaxY(self.rn_navigationBar.frame));
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
            vc.view.frame = CGRectMake(0, CGRectGetMaxY(self.rn_navigationBar.frame), SCREEN_Width, SCREEN_Height-CGRectGetMaxY(self.rn_navigationBar.frame)-rn_tabbarH);
        }
    }else{
        if (@available(iOS 11.0, *)) {
            vc.view.rn_x = 0;
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
            vc.view.frame = CGRectMake(0, rn_originY, SCREEN_Width, SCREEN_Height-rn_originY-rn_tabbarH);
        }
    }
    [self.view addSubview:vc.view];
//    [self.view bringSubviewToFront:self.rn_headerView];
    [self.view bringSubviewToFront:self.rn_navigationBar];
    [self.view bringSubviewToFront:self.rn_topView];
}

- (void)rn_contentOfftoBottom{
    self.rn_currectVC.view.frame = CGRectMake(0, self.rn_navigationBar.currectViewOriginY + self.rn_navigationBar.rn_height, SCREEN_Width, SCREEN_Height-self.rn_navigationBar.currectViewOriginY-self.rn_navigationBar.rn_height);
    if (!(self.rn_navigationBar.pageUIType & RNPageUIOnNav)) {
        self.rn_navigationBar.rn_y = MAX(MAX(CGRectGetMinY(self.rn_currectVC.view.frame)-self.rn_navigationBar.rn_height, self.rn_navigationBar.currectViewOriginY), rn_originY);
        self.rn_headerView.rn_y = CGRectGetMinY(self.rn_currectVC.view.frame) -self.rn_navigationBar.rn_height- self.rn_headerView.rn_height;
    }
//    scroll.contentOffset = CGPointMake(0, scroll.contentSize.height - scroll.rn_height);
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)sender {
    static BOOL turning;
    static BOOL linkage;
    static float itemHeight;
    static float bannerHeight = 0;
    
    static float viewMaxY = 0;
    static float viewMixY = 0;

    if (self.rn_navigationBar.pageUIType & RNPageUICanNotScroll) {
        return;
    }
    
    UIScrollView *scroll = (UIScrollView *)self.rn_panGestureRecognizer.view;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            turning = YES;
            [self.rn_animator removeAllBehaviors];
            self.rn_animator = nil;
            self.rn_navigationBar.itemBehavior=nil;
            self.rn_animator = nil;
            viewMixY = (self.rn_navigationBar.currectViewOriginY == 0) ? self.rn_navigationBar.currectViewOriginY : self.rn_navigationBar.currectViewOriginY + self.rn_navigationBar.rn_height;
            viewMaxY = viewMixY + self.rn_headerView.rn_height + ((self.rn_navigationBar.currectViewOriginY == 0) ? self.rn_navigationBar.rn_height : 0) + rn_originY;
            bannerHeight = self.rn_currectVC.view.rn_y;
            if (fabs([sender velocityInView:sender.view].x) > fabs([sender velocityInView:sender.view].y)) {
                if (self.rn_navigationBar.hasScreenEdgePan) {  //屏幕边缘的侧滑
                    return;
                }
                self.rn_navigationBar.bothPan = NO;
                if ([self.rn_vcArray indexOfObject:self.rn_currectVC] != self.rn_vcArray.count - 1 && [self.rn_vcArray indexOfObject:self.rn_currectVC] != 0) {
                    self.rn_rightVC = self.rn_vcArray[[self.rn_vcArray indexOfObject:self.rn_currectVC] + 1];
                    [self addViewController:self.rn_rightVC];
                    self.rn_rightVC.view.rn_x = SCREEN_Width;
                    self.rn_rightVC.view.rn_y = self.rn_currectVC.view.rn_y;
                    self.rn_rightVC.view.rn_height = self.rn_currectVC.view.rn_height;
                    self.rn_leftVC = self.rn_vcArray[[self.rn_vcArray indexOfObject:self.rn_currectVC] - 1];
                    [self addViewController:self.rn_leftVC];
                    self.rn_leftVC.view.rn_x = -SCREEN_Width;
                    self.rn_leftVC.view.rn_y = self.rn_currectVC.view.rn_y;
                    self.rn_leftVC.view.rn_height = self.rn_currectVC.view.rn_height;
                    turning = YES;
                }else if ([self.rn_vcArray indexOfObject:self.rn_currectVC] == self.rn_vcArray.count - 1  && [sender velocityInView:sender.view].x > 0){
                    self.rn_leftVC = self.rn_vcArray[[self.rn_vcArray indexOfObject:self.rn_currectVC] - 1];
                    [self addViewController:self.rn_leftVC];
                    self.rn_leftVC.view.rn_x = -SCREEN_Width;
                    self.rn_leftVC.view.rn_y = self.rn_currectVC.view.rn_y;
                    self.rn_leftVC.view.rn_height = self.rn_currectVC.view.rn_height;
                    self.rn_rightVC = nil;
                    turning = YES;
                }else if ([self.rn_vcArray indexOfObject:self.rn_currectVC] == 0 && [sender velocityInView:sender.view].x < 0){
                    self.rn_rightVC = self.rn_vcArray[[self.rn_vcArray indexOfObject:self.rn_currectVC] + 1];
                    [self addViewController:self.rn_rightVC];
                    self.rn_rightVC.view.rn_x = SCREEN_Width;
                    self.rn_rightVC.view.rn_y = self.rn_currectVC.view.rn_y;
                    self.rn_rightVC.view.rn_height = self.rn_currectVC.view.rn_height;
                    self.rn_leftVC = nil;
                    turning = YES;
                }else{
                    return;
                }
                if (self.rn_navigationBar.pageUIType & RNPageUIOnNav) {
                    [self.rn_panGestureRecognizer rn_changeGestureState:4];
                }
            }else{
                if (self.rn_currectVC.view.frame.origin.y <= 0 && scroll.contentOffset.y>0) {
                    linkage = NO;   //此时页面中只有childView
                }else{
                    linkage = YES;    //此时页面是parentView和childView的组合
                }
                turning = NO;
            }
            break;
        case UIGestureRecognizerStateChanged:
            if (turning) {
                if (self.rn_navigationBar.hasScreenEdgePan) {  //屏幕边缘的侧滑
                    return;
                }
                if (([self.rn_vcArray indexOfObject:self.rn_currectVC] == self.rn_vcArray.count - 1  && [sender translationInView:sender.view].x < 0) || ([self.rn_vcArray indexOfObject:self.rn_currectVC] == 0  && [sender translationInView:sender.view].x > 0)) {
                    return;
                }
                self.rn_leftVC.view.rn_x = -SCREEN_Width+[sender translationInView:sender.view].x;
                self.rn_currectVC.view.rn_x = [sender translationInView:sender.view].x;
                self.rn_rightVC.view.rn_x = SCREEN_Width+[sender translationInView:sender.view].x;
                if (!(self.rn_navigationBar.pageUIType & RNPageUIOnNav)) {
                    self.rn_navigationBar.rn_y = MAX(MAX(CGRectGetMinY(self.rn_currectVC.view.frame)-self.rn_navigationBar.rn_height, self.rn_navigationBar.currectViewOriginY), rn_originY);
                    self.rn_headerView.rn_y = CGRectGetMinY(self.rn_currectVC.view.frame) -self.rn_navigationBar.rn_height- self.rn_headerView.rn_height;
                }
                
                NSInteger page =[self.rn_vcArray indexOfObject:self.rn_currectVC];
                UILabel *labelFront=self.rn_navigationBar.titleLabelArray[page];
                UILabel *labelBack;
                if ([sender translationInView:sender.view].x < 0) {
                    if (page <self.rn_navigationBar.titleLabelArray.count-1) {
                        labelBack=self.rn_navigationBar.titleLabelArray[page +1];
                    }else{
                        labelBack=labelFront;
                    }
                }else{
                    if (page>0) {
                        labelBack=self.rn_navigationBar.titleLabelArray[page -1];
                    }else{
                        labelBack=labelFront;
                    }
                }
                float distance=fabs(CGRectGetMidX(labelBack.frame)-CGRectGetMidX(labelFront.frame));
                float rate=distance/self.view.frame.size.width;
                float rateWidth = (1 + self.rn_navigationBar.titleWidthRate * fabs(sin([sender translationInView:sender.view].x * (M_PI / self.view.frame.size.width))));
                self.rn_navigationBar.titleLine.frame=CGRectMake(labelFront.center.x-(self.rn_navigationBar.titleLineWidth/2 * rateWidth) + ( -[sender translationInView:sender.view].x  ) * rate, self.rn_navigationBar.titleLine.frame.origin.y, self.rn_navigationBar.titleLineWidth * rateWidth, self.rn_navigationBar.titleLine.frame.size.height);
                
                CGFloat ur, ug, ub, ua;
                CGFloat r, g, b, a;
                float rateColor = fabs([sender translationInView:sender.view].x)  / self.view.frame.size.width;
                [self.rn_navigationBar.unselectedTitle.textColor getRed:&ur green:&ug blue:&ub alpha:&ua];
                [self.rn_navigationBar.selectedTitle.textColor getRed:&r green:&g blue:&b alpha:&a];
                
                labelBack.textColor=[UIColor colorWithRed:ur+(r-ur)*rateColor green:ug+(g-ug)*rateColor blue:ub+(b-ub)*rateColor alpha:ua+(a-ua)*rateColor];
                labelFront.textColor=[UIColor colorWithRed:r+(ur-r)*rateColor green:g+(ug-g)*rateColor blue:b+(ub-b)*rateColor alpha:a+(ua-a)*rateColor];
                
//                [self.rn_panGestureRecognizer rn_changeGestureState:4];
            }else{
                if (self.rn_currectVC.view.frame.origin.y <= viewMixY && scroll.contentOffset.y>0) {   //currectView到达顶部 并 scroll已经滑动了
                    [self.rn_panGestureRecognizer rn_changeGestureState:2];
                    bannerHeight = -[sender translationInView:sender.view].y + viewMixY;
                    linkage = NO;   //此时页面中只有childView
                    self.rn_currectVC.view.frame = CGRectMake(0, viewMixY, SCREEN_Width, SCREEN_Height-viewMixY);
//                    NSLog(@"444:%f  %f   %f   %f",self.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, [sender translationInView:sender.view].y, bannerHeight);
                }else{
                    if (self.rn_currectVC.view.frame.origin.y >= viewMaxY && [sender velocityInView:sender.view].y > 0) {       //currectView到达底部 并 滑动向下
                        [self.rn_panGestureRecognizer rn_changeGestureState:2];
                        self.rn_currectVC.view.frame = CGRectMake(0, viewMaxY, SCREEN_Width, SCREEN_Height - viewMaxY);
//                        NSLog(@"222:%f  %f   %f   %f",self.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, [sender translationInView:sender.view].y, bannerHeight);
                    }else{
                        if (self.rn_currectVC.view.frame.origin.y <= viewMixY && [sender velocityInView:sender.view].y<0) {    //currectView到达顶部 并 滑动向上
                            [self.rn_panGestureRecognizer rn_changeGestureState:2];
                            bannerHeight = -[sender translationInView:sender.view].y;
                            linkage = NO;   //此时页面中只有childView
//                            NSLog(@"000:%f  %f   %f   %f",self.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, [sender translationInView:sender.view].y, bannerHeight);
                        }else{
                            if (scroll.contentOffset.y < 0 && [sender velocityInView:sender.view].y <= 0) {       //currectView到达底部 并 滑动向上
//                                NSLog(@"555:%f  %f   %f   %f",self.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, [sender translationInView:sender.view].y, bannerHeight);
                            }else{
                                [self.rn_panGestureRecognizer rn_changeGestureState:0];
                                self.rn_currectVC.view.frame = CGRectMake(0, bannerHeight + [sender translationInView:sender.view].y, SCREEN_Width, SCREEN_Height - bannerHeight - [sender translationInView:sender.view].y );
//                                NSLog(@"111:%f  %f   %f   %f",self.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, [sender translationInView:sender.view].y, bannerHeight);
//                                scroll.contentOffset = CGPointMake(0, 0);
                            }
                        }
                    }
                    if (!(self.rn_navigationBar.pageUIType & RNPageUIOnNav)) {
                        self.rn_navigationBar.rn_y = MAX(MAX(CGRectGetMinY(self.rn_currectVC.view.frame)-self.rn_navigationBar.rn_height, self.rn_navigationBar.currectViewOriginY), rn_originY);
                        self.rn_headerView.rn_y = CGRectGetMinY(self.rn_currectVC.view.frame) -self.rn_navigationBar.rn_height- self.rn_headerView.rn_height;
                    }
                    linkage = YES;    //此时页面是parentView和childView的组合
                }
            }
            break;
        case UIGestureRecognizerStateEnded:
            if (turning) {
                if (self.rn_navigationBar.hasScreenEdgePan) {  //屏幕边缘的侧滑
                    self.rn_navigationBar.hasScreenEdgePan = NO;
                    return;
                }
                if (self.rn_navigationBar.pageUIType & RNPageUIOnNav) {
                    if (@available(iOS 11.0, *)) {
                        [self.rn_panGestureRecognizer rn_changeGestureState:3];
                    }else{
                        [self.rn_panGestureRecognizer rn_changeGestureState:0];
                    }
                }
                self.rn_navigationBar.bothPan = YES;
                NSInteger page =[self.rn_vcArray indexOfObject:self.rn_currectVC];
                UILabel *labelFront=self.rn_navigationBar.titleLabelArray[page];
                UILabel *labelBack;
                if ([sender translationInView:sender.view].x < 0) {
                    if (page <self.rn_navigationBar.titleLabelArray.count-1) {
                        labelBack=self.rn_navigationBar.titleLabelArray[page +1];
                    }else{
                        labelBack=labelFront;
                    }
                }else{
                    if (page>0) {
                        labelBack=self.rn_navigationBar.titleLabelArray[page -1];
                    }else{
                        labelBack=labelFront;
                    }
                }
                if (fabs([sender translationInView:sender.view].x) > 100) {
                    [UIView animateWithDuration:0.2 animations:^{
                        self.rn_navigationBar.titleLine.frame = CGRectMake(labelBack.center.x - self.rn_navigationBar.titleLineWidth/2, self.rn_navigationBar.titleLine.frame.origin.y, self.rn_navigationBar.titleLineWidth, self.rn_navigationBar.titleLine.rn_height);
                        
                        labelFront.textColor = self.rn_navigationBar.unselectedTitle.textColor;
                        labelBack.textColor = self.rn_navigationBar.selectedTitle.textColor;
                        
                        labelFront.font = self.rn_navigationBar.unselectedTitle.font;
                        labelBack.font = self.rn_navigationBar.selectedTitle.font;
                    }];
                    if ([sender translationInView:sender.view].x < 0) {
                        if (page <self.rn_navigationBar.titleLabelArray.count-1) {
                            self.rn_navigationBar.page = (int)page+1;
                        }
                    }else{
                        if (page>0) {
                            self.rn_navigationBar.page = (int)page-1;
                        }
                    }
                }else{
                    [UIView animateWithDuration:0.2 animations:^{
                        self.rn_navigationBar.titleLine.frame = CGRectMake(labelFront.center.x - self.rn_navigationBar.titleLineWidth/2, self.rn_navigationBar.titleLine.frame.origin.y, self.rn_navigationBar.titleLineWidth, self.rn_navigationBar.titleLine.rn_height);
                        
                        labelBack.textColor = self.rn_navigationBar.unselectedTitle.textColor;
                        labelFront.textColor = self.rn_navigationBar.selectedTitle.textColor;
                        
                        labelBack.font = self.rn_navigationBar.unselectedTitle.font;
                        labelFront.font = self.rn_navigationBar.selectedTitle.font;
                    }];
                }
                
                if (([self.rn_vcArray indexOfObject:self.rn_currectVC] == self.rn_vcArray.count - 1  && [sender translationInView:sender.view].x < 0) || ([self.rn_vcArray indexOfObject:self.rn_currectVC] == 0  && [sender translationInView:sender.view].x > 0)) {
                    return;
                }
                if (fabs([sender translationInView:sender.view].x) > 100) {
                    [UIView animateWithDuration:0.2 animations:^{
                        if ([sender translationInView:sender.view].x < 0) {
                            self.rn_currectVC.view.rn_x = -SCREEN_Width;
                            self.rn_rightVC.view.rn_x = 0;
                            self.rn_leftVC.view.rn_x = -SCREEN_Width*2;
                        }else{
                            self.rn_currectVC.view.rn_x = SCREEN_Width;
                            self.rn_rightVC.view.rn_x = SCREEN_Width*2;
                            self.rn_leftVC.view.rn_x = 0;
                        }
                    } completion:^(BOOL finished) {
                        if (self.rn_currectVC.view.frame.origin.x < 0) {
                            self.rn_currectVC = self.rn_rightVC;
                        }else{
                            self.rn_currectVC = self.rn_leftVC;
                        }
                        for (UIViewController *vc in self.childViewControllers) {
                            if (![vc isEqual:self.rn_currectVC] ) {
                                [vc.view removeFromSuperview];
                                [vc removeFromParentViewController];
                            }
                        }
                        //通知rn_delegate已经切换ChildViewController
                        if ([self.rn_navigationBar.rn_delegate respondsToSelector:@selector(didChangeChildViewController:)]) {
                            [self.rn_navigationBar.rn_delegate didChangeChildViewController:self.rn_currectVC];
                        }
                    }];
                }else{
                    [UIView animateWithDuration:0.2 animations:^{
                        self.rn_currectVC.view.rn_x = 0;
                        self.rn_rightVC.view.rn_x = SCREEN_Width;
                        self.rn_leftVC.view.rn_x = -SCREEN_Width;
                    }completion:^(BOOL finished) {
                        for (UIViewController *vc in self.childViewControllers) {
                            if (![vc isEqual:self.rn_currectVC] ) {
                                [vc.view removeFromSuperview];
                                [vc removeFromParentViewController];
                            }
                        }
                    }];
                }
                if (!(self.rn_navigationBar.pageUIType & RNPageUIOnNav)) {
                    self.rn_navigationBar.rn_y = MAX(MAX(CGRectGetMinY(self.rn_currectVC.view.frame)-self.rn_navigationBar.rn_height, self.rn_navigationBar.currectViewOriginY), rn_originY);
                    self.rn_headerView.rn_y = CGRectGetMinY(self.rn_currectVC.view.frame) -self.rn_navigationBar.rn_height- self.rn_headerView.rn_height;
                }
                
            }else{
                if (scroll.contentOffset.y >= 0) {
                    self.rn_animator = [[UIDynamicAnimator alloc] initWithReferenceView:scroll];
                    CGFloat speed = [sender velocityInView:sender.view].y;
                    dynamicItem * item = [dynamicItem new];
                    item.center=CGPointMake(0, self.rn_currectVC.view.frame.origin.y);
                    self.rn_navigationBar.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
                    [self.rn_navigationBar.itemBehavior addLinearVelocity:CGPointMake(0, speed) forItem:item];
                    self.rn_navigationBar.itemBehavior.resistance = 3;
                    self.rn_navigationBar.itemBehavior.elasticity = 1;
                    [self.rn_animator addBehavior:self.rn_navigationBar.itemBehavior];

                    itemHeight = -viewMixY;
                    __weak __typeof(&*self)weakSelf = self;
                    self.rn_navigationBar.itemBehavior.action = ^(){

                        if (weakSelf.rn_delayedTouchesBeganGestureRecognizer.state == UIGestureRecognizerStateFailed) {
//                            bannerHeight = weakSelf.rn_currectVC.view.frame.origin.y;
                            [weakSelf.rn_animator removeAllBehaviors];
                            return;
                        }
//                        NSLog(@"aaa:%f  %f   %f   %f",weakSelf.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, item.center.y, translationHeight);

                        if (speed < 0) {      //向上滑
                            if (linkage) {    //只处理child和parent同时存在的情况
                                if (item.center.y < viewMixY) {
//                                    NSLog(@"000:%f  %f   %f   %f",weakSelf.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, item.center.y, speed);
                                    scroll.contentOffset = CGPointMake(0, -item.center.y + viewMixY);
                                    weakSelf.rn_currectVC.view.frame = CGRectMake(0, viewMixY, SCREEN_Width, SCREEN_Height - viewMixY);

                                    if (viewMixY + scroll.rn_height > scroll.contentSize.height + item.center.y) {
                                        [weakSelf.rn_animator removeAllBehaviors];
                                        dynamicItem * item1 = [dynamicItem new];
                                        if (scroll.rn_height < scroll.contentSize.height) {
                                            item1.center=CGPointMake(0, -item.center.y);
                                        }else{
                                            item1.center=CGPointMake(0, 0);
                                        }
                                        
                                        UIDynamicItemBehavior *decelerationBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[item1]];
                                        [decelerationBehavior addLinearVelocity:CGPointMake(0, -[weakSelf.rn_navigationBar.itemBehavior linearVelocityForItem:item].y) forItem:item1];
                                        decelerationBehavior.resistance = 3.0;
                                        [weakSelf.rn_animator addBehavior:decelerationBehavior];

                                        decelerationBehavior.action = ^{
//                                            NSLog(@"222:%f  %f   %f   %f",weakSelf.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, item.center.y, item1.center.y);

                                            if (weakSelf.rn_delayedTouchesBeganGestureRecognizer.state == UIGestureRecognizerStateFailed) {
//                                                NSLog(@"333:%f  %f   %f   %f",weakSelf.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, item.center.y, item1.center.y);
//                                                bannerHeight = weakSelf.rn_currectVC.view.frame.origin.y;
                                                [weakSelf.rn_animator removeAllBehaviors];
                                                return;
                                            }

                                            // IMPORTANT: If the deceleration behavior is removed, the bounds' origin will stop updating. See other possible ways of updating origin in the accompanying blog post.
                                            CGRect bounds = scroll.bounds;
                                            bounds.origin = item1.center;

                                            if (-item.center.y + scroll.rn_height < scroll.contentSize.height) {
//                                                NSLog(@"444:%f  %f   %f   %f",weakSelf.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, item.center.y, item1.center.y);
                                                [weakSelf.rn_animator removeAllBehaviors];
//                                                NSLog(@"5  %f", item.center.y);
//                                                bannerHeight = weakSelf.rn_currectVC.view.frame.origin.y;
                                                return;
                                            }

                                            if (weakSelf.rn_animator.behaviors.count == 2) {

                                                CGPoint target;
                                                if (scroll.rn_height < scroll.contentSize.height) {
                                                    target = CGPointMake(0, scroll.contentSize.height - scroll.rn_height);
                                                }else{
                                                    target = CGPointMake(0, 0);
                                                }
//                                                NSLog(@"555:%f  %f   %f   %f   %f",weakSelf.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, item.center.y, item1.center.y, target.y);
                                                UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:item1 attachedToAnchor:target];
                                                // Has to be equal to zero, because otherwise the bounds.origin wouldn't exactly match the target's position.
                                                springBehavior.length = 0;
                                                // These two values were chosen by trial and error.
                                                springBehavior.damping = 1;
                                                springBehavior.frequency = 2;

                                                [weakSelf.rn_animator addBehavior:springBehavior];
                                            }
                                            scroll.contentOffset = item1.center;
                                        };
//                                        bannerHeight = weakSelf.rn_currectVC.view.frame.origin.y;
                                        return;
                                    }

                                }else{
//                                    NSLog(@"111:%f  %f   %f ",weakSelf.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, item.center.y);
                                    scroll.contentOffset = CGPointMake(0, 0);
                                    weakSelf.rn_currectVC.view.frame = CGRectMake(0, item.center.y, SCREEN_Width, SCREEN_Height-item.center.y);
                                }
                                if (!(weakSelf.rn_navigationBar.pageUIType & RNPageUIOnNav)) {
                                    weakSelf.rn_navigationBar.rn_y = MAX(MAX(CGRectGetMinY(weakSelf.rn_currectVC.view.frame)-weakSelf.rn_navigationBar.rn_height, weakSelf.rn_navigationBar.currectViewOriginY), rn_originY);
                                    weakSelf.rn_headerView.rn_y = item.center.y - weakSelf.rn_navigationBar.rn_height - weakSelf.rn_headerView.rn_height;
                                }
                            }
                            itemHeight = -item.center.y;
                        }else if (speed > 0){
                            if (scroll.contentOffset.y <= 0) {
                                scroll.contentOffset = CGPointMake(0, 0);

                                if (weakSelf.rn_currectVC.view.frame.origin.y < viewMaxY) {
                                    weakSelf.rn_currectVC.view.frame = CGRectMake(0, viewMixY + item.center.y + itemHeight, SCREEN_Width, SCREEN_Height - item.center.y - itemHeight - viewMixY);

//                                    NSLog(@"666:%f  %f   %f   %f",weakSelf.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, item.center.y, translationHeight);
                                }else{
                                    weakSelf.rn_currectVC.view.frame = CGRectMake(0, viewMaxY, SCREEN_Width, SCREEN_Height-viewMaxY);
//                                    NSLog(@"777:%f  %f   %f   %f",weakSelf.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, item.center.y, translationHeight);
                                }
                                if (!(weakSelf.rn_navigationBar.pageUIType & RNPageUIOnNav)) {
                                    weakSelf.rn_navigationBar.rn_y = MAX(MAX(CGRectGetMinY(weakSelf.rn_currectVC.view.frame)-weakSelf.rn_navigationBar.rn_height, weakSelf.rn_navigationBar.currectViewOriginY), rn_originY);
                                    weakSelf.rn_headerView.rn_y = CGRectGetMinY(weakSelf.rn_currectVC.view.frame) -weakSelf.rn_navigationBar.rn_height- weakSelf.rn_headerView.rn_height;
                                }
                            }else{
                                itemHeight = -item.center.y;
//                                NSLog(@"888:%f  %f   %f   %f",weakSelf.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, item.center.y, translationHeight);
                            }
                        }else{
                            itemHeight = -item.center.y;
//                            NSLog(@"999:%f  %f   %f   %f",weakSelf.rn_currectVC.view.frame.origin.y, scroll.contentOffset.y, item.center.y, translationHeight);
                        }
//                        bannerHeight = weakSelf.rn_currectVC.view.frame.origin.y;
                    };
                }
            }
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    NSLog(@"gestureRecognizer:%@",gestureRecognizer);
    if ([NSStringFromClass(gestureRecognizer.class) isEqualToString:@"UIScreenEdgePanGestureRecognizer"] && ( gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStatePossible)) {
        self.rn_navigationBar.hasScreenEdgePan = YES;
        return YES;
    }
    if ([self.rn_pan isEqual:gestureRecognizer] && self.rn_headerView.rn_height != 0 && self.rn_navigationBar.bothPan) {
        if ([NSStringFromClass(otherGestureRecognizer.class) isEqualToString:@"UIScrollViewPanGestureRecognizer"] ) {
            UIView *superView = gestureRecognizer.view;
            UIView *subView = otherGestureRecognizer.view;
            while (![superView isEqual:subView]) {
                subView = subView.superview;
                BOOL has = NO;
                for (UIGestureRecognizer *gest in subView.gestureRecognizers) {
                    if ([NSStringFromClass(gest.class) isEqualToString:@"UIScrollViewPanGestureRecognizer"]) {
                        has = YES;
                        break;
                    }
                }
                if (has) {
                    return NO;
                }
            }
            self.rn_panGestureRecognizer = otherGestureRecognizer;
            return YES;
        }
        if ([NSStringFromClass(otherGestureRecognizer.class) isEqualToString:@"UIScrollViewDelayedTouchesBeganGestureRecognizer"]){
            UIView *superView = gestureRecognizer.view;
            UIView *subView = otherGestureRecognizer.view;
            while (![superView isEqual:subView]) {
                subView = subView.superview;
                BOOL has = NO;
                for (UIGestureRecognizer *gest in subView.gestureRecognizers) {
                    if ([NSStringFromClass(gest.class) isEqualToString:@"UIScrollViewDelayedTouchesBeganGestureRecognizer"]) {
                        has = YES;
                        break;
                    }
                }
                if (has) {
                    return NO;
                }
            }
            self.rn_delayedTouchesBeganGestureRecognizer = otherGestureRecognizer;
            return YES;
        }
    }
    return NO;
}

#pragma mark - GET SET

- (UIView *)rn_headerView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_headerView:(UIView *)headerView {
    objc_setAssociatedObject(self, @selector(rn_headerView), headerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)rn_vcArray {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_vcArray:(NSMutableArray *)vcArray {
    objc_setAssociatedObject(self, @selector(rn_vcArray), vcArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIGestureRecognizer *)rn_panGestureRecognizer {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_panGestureRecognizer:(UIGestureRecognizer *)panGestureRecognizer {
    objc_setAssociatedObject(self, @selector(rn_panGestureRecognizer), panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIGestureRecognizer *)rn_delayedTouchesBeganGestureRecognizer {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_delayedTouchesBeganGestureRecognizer:(UIGestureRecognizer *)delayedTouchesBeganGestureRecognizer {
    objc_setAssociatedObject(self, @selector(rn_delayedTouchesBeganGestureRecognizer), delayedTouchesBeganGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIDynamicAnimator *)rn_animator {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_animator:(UIDynamicAnimator *)animator{
    objc_setAssociatedObject(self, @selector(rn_animator), animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)rn_currectVC {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_currectVC:(UIViewController *)currectVC{
    objc_setAssociatedObject(self, @selector(rn_currectVC), currectVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)rn_leftVC {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_leftVC:(UIViewController *)leftVC{
    objc_setAssociatedObject(self, @selector(rn_leftVC), leftVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)rn_rightVC {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_rightVC:(UIViewController *)rightVC{
    objc_setAssociatedObject(self, @selector(rn_rightVC), rightVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RNTitleScrollView *)rn_navigationBar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_navigationBar:(RNTitleScrollView *)navigationBar{
    objc_setAssociatedObject(self, @selector(rn_navigationBar), navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)rn_selectedTitle {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_selectedTitle:(UILabel *)rn_selectedTitle{
    objc_setAssociatedObject(self, @selector(rn_selectedTitle), rn_selectedTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)rn_unselectedTitle {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_unselectedTitle:(UILabel *)rn_unselectedTitle{
    objc_setAssociatedObject(self, @selector(rn_unselectedTitle), rn_unselectedTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIPanGestureRecognizer *)rn_pan {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_pan:(UIPanGestureRecognizer *)rn_pan{
    objc_setAssociatedObject(self, @selector(rn_pan), rn_pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)rn_topView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRn_topView:(UIView *)rn_topView {
    objc_setAssociatedObject(self, @selector(rn_topView), rn_topView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
