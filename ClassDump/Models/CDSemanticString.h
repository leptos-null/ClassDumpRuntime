//
//  CDSemanticString.h
//  ClassDump
//
//  Created by Leptos on 1/1/23.
//  Copyright © 2023 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

/// The semantic types that a string may represent in an Objective-C header file
typedef NS_ENUM(NSUInteger, CDSemanticType) {
    // whitespace, colons (':'), semicolons (';'), pointers ('*'),
    // braces ('(', ')'), brackets ('{','}', '[', ']', '<', '>')
    CDSemanticTypeStandard,
    // characters used to start and end a comment, and the contents of the comment
    CDSemanticTypeComment,
    // struct, union, type modifiers, language provided primitive types
    CDSemanticTypeKeyword,
    // the name of a variable- this includes both declartion and usage sites
    CDSemanticTypeVariable,
    // a type that is declared by a header (e.g. NSString)
    CDSemanticTypeDeclared,
    // a number literal (e.g. 2, 18, 1e5, 7.1)
    CDSemanticTypeNumeric,
    
    /// The number of valid cases there are in @c CDSemanticType
    CDSemanticTypeCount
};

/// A string composed of substrings that may have different semantic meanings
@interface CDSemanticString : NSObject
/// The length of the string
@property (readonly) NSUInteger length;
/// Append another semantic string to the end of this string,
/// keeping all of the semantics of both the parameter and receiver
- (void)appendSemanticString:(CDSemanticString *)semanticString;
/// Append a string with a semantic type to the end of this string
- (void)appendString:(NSString *)string semanticType:(CDSemanticType)type;
/// Whether the last character in this string is equal to @c character
- (BOOL)endWithChar:(char)character;
/// Enumerate the substrings and the associated semantic type that compose this string
- (void)enumerateTypesUsingBlock:(void (NS_NOESCAPE ^)(NSString *string, CDSemanticType type))block;
/// The string representation without semantics
- (NSString *)string;

@end
