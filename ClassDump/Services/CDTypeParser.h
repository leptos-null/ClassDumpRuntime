//
//  CDTypeParser.h
//  ClassDump
//
//  Created by Leptos on 3/24/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CDParseType.h"

@interface CDTypeParser : NSObject

/// Find the end of an Objective-C type encoding
/// @param encoding An Objective-C type encoding
/// @returns A pointer to the first character that is not part of the type encoding.
/// If @c encoding is not a type encoding, @c encoding will be returned.
+ (const char *)endOfTypeEncoding:(const char *)encoding;
/// Get an object representing the type encoded in @c encoding
/// @param encoding A null-terminated C-string as returned by @c \@encode
+ (CDParseType *)typeForEncoding:(const char *)encoding;
/// Get an object representing the type encoded
/// @param start A pointer to the start of an encoded value as returned by @c \@encode
/// @param end A pointer to the first byte out-of-bounds from @c start
/// @param error Set to @c YES if an error occurs during proccessing
+ (CDParseType *)typeForEncodingStart:(const char *const)start end:(const char *const)end error:(inout BOOL *)error;

/// @brief A variable declaration that is able to be compiled
/// @param encoding A null-terminated C-string as returned by @c encode
/// @param varName The variable name that should be placed in the line,
///   for example, in @c char @c varName[8] the variable name may appear in the middle of the line.
+ (NSString *)stringForEncoding:(const char *)encoding variable:(NSString *)varName;
/// @brief A variable declaration that is able to be compiled
/// @param start A pointer to the start of an encoded value as returned by @c encode
/// @param end A pointer to the first byte out-of-bounds from @c start
/// @param varName The variable name that should be placed in the line,
///   for example in @c char @c varName[8] the variable name may appear in the middle of the line.
/// @param error Set to true if an error occurs during proccessing
+ (NSString *)stringForEncodingStart:(const char *)start end:(const char *)end variable:(NSString *)varName
                               error:(inout BOOL *)error;

@end
