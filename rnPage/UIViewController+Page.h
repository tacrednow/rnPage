//
//  UIViewController+Page.h
//  sxsiosapp
//
//  Created by rednow on 2018/4/26.
//  Copyright © 2018年 mshare. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class RNTitleScrollView;

typedef NS_ENUM(NSInteger, RNPageUIType) {
    RNPageUIDefault             = 0,
    RNPageUITitleCenter         = 1 << 0,
    RNPageUITitleBlur           = 1 << 1,
    RNPageUINavClear            = 1 << 2,
    RNPageUIOnNav               = 1 << 3,
    RNPageUICanNotScroll        = 1 << 4,
};

@protocol UIViewControllerPageDelegate <NSObject>

@optional
-(void)didChangeChildViewController:(UIViewController *)viewController;

@end

@interface RNTitleScrollView : UIScrollView 

@property (nonatomic, assign) id<UIViewControllerPageDelegate> rn_delegate;
@property (nonatomic, strong)UILabel *selectedTitle;
@property (nonatomic, strong)UILabel *unselectedTitle;
@property (nonatomic, strong)NSMutableArray *vcArray;
@property (nonatomic, strong) NSMutableArray *titleLabelArray;
@property (nonatomic, strong)UIImageView *titleLine;
@property (nonatomic, weak)UIViewController *rootVC;
@property (nonatomic) float titleWidthRate;
@property (nonatomic) float titleLineWidth;
@property (nonatomic) int page;
@property (nonatomic) float currectViewOriginY;    //当前VC可以达到的最顶部
@property (nonatomic) RNPageUIType pageUIType;

@end

@interface UIViewController (Page)

@property (nonatomic, strong) UIPanGestureRecognizer *rn_pan;
@property (nonatomic, strong) UIView *rn_topView;
@property (nonatomic, strong) UIView *rn_headerView;
@property (nonatomic, strong) NSMutableArray *rn_vcArray;

@property (nonatomic, strong) UIViewController *rn_currectVC;
@property (nonatomic, strong) UIViewController *rn_leftVC;
@property (nonatomic, strong) UIViewController *rn_rightVC;

@property (nonatomic, strong) UILabel *rn_selectedTitle;
@property (nonatomic, strong) UILabel *rn_unselectedTitle;

@property (nonatomic, strong) RNTitleScrollView *rn_navigationBar;

- (void)readyPage:(NSArray *)vcArray;
- (void)rn_layoutViews:(RNPageUIType)type;
- (void)rn_reloadData;
- (void)addViewController:(UIViewController *)vc;
- (void)rn_contentOfftoBottom;

@end
