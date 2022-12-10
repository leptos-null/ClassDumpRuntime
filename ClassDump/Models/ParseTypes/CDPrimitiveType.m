//
//  CDPrimitiveType.m
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDPrimitiveType.h"

@implementation CDPrimitiveType

+ (nonnull instancetype)primitiveWithRawType:(CDPrimitiveRawType)rawType {
    CDPrimitiveType *ret = [self new];
    ret.rawType = rawType;
    return ret;
}

@end
