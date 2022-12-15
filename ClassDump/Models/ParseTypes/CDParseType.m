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
    NSAssert(NO, @"Subclasses must implement stringForVariableName");
    return @"";
}

- (NSString *)modifiersString {
    NSArray<NSNumber *> *const modifiers = self.modifiers;
    NSMutableArray<NSString *> *strings = [NSMutableArray arrayWithCapacity:modifiers.count];
    [modifiers enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
        strings[idx] = NSStringFromCDTypeModifier(value.unsignedIntegerValue);
    }];
    return [strings componentsJoinedByString:@" "];
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
