//
//  CDObjectType.m
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDObjectType.h"

@implementation CDObjectType

- (NSString *)stringForVariableName:(NSString *)varName {
    NSMutableString *build = [NSMutableString string];
    NSString *modifiersString = [self modifiersString];
    if (modifiersString.length > 0) {
        [build appendString:modifiersString];
        [build appendString:@" "];
    }
    
    BOOL const hasClassName = (self.className != nil);
    
    if (hasClassName) {
        [build appendString:self.className];
    } else {
        [build appendString:@"id"];
    }
    
    NSArray<NSString *> *protocolNames = self.protocolNames;
    if (protocolNames.count > 0) {
        [build appendString:@"<"];
        [build appendString:[protocolNames componentsJoinedByString:@", "]];
        [build appendString:@">"];
    }
    if (hasClassName) {
        [build appendString:@" *"];
    }
    
    if (varName != nil) {
        if (!hasClassName) {
            [build appendString:@" "];
        }
        [build appendString:varName];
    }
    return [build copy];
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
