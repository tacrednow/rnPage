//
//  REDSwizzle.h
//  sxsiosapp
//
//  Created by rednow on 2018/4/25.
//  Copyright © 2018年 mshare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

extern void REDSwizzleMethod(Class originalCls, SEL originalSelector, Class swizzledCls, SEL swizzledSelector);

