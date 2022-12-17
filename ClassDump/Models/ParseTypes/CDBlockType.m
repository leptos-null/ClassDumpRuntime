//
//  CDBlockType.m
//  ClassDump
//
//  Created by Leptos on 12/15/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDBlockType.h"

@implementation CDBlockType

- (NSString *)stringForVariableName:(NSString *)varName {
    NSMutableString *build = [NSMutableString string];
    NSString *modifiersString = [self modifiersString];
    
    if (self.returnType != nil && self.parameterTypes != nil) {
        [build appendString:[self.returnType stringForVariableName:nil]];
        [build appendString:@" (^"];
        
        if (modifiersString.length > 0) {
            [build appendString:modifiersString];
        }
        if (modifiersString.length > 0 && varName != nil) {
            [build appendString:@" "];
        }
        if (varName != nil) {
            [build appendString:varName];
        }
        [build appendString:@")("];
        
        NSUInteger const paramCount = self.parameterTypes.count;
        if (paramCount == 0) {
            [build appendString:@"void"];
        } else {
            [self.parameterTypes enumerateObjectsUsingBlock:^(CDParseType *paramType, NSUInteger idx, BOOL *stop) {
                [build appendString:[paramType stringForVariableName:nil]];
                if ((idx + 1) < paramCount) {
                    [build appendString:@", "];
                }
            }];
        }
        [build appendString:@")"];
    } else {
        if (modifiersString.length > 0) {
            [build appendString:modifiersString];
            [build appendString:@" "];
        }
        
        [build appendString:@"id /* block */"];
        if (varName != nil) {
            [build appendString:@" "];
            [build appendString:varName];
        }
    }
    return [build copy];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        __typeof(self) casted = (__typeof(casted))object;
        return (self.modifiers == casted.modifiers || [self.modifiers isEqualToArray:casted.modifiers]) &&
        (self.returnType == casted.returnType || [self.returnType isEqual:casted.returnType]) &&
        (self.parameterTypes == casted.parameterTypes || [self.parameterTypes isEqualToArray:casted.parameterTypes]);
    }
    return NO;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {modifiers: '%@', returnType: %@, parameterTypes: %@}",
            [self class], self, [self modifiersString], self.returnType, self.parameterTypes];
}

@end
