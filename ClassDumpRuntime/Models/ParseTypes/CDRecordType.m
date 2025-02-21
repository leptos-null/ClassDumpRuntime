//
//  CDRecordType.m
//  ClassDumpRuntime
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDRecordType.h"

@implementation CDRecordType

- (CDSemanticString *)semanticStringForVariableName:(NSString *)varName {
    CDSemanticString *build = [CDSemanticString new];
    CDSemanticString *modifiersString = [self modifiersSemanticString];
    if (modifiersString.length > 0) {
        [build appendSemanticString:modifiersString];
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
    }
    [build appendString:(self.isUnion ? @"union" : @"struct") semanticType:CDSemanticTypeKeyword];
    if (self.name != nil) {
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
        [build appendString:self.name semanticType:CDSemanticTypeRecordName];
    }
    if (self.fields != nil) {
        [build appendString:@" { " semanticType:CDSemanticTypeStandard];
        
        unsigned fieldName = 0;
        if (self.isExpand) {
            [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
        }
        for (CDVariableModel *variableModel in self.fields) {
            if (self.isExpand) {
                [build appendString:@"    " semanticType:CDSemanticTypeStandard];
                for (NSInteger i = 0; i < self.indentLevel; i++) {
                    [build appendString:@"    " semanticType:CDSemanticTypeStandard];
                }
            }
            NSString *variableName = variableModel.name;
            if (variableName == nil) {
                variableName = [NSString stringWithFormat:@"x%u", fieldName++];
            }
            [build appendSemanticString:[variableModel.type semanticStringForVariableName:variableName]];
            [build appendString:@"; " semanticType:CDSemanticTypeStandard];
            if (self.isExpand) {
                [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
            }
        }
        for (NSInteger i = 0; i < self.indentLevel; i++) {
            [build appendString:@"    " semanticType:CDSemanticTypeStandard];
        }
        [build appendString:@"}" semanticType:CDSemanticTypeStandard];
    }
    if (varName != nil) {
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
        [build appendString:varName semanticType:CDSemanticTypeVariable];
    }
    return build;
}

- (NSSet<NSString *> *)classReferences {
    NSMutableSet<NSString *> *build = [NSMutableSet set];
    for (CDVariableModel *variableModel in self.fields) {
        NSSet<NSString *> *paramReferences = [variableModel.type classReferences];
        if (paramReferences != nil) {
            [build unionSet:paramReferences];
        }
    }
    return build;
}

- (NSSet<NSString *> *)protocolReferences {
    NSMutableSet<NSString *> *build = [NSMutableSet set];
    for (CDVariableModel *variableModel in self.fields) {
        NSSet<NSString *> *paramReferences = [variableModel.type protocolReferences];
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
        (self.name == casted.name || [self.name isEqualToString:casted.name]) &&
        self.isUnion == casted.isUnion &&
        (self.fields == casted.fields || [self.fields isEqualToArray:casted.fields]);
    }
    return NO;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {modifiers: '%@', name: '%@', isUnion: %@, fields: %@}",
            [self class], self, [self modifiersString], self.name, self.isUnion ? @"YES" : @"NO", self.fields.debugDescription];
}

- (void)setExpand:(BOOL)expand {
    _expand = expand;
    
    if (self.fields) {
        for (CDVariableModel *variableModel in self.fields) {
            if ([variableModel.type isKindOfClass:[CDRecordType class]]) {
                CDRecordType *recordType = (CDRecordType *)variableModel.type;
                recordType.indentLevel = self.indentLevel + 1;
                recordType.expand = expand;
            }
        }
    }
}

@end
