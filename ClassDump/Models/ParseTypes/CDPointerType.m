//
//  CDPointerType.m
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDPointerType.h"

@implementation CDPointerType

+ (nonnull instancetype)pointerToPointee:(nonnull CDParseType *)pointee {
    CDPointerType *ret = [self new];
    ret.pointee = pointee;
    return ret;
}
@end
