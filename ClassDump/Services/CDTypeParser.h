//
//  CDTypeParser.h
//  ClassDump
//
//  Created by Leptos on 3/24/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDTypeParser : NSObject

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
