//
//  CDPrimitiveType.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDParseType.h"

typedef NS_ENUM(NSUInteger, CDPrimitiveRawType) {
    CDPrimitiveRawTypeVoid,
    
    CDPrimitiveRawTypeChar,
    CDPrimitiveRawTypeInt,
    CDPrimitiveRawTypeShort,
    CDPrimitiveRawTypeLong,
    CDPrimitiveRawTypeLongLong,
    CDPrimitiveRawTypeInt128,
    
    CDPrimitiveRawTypeUnsignedChar,
    CDPrimitiveRawTypeUnsignedInt,
    CDPrimitiveRawTypeUnsignedShort,
    CDPrimitiveRawTypeUnsignedLong,
    CDPrimitiveRawTypeUnsignedLongLong,
    CDPrimitiveRawTypeUnsignedInt128,
    
    CDPrimitiveRawTypeFloat,
    CDPrimitiveRawTypeDouble,
    CDPrimitiveRawTypeLongDouble,
    
    CDPrimitiveRawTypeBool,
    CDPrimitiveRawTypeClass,
    CDPrimitiveRawTypeSel,
    
    CDPrimitiveRawTypeFunction,
};

@interface CDPrimitiveType : CDParseType

@property (nonatomic) CDPrimitiveRawType rawType;

+ (nonnull instancetype)primitiveWithRawType:(CDPrimitiveRawType)rawType;

@end
