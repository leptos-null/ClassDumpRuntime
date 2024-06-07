//
//  CDPrimitiveType.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import <ClassDump/CDParseType.h>

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
    
    /// @note This is not a real type.
    /// @discussion A blank type represents a type that
    /// is encoded to a space character. There are multiple
    /// types that are encoded to a space character, and it
    /// is not possible for us to discern the difference
    /// between them.
    CDPrimitiveRawTypeBlank,
    /// @note This is not a real type.
    /// @discussion An empty type represents a type that
    /// was not encoded. Usually this occurs when types
    /// that do not exist in Objective-C are bridged into
    /// Objective-C (this should only occur at runtime).
    CDPrimitiveRawTypeEmpty,
};

NS_HEADER_AUDIT_BEGIN(nullability)

OBJC_EXTERN NSString *_Nullable NSStringFromCDPrimitiveRawType(CDPrimitiveRawType);

@interface CDPrimitiveType : CDParseType

@property (nonatomic) CDPrimitiveRawType rawType;

+ (instancetype)primitiveWithRawType:(CDPrimitiveRawType)rawType;

@end

NS_HEADER_AUDIT_END(nullability)
