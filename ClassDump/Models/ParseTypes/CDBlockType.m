//
//  CDBlockType.m
//  ClassDump
//
//  Created by Leptos on 12/15/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDBlockType.h"

@implementation CDBlockType

- (CDSemanticString *)semanticStringForVariableName:(NSString *)varName {
    CDSemanticString *build = [CDSemanticString new];
    CDSemanticString *modifiersString = [self modifiersSemanticString];
    
    if (self.returnType != nil && self.parameterTypes != nil) {
        [build appendSemanticString:[self.returnType semanticStringForVariableName:nil]];
        [build appendString:@" (^" semanticType:CDSemanticTypeStandard];
        
        if (modifiersString.length > 0) {
            [build appendSemanticString:modifiersString];
        }
        if (modifiersString.length > 0 && varName != nil) {
            [build appendString:@" " semanticType:CDSemanticTypeStandard];
        }
        if (varName != nil) {
            [build appendString:varName semanticType:CDSemanticTypeVariable];
        }
        [build appendString:@")(" semanticType:CDSemanticTypeStandard];
        
        NSUInteger const paramCount = self.parameterTypes.count;
        if (paramCount == 0) {
            [build appendString:@"void" semanticType:CDSemanticTypeKeyword];
        } else {
            [self.parameterTypes enumerateObjectsUsingBlock:^(CDParseType *paramType, NSUInteger idx, BOOL *stop) {
                [build appendSemanticString:[paramType semanticStringForVariableName:nil]];
                if ((idx + 1) < paramCount) {
                    [build appendString:@", " semanticType:CDSemanticTypeStandard];
                }
            }];
        }
        [build appendString:@")" semanticType:CDSemanticTypeStandard];
    } else {
        if (modifiersString.length > 0) {
            [build appendSemanticString:modifiersString];
            [build appendString:@" " semanticType:CDSemanticTypeStandard];
        }
        [build appendString:@"id" semanticType:CDSemanticTypeKeyword];
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
        [build appendString:@"/* block */" semanticType:CDSemanticTypeComment];
        if (varName != nil) {
            [build appendString:@" " semanticType:CDSemanticTypeStandard];
            [build appendString:varName semanticType:CDSemanticTypeVariable];
        }
    }
    return build;
}

- (NSSet<NSString *> *)classReferences {
    NSMutableSet<NSString *> *build = [NSMutableSet set];
    NSSet<NSString *> *returnReferences = [self.returnType classReferences];
    if (returnReferences != nil) {
        [build unionSet:returnReferences];
    }
    for (CDParseType *paramType in self.parameterTypes) {
        NSSet<NSString *> *paramReferences = [paramType classReferences];
        if (paramReferences != nil) {
            [build unionSet:paramReferences];
        }
    }
    return build;
}

- (NSSet<NSString *> *)protocolReferences {
    NSMutableSet<NSString *> *build = [NSMutableSet set];
    NSSet<NSString *> *returnReferences = [self.returnType protocolReferences];
    if (returnReferences != nil) {
        [build unionSet:returnReferences];
    }
    for (CDParseType *paramType in self.parameterTypes) {
        NSSet<NSString *> *paramReferences = [paramType protocolReferences];
        if (paramReferences != nil) {
            [build unionSet:paramReferences];
        }
    }
    return build;
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
