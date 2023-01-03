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
        case CDPrimitiveRawTypeBlank:
            return @"void /* unknown type, blank encoding */";
        case CDPrimitiveRawTypeEmpty:
            return @"void /* unknown type, empty encoding */";
    }
}

@implementation CDPrimitiveType

+ (nonnull instancetype)primitiveWithRawType:(CDPrimitiveRawType)rawType {
    CDPrimitiveType *ret = [self new];
    ret.rawType = rawType;
    return ret;
}

- (CDSemanticString *)semanticStringForVariableName:(NSString *)varName {
    CDSemanticString *build = [CDSemanticString new];
    CDSemanticString *modifiersString = [self modifiersSemanticString];
    if (modifiersString.length > 0) {
        [build appendSemanticString:modifiersString];
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
    }
    switch (self.rawType) {
        case CDPrimitiveRawTypeVoid:
            [build appendString:@"void" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeChar:
            [build appendString:@"char" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeInt:
            [build appendString:@"int" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeShort:
            [build appendString:@"short" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeLong:
            [build appendString:@"long" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeLongLong:
            [build appendString:@"long long" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeInt128:
            [build appendString:@"__int128" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeUnsignedChar:
            [build appendString:@"unsigned char" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeUnsignedInt:
            [build appendString:@"unsigned int" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeUnsignedShort:
            [build appendString:@"unsigned short" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeUnsignedLong:
            [build appendString:@"unsigned long" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeUnsignedLongLong:
            [build appendString:@"unsigned long long" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeUnsignedInt128:
            [build appendString:@"unsigned __int128" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeFloat:
            [build appendString:@"float" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeDouble:
            [build appendString:@"double" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeLongDouble:
            [build appendString:@"long double" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeBool:
            [build appendString:@"BOOL" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeClass:
            [build appendString:@"Class" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeSel:
            [build appendString:@"SEL" semanticType:CDSemanticTypeKeyword];
            break;
        case CDPrimitiveRawTypeFunction:
            [build appendString:@"void" semanticType:CDSemanticTypeKeyword];
            [build appendString:@" " semanticType:CDSemanticTypeStandard];
            [build appendString:@"/* function */" semanticType:CDSemanticTypeComment];
            break;
        case CDPrimitiveRawTypeBlank:
            [build appendString:@"void" semanticType:CDSemanticTypeKeyword];
            [build appendString:@" " semanticType:CDSemanticTypeStandard];
            [build appendString:@"/* unknown type, blank encoding */" semanticType:CDSemanticTypeComment];
            break;
        case CDPrimitiveRawTypeEmpty:
            [build appendString:@"void" semanticType:CDSemanticTypeKeyword];
            [build appendString:@" " semanticType:CDSemanticTypeStandard];
            [build appendString:@"/* unknown type, empty encoding */" semanticType:CDSemanticTypeComment];
            break;
    }
    if (varName != nil) {
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
        [build appendString:varName semanticType:CDSemanticTypeVariable];
    }
    return build;
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
