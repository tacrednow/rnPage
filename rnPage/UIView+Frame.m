//
//  UIView+Frame.m
//  sxsiosapp
//
//  Created by rednow on 2018/5/1.
//  Copyright © 2018年 mshare. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)


- (CGFloat)rn_x {
    return self.frame.origin.x;
}

- (void)setRn_x:(CGFloat)rn_x{
    CGRect rect = self.frame;
    rect.origin.x = rn_x;
    self.frame = rect;
}

- (CGFloat)rn_y{
    return self.frame.origin.y;
}

- (void)setRn_y:(CGFloat)rn_y{
    CGRect rect = self.frame;
    rect.origin.y = rn_y;
    self.frame = rect;
}

- (CGFloat)rn_width {
    return self.frame.size.width;
}

- (void)setRn_width:(CGFloat)rn_width{
    CGRect rect = self.frame;
    rect.size.width = rn_width;
    self.frame = rect;
}

- (CGFloat)rn_height {
    return self.frame.size.height;
}

- (void)setRn_height:(CGFloat)rn_height{
    CGRect rect = self.frame;
    rect.size.height = rn_height;
    self.frame = rect;
}



@end
