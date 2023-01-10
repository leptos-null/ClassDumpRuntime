//
//  CDParseType.m
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDParseType.h"

NSString *NSStringFromCDTypeModifier(CDTypeModifier modifier) {
    switch (modifier) {
        case CDTypeModifierConst:
            return @"const";
        case CDTypeModifierComplex:
            return @"_Complex";
        case CDTypeModifierAtomic:
            return @"_Atomic";
        case CDTypeModifierIn:
            return @"in";
        case CDTypeModifierInOut:
            return @"inout";
        case CDTypeModifierOut:
            return @"out";
        case CDTypeModifierBycopy:
            return @"bycopy";
        case CDTypeModifierByref:
            return @"byref";
        case CDTypeModifierOneway:
            return @"oneway";
        default:
            NSCAssert(NO, @"Unknown CDTypeModifier value");
            return nil;
    }
}

@implementation CDParseType

- (NSString *)stringForVariableName:(NSString *)varName {
    return [[self semanticStringForVariableName:varName] string];
}

- (CDSemanticString *)semanticStringForVariableName:(NSString *)varName {
    NSAssert(NO, @"Subclasses must implement %@", NSStringFromSelector(_cmd));
    return [CDSemanticString new];
}

- (NSString *)modifiersString {
    NSArray<NSNumber *> *const modifiers = self.modifiers;
    NSMutableArray<NSString *> *strings = [NSMutableArray arrayWithCapacity:modifiers.count];
    [modifiers enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
        strings[idx] = NSStringFromCDTypeModifier(value.unsignedIntegerValue);
    }];
    return [strings componentsJoinedByString:@" "];
}

- (CDSemanticString *)modifiersSemanticString {
    NSArray<NSNumber *> *const modifiers = self.modifiers;
    CDSemanticString *build = [CDSemanticString new];
    NSUInteger const modifierCount = self.modifiers.count;
    [modifiers enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
        NSString *string = NSStringFromCDTypeModifier(value.unsignedIntegerValue);
        [build appendString:string semanticType:CDSemanticTypeKeyword];
        if ((idx + 1) < modifierCount) {
            [build appendString:@" " semanticType:CDSemanticTypeStandard];
        }
    }];
    return build;
}

- (NSSet<NSString *> *)classReferences {
    return nil;
}

- (NSSet<NSString *> *)protocolReferences {
    return nil;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        __typeof(self) casted = (__typeof(casted))object;
        return (self.modifiers == casted.modifiers || [self.modifiers isEqualToArray:casted.modifiers]);
    }
    return NO;
}

- (NSString *)description {
    return [self stringForVariableName:nil];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {modifiers: '%@'}",
            [self class], self, [self modifiersString]];
}

@end
