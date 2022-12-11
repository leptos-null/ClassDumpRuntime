//
//  CDBitFieldType.m
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDBitFieldType.h"

@implementation CDBitFieldType

- (NSString *)stringForVariableName:(NSString *)varName {
    NSMutableString *build = [NSMutableString string];
    NSString *modifiersString = [self modifiersString];
    if (modifiersString.length > 0) {
        [build appendString:modifiersString];
        [build appendString:@" "];
    }
    
    NSUInteger const bitWidth = self.width;
    
    NSString *type = nil;
#ifndef __CHAR_BIT__
#   error __CHAR_BIT__ must be defined
#endif
    /* all bitwidth base-types are unsigned, because that's the typical use case */
    if (bitWidth <= __CHAR_BIT__) {
        type = @"unsigned char";
    }
#ifdef __SIZEOF_SHORT__
    else if (bitWidth <= (__SIZEOF_SHORT__ * __CHAR_BIT__)) {
        type = @"unsigned short";
    }
#endif
#ifdef __SIZEOF_INT__
    else if (bitWidth <= (__SIZEOF_INT__ * __CHAR_BIT__)) {
        type = @"unsigned int";
    }
#endif
#ifdef __SIZEOF_LONG__
    else if (bitWidth <= (__SIZEOF_LONG__ * __CHAR_BIT__)) {
        type = @"unsigned long";
    }
#endif
#ifdef __SIZEOF_LONG_LONG__
    else if (bitWidth <= (__SIZEOF_LONG_LONG__ * __CHAR_BIT__)) {
        type = @"unsigned long long";
    }
#endif
#ifdef __SIZEOF_INT128__
    else if (bitWidth <= (__SIZEOF_INT128__ * __CHAR_BIT__)) {
        type = @"unsigned __int128";
    }
#endif
    else {
        NSAssert(NO, @"width of bit-field exceeds width of any known type");
        type = @"unsigned";
    }
    
    [build appendString:type];
    
    if (varName != nil) {
        [build appendString:@" "];
        [build appendString:varName];
    }
    
    [build appendFormat:@" : %lu", (unsigned long)self.width];
    return [build copy];
}

@end
