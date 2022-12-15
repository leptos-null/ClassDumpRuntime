//
//  CDPrimitiveType.m
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDPrimitiveType.h"

NSString *NSStringFromCDPrimitiveRawType(CDPrimitiveRawType rawType) {
    switch (rawType) {
        case CDPrimitiveRawTypeVoid:
            return @"void";
        case CDPrimitiveRawTypeChar:
            return @"char";
        case CDPrimitiveRawTypeInt:
            return @"int";
        case CDPrimitiveRawTypeShort:
            return @"short";
        case CDPrimitiveRawTypeLong:
            return @"long";
        case CDPrimitiveRawTypeLongLong:
            return @"long long";
        case CDPrimitiveRawTypeInt128:
            return @"__int128";
        case CDPrimitiveRawTypeUnsignedChar:
            return @"unsigned char";
        case CDPrimitiveRawTypeUnsignedInt:
            return @"unsigned int";
        case CDPrimitiveRawTypeUnsignedShort:
            return @"unsigned short";
        case CDPrimitiveRawTypeUnsignedLong:
            return @"unsigned long";
        case CDPrimitiveRawTypeUnsignedLongLong:
            return @"unsigned long long";
        case CDPrimitiveRawTypeUnsignedInt128:
            return @"unsigned __int128";
        case CDPrimitiveRawTypeFloat:
            return @"float";
        case CDPrimitiveRawTypeDouble:
            return @"double";
        case CDPrimitiveRawTypeLongDouble:
            return @"long double";
        case CDPrimitiveRawTypeBool:
            return @"BOOL";
        case CDPrimitiveRawTypeClass:
            return @"Class";
        case CDPrimitiveRawTypeSel:
            return @"SEL";
        case CDPrimitiveRawTypeFunction:
            return @"void /* function */";
    }
}

@implementation CDPrimitiveType

+ (nonnull instancetype)primitiveWithRawType:(CDPrimitiveRawType)rawType {
    CDPrimitiveType *ret = [self new];
    ret.rawType = rawType;
    return ret;
}

- (NSString *)stringForVariableName:(NSString *)varName {
    NSMutableString *build = [NSMutableString string];
    NSString *modifiersString = [self modifiersString];
    if (modifiersString.length > 0) {
        [build appendString:modifiersString];
        [build appendString:@" "];
    }
    [build appendString:NSStringFromCDPrimitiveRawType(self.rawType)];
    if (varName != nil) {
        [build appendString:@" "];
        [build appendString:varName];
    }
    return [build copy];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        __typeof(self) casted = (__typeof(casted))object;
        return (self.modifiers == casted.modifiers || [self.modifiers isEqualToArray:casted.modifiers]) &&
        self.rawType == casted.rawType;
    }
    return NO;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {modifiers: '%@', rawType: '%@'}",
            [self class], self, [self modifiersString], NSStringFromCDPrimitiveRawType(self.rawType)];
}

@end
