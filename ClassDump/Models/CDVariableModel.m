//
//  CDVariableModel.m
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDVariableModel.h"

@implementation CDVariableModel

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        __typeof(self) casted = (__typeof(casted))object;
        return (self.name == casted.name || [self.name isEqualToString:casted.name]) &&
        (self.type == casted.type || [self.type isEqual:casted.type]);
    }
    return NO;
}

- (NSString *)description {
    return [self.type stringForVariableName:self.name];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {name: '%@', type: %@}",
            [self class], self, self.name, self.type.debugDescription];
}

@end
