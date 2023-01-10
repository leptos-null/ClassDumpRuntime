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

- (CDSemanticString *)semanticStringForVariableName:(NSString *)varName {
    CDSemanticString *build = [CDSemanticString new];
    CDSemanticString *modifiersString = [self modifiersSemanticString];
    if (modifiersString.length > 0) {
        [build appendSemanticString:modifiersString];
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
    }
    [build appendSemanticString:[self.pointee semanticStringForVariableName:nil]];
    if (![build endWithChar:'*']) {
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
    }
    [build appendString:@"*" semanticType:CDSemanticTypeStandard];
    if (varName != nil) {
        [build appendString:varName semanticType:CDSemanticTypeVariable];
    }
    return build;
}

- (NSSet<NSString *> *)classReferences {
    return [self.pointee classReferences];
}

- (NSSet<NSString *> *)protocolReferences {
    return [self.pointee protocolReferences];
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
