//
//  UIGestureRecognizer+Category.m
//  sxsiosapp
//
//  Created by rednow on 2018/4/25.
//  Copyright © 2018年 mshare. All rights reserved.
//

#import "UIGestureRecognizer+Category.h"
#import "REDSwizzle.h"

@implementation UIGestureRecognizer (Category)

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        REDSwizzleMethod([self class],
//                         @selector(initWithTarget:action:),
//                         [self class],
//                         @selector(rn_initWithTarget:action:));
//        REDSwizzleMethod([self class],
//                         @selector(requireGestureRecognizerToFail:),
//                         [self class],
//                         @selector(rn_requireGestureRecognizerToFail:));
//    });
//}
//
//- (instancetype)rn_initWithTarget:(nullable id)target action:(nullable SEL)action{
////    [self someMethod];
//    return [self rn_initWithTarget:target action:action];
//}
//
//- (void)rn_requireGestureRecognizerToFail:(UIGestureRecognizer *)otherGestureRecognizer{
//    [self rn_requireGestureRecognizerToFail:otherGestureRecognizer];
//}

-(void)rn_changeGestureState:(NSInteger)state{
    [self setValue:@(state) forKey:@"_state"];

}

//-(id)rn_getGestureValue{
//    return [NSString stringWithFormat:@"%@", [self valueForKey:@"_state"]];
//}

//- (void)someMethod {
//    unsigned int count = 0;
//    //该方法是C函数，获取所有属性
//    Ivar * ivars = class_copyIvarList([self.superclass class], &count);
//    NSLog(@"\n");
////    NSLog(@"TEST:%@",self);
////    if ([NSStringFromClass(self.class) isEqualToString:@"UIPanGestureRecognizer"]) {
//        for (unsigned int i = 0; i < count; i ++)
//        {
//            Ivar ivar = ivars[i];
//            //获取属性名
//            const char * name = ivar_getName(ivar);
//            //使用KVC直接获取相关属性的值
////            NSObject *value = [self valueForKey:[NSString stringWithUTF8String:name]];
//            NSLog(@"dddddddd%s", name);
////                    NSLog(@"dddddddd%s %@", name, value);
//        }
////        NSLog(@"TEST:%@",[NSString stringWithFormat:@"%@", [self valueForKey:@"_ignoresStationaryTouches"]]);
////    }
//    //需要释放获取到的属性
//    free(ivars);
//}


@end

