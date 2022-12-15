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

- (NSString *)stringForVariableName:(NSString *)varName {
    NSMutableString *build = [NSMutableString string];
    NSString *modifiersString = [self modifiersString];
    if (modifiersString.length > 0) {
        [build appendString:modifiersString];
        [build appendString:@" "];
    }
    [build appendString:[self.pointee stringForVariableName:nil]];
    if ([build characterAtIndex:(build.length - 1)] != '*') {
        [build appendString:@" "];
    }
    [build appendString:@"*"];
    if (varName != nil) {
        [build appendString:varName];
    }
    return [build copy];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        __typeof(self) casted = (__typeof(casted))object;
        return (self.modifiers == casted.modifiers || [self.modifiers isEqualToArray:casted.modifiers]) &&
        (self.pointee == casted.pointee || [self.pointee isEqual:casted.pointee]);
    }
    return NO;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {modifiers: '%@', pointee: %@}",
            [self class], self, [self modifiersString], self.pointee.debugDescription];
}

@end
