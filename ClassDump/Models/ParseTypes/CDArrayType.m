//
//  CDArrayType.m
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDArrayType.h"

@implementation CDArrayType

- (NSString *)stringForVariableName:(NSString *)varName {
    NSMutableString *build = [NSMutableString string];
    NSString *modifiersString = [self modifiersString];
    if (modifiersString.length > 0) {
        [build appendString:modifiersString];
        [build appendString:@" "];
    }
    
    NSMutableArray<CDArrayType *> *arrayStack = [NSMutableArray array];
    
    CDParseType *headType = self;
    while ([headType isKindOfClass:[CDArrayType class]]) {
        CDArrayType *arrayType = (__kindof CDParseType *)headType;
        [arrayStack addObject:arrayType];
        headType = arrayType.type;
    }
    
    [build appendString:[headType stringForVariableName:varName]];
    
    [arrayStack enumerateObjectsUsingBlock:^(CDArrayType *arrayType, NSUInteger idx, BOOL *stop) {
        [build appendFormat:@"[%lu]", (unsigned long)arrayType.size];
    }];
    
    return [build copy];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {modifiers: '%@', type: %@, size: %lu}",
            [self class], self, [self modifiersString], self.type.debugDescription, (unsigned long)self.size];
}

@end
