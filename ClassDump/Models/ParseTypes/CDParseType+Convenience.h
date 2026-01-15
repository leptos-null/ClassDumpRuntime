//
//  CDParseType+Convenience.h
//  ClassDump
//
//  Created by Leptos on 1/15/26.
//  Copyright © 2026 Leptos. All rights reserved.
//

#import <ClassDump/CDParseType.h>

@interface CDParseType (Convenience)
/// A string as this type would appear in code for a given variable name.
///
/// @param varName The name of the variable this type is for
- (nonnull NSString *)stringForVariableName:(nullable NSString *)varName;

- (nonnull CDSemanticString *)semanticStringForVariableName:(nullable NSString *)varName;

@end
