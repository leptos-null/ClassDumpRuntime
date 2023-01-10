//
//  CDArrayType.m
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDArrayType.h"

@implementation CDArrayType

- (CDSemanticString *)semanticStringForVariableName:(NSString *)varName {
    CDSemanticString *build = [CDSemanticString new];
    CDSemanticString *modifiersString = [self modifiersSemanticString];
    if (modifiersString.length > 0) {
        [build appendSemanticString:modifiersString];
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
    }
    
    NSMutableArray<CDArrayType *> *arrayStack = [NSMutableArray array];
    
    CDParseType *headType = self;
    while ([headType isKindOfClass:[CDArrayType class]]) {
        CDArrayType *arrayType = (__kindof CDParseType *)headType;
        [arrayStack addObject:arrayType];
        headType = arrayType.type;
    }
    
    [build appendSemanticString:[headType semanticStringForVariableName:varName]];
    
    [arrayStack enumerateObjectsUsingBlock:^(CDArrayType *arrayType, NSUInteger idx, BOOL *stop) {
        [build appendString:@"[" semanticType:CDSemanticTypeStandard];
        [build appendString:[NSString stringWithFormat:@"%lu", (unsigned long)arrayType.size] semanticType:CDSemanticTypeNumeric];
        [build appendString:@"]" semanticType:CDSemanticTypeStandard];
    }];
    
    return build;
}

- (NSSet<NSString *> *)classReferences {
    return [self.type classReferences];
}

- (NSSet<NSString *> *)protocolReferences {
    return [self.type protocolReferences];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        __typeof(self) casted = (__typeof(casted))object;
        return (self.modifiers == casted.modifiers || [self.modifiers isEqualToArray:casted.modifiers]) &&
        (self.type == casted.type || [self.type isEqual:casted.type]) &&
        (self.size == casted.size);
    }
    return NO;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {modifiers: '%@', type: %@, size: %lu}",
            [self class], self, [self modifiersString], self.type.debugDescription, (unsigned long)self.size];
}

@end
