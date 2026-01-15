//
//  CDParseType+Convenience.m
//  ClassDump
//
//  Created by Leptos on 1/15/26.
//  Copyright © 2026 Leptos. All rights reserved.
//

#import "CDParseType+Convenience.h"

@implementation CDParseType (Convenience)

- (NSString *)stringForVariableName:(NSString *)varName {
    return [[self semanticStringForVariableName:varName] string];
}

- (CDSemanticString *)semanticStringForVariableName:(NSString *)varName {
    return [self semanticStringForVariableName:varName indentationLevel:0 formatOptions:nil];
}

@end
