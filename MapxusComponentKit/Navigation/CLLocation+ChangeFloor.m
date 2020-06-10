//
//  CLLocation+ChangeFloor.m
//  BeeMapDemo
//
//  Created by Chenghao Guo on 2018/12/28.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "CLLocation+ChangeFloor.h"
#import <objc/runtime.h>

@implementation CLLocation (ChangeFloor)

+ (void)load
{
    static dispatch_once_t mxmOnceToken;
    dispatch_once(&mxmOnceToken, ^{
        SEL oldSelector = @selector(floor);
        SEL newSelector = @selector(hook_getFloor);
        Method oldMethod = class_getInstanceMethod([self class], oldSelector);
        Method newMethod = class_getInstanceMethod([self class], newSelector);
        
        // 若未实现代理方法，则先添加代理方法
        BOOL isSuccess = class_addMethod([self class], oldSelector, class_getMethodImplementation([self class], newSelector), method_getTypeEncoding(newMethod));
        if (isSuccess) {
            class_replaceMethod([self class], newSelector, class_getMethodImplementation([self class], oldSelector), method_getTypeEncoding(oldMethod));
        } else {
            method_exchangeImplementations(oldMethod, newMethod);
        }
    });
}

- (CLFloor *)hook_getFloor
{
    if (self.myFloor) {
        return self.myFloor;
    } else {
        return [self hook_getFloor];
    }
}

- (CLFloor *)myFloor {
    return objc_getAssociatedObject(self, @selector(myFloor));
}

- (void)setMyFloor:(CLFloor *)myFloor {
    objc_setAssociatedObject(self, @selector(myFloor), myFloor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
