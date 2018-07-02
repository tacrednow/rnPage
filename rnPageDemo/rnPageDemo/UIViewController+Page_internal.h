//
//  UIViewController+Page_internal.h
//  sxsiosapp
//
//  Created by rednow on 2018/4/28.
//  Copyright © 2018年 mshare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (UIViewController_Page_internal)

@property (nonatomic, strong) UIGestureRecognizer *rn_panGestureRecognizer;
@property (nonatomic, strong) UIGestureRecognizer *rn_delayedTouchesBeganGestureRecognizer;
@property (nonatomic, strong) UIDynamicAnimator *rn_animator;

//- (void)km_addTransitionNavigationBarIfNeeded;

@end
