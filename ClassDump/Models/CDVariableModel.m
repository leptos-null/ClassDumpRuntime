//
//  CDVariableModel.m
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDVariableModel.h"

@implementation CDVariableModel

- (NSString *)description {
    return [self.type stringForVariableName:self.name];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {name: '%@', type: %@}",
            [self class], self, self.name, self.type.debugDescription];
}

@end
