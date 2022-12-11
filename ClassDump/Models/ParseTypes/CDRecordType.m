//
//  CDRecordType.m
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDRecordType.h"

@implementation CDRecordType

- (NSString *)stringForVariableName:(NSString *)varName {
    NSMutableString *build = [NSMutableString string];
    NSString *modifiersString = [self modifiersString];
    if (modifiersString.length > 0) {
        [build appendString:modifiersString];
        [build appendString:@" "];
    }
    [build appendString:(self.isUnion ? @"union" : @"struct")];
    if (self.name != nil) {
        [build appendString:@" "];
        [build appendString:self.name];
    }
    if (self.fields != nil) {
        [build appendString:@" { "];
        
        unsigned fieldName = 0;
        
        for (CDVariableModel *variableModel in self.fields) {
            NSString *variableName = variableModel.name;
            if (variableName == nil) {
                variableName = [NSString stringWithFormat:@"x%u", fieldName++];
            }
            [build appendString:[variableModel.type stringForVariableName:variableName]];
            [build appendString:@"; "];
        }
        [build appendString:@"}"];
    }
    if (varName != nil) {
        [build appendString:@" "];
        [build appendString:varName];
    }
    return [build copy];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {modifiers: '%@', name: '%@', isUnion: %@, fields: %@}",
            [self class], self, [self modifiersString], self.name, self.isUnion ? @"YES" : @"NO", self.fields.debugDescription];
}

@end
