//
//  CDObjectType.m
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDObjectType.h"

@implementation CDObjectType

- (CDSemanticString *)semanticStringForVariableName:(NSString *)varName {
    CDSemanticString *build = [CDSemanticString new];
    CDSemanticString *modifiersString = [self modifiersSemanticString];
    if (modifiersString.length > 0) {
        [build appendSemanticString:modifiersString];
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
    }
    
    BOOL const hasClassName = (self.className != nil);
    
    if (hasClassName) {
        [build appendString:self.className semanticType:CDSemanticTypeClass];
    } else {
        [build appendString:@"id" semanticType:CDSemanticTypeKeyword];
    }
    
    NSArray<NSString *> *protocolNames = self.protocolNames;
    NSUInteger const protocolNameCount = protocolNames.count;
    if (protocolNames.count > 0) {
        [build appendString:@"<" semanticType:CDSemanticTypeStandard];
        [protocolNames enumerateObjectsUsingBlock:^(NSString *protocolName, NSUInteger idx, BOOL *stop) {
            [build appendString:protocolName semanticType:CDSemanticTypeProtocol];
            if ((idx + 1) < protocolNameCount) {
                [build appendString:@", " semanticType:CDSemanticTypeStandard];
            }
        }];
        [build appendString:@">" semanticType:CDSemanticTypeStandard];
    }
    if (hasClassName) {
        [build appendString:@" *" semanticType:CDSemanticTypeStandard];
    }
    
    if (varName != nil) {
        if (!hasClassName) {
            [build appendString:@" " semanticType:CDSemanticTypeStandard];
        }
        [build appendString:varName semanticType:CDSemanticTypeVariable];
    }
    return build;
}

- (NSSet<NSString *> *)classReferences {
    NSString *className = self.className;
    if (className != nil) {
        return [NSSet setWithObject:className];
    }
    return nil;
}

- (NSSet<NSString *> *)protocolReferences {
    NSArray<NSString *> *protocolNames = self.protocolNames;
    if (protocolNames != nil) {
        return [NSSet setWithArray:protocolNames];
    }
    return nil;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        __typeof(self) casted = (__typeof(casted))object;
        return (self.modifiers == casted.modifiers || [self.modifiers isEqualToArray:casted.modifiers]) &&
        (self.className == casted.className || [self.className isEqualToString:casted.className]) &&
        (self.protocolNames == casted.protocolNames || [self.protocolNames isEqualToArray:casted.protocolNames]);
    }
    return NO;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {modifiers: '%@', className: '%@', protocolNames: %@}",
            [self class], self, [self modifiersString], self.className, self.protocolNames];
}

@end
