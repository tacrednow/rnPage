//
//  ViewController.m
//  testrnPage
//
//  Created by rednow on 2018/7/1.
//  Copyright © 2018年 rednow. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+Page.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UILabel *selectLabel;
@property (strong, nonatomic) IBOutlet UILabel *unselectLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rn_selectedTitle = self.selectLabel;
    self.rn_unselectedTitle = self.unselectLabel;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UIViewController *vc0 = [storyboard instantiateViewControllerWithIdentifier:@"vc0"];
    vc0.title = @"公司详情";
    UIViewController *vc1 = [storyboard instantiateViewControllerWithIdentifier:@"vc1"];
    vc1.title = @"在招职位";
    UIViewController *vc2 = [storyboard instantiateViewControllerWithIdentifier:@"vc2"];
    vc2.title = @"公司视频";
    [self readyPage:@[vc0, vc1, vc2]];
    [self rn_layoutViews:RNPageUITitleCenter];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
