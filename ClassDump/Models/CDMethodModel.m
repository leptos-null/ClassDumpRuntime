//
//  CDMethodModel.m
//  ClassDump
//
//  Created by Leptos on 4/7/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "CDMethodModel.h"
#import "../Services/CDTypeParser.h"

// these functions were copied from objc4/runtime/objc-typeencoding.mm
//   and modified slightly to fix a bug in SkipFirstType

/*
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */

/// Find the end of a type encoding
static const char *seekOverType(const char *type) {
    while (*type) {
        switch (*type) {
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                /* don't modify, this isn't actually a type */
                return type;
                
            /* prefix modifiers */
            case '^':
            case 'r':
            case 'n':
            case 'N':
            case 'o':
            case 'O':
            case 'R':
            case 'V':
            case 'A':
            case 'j':
                type++;
                break;
                
            case '@': {
                type++;
                if (*type == '"') {
                    type++;
                    while (*type != '"') {
                        type++;
                    }
                    type++;
                } else if (*type == '?') {
                    type++;
                }
                return type;
            } break;
                
            case 'b': { // not really possible to have a bit field as a return type, but just in case
                type++;
                while (isnumber(*type)) {
                    type++;
                }
                return type;
            } break;
                
            case '[': {
                unsigned openTokens = 1;
                while (openTokens) {
                    switch (*++type) {
                        case '[':
                            openTokens++;
                            break;
                        case ']':
                            openTokens--;
                            break;
                    }
                }
                type++;
                return type;
            } break;
                
            case '{': {
                unsigned openTokens = 1;
                while (openTokens) {
                    switch (*++type) {
                        case '{':
                            openTokens++;
                            break;
                        case '}':
                            openTokens--;
                            break;
                    }
                }
                type++;
                return type;
            } break;
                
            case '(': {
                unsigned openTokens = 1;
                while (openTokens) {
                    switch (*++type) {
                        case '(':
                            openTokens++;
                            break;
                        case ')':
                            openTokens--;
                            break;
                    }
                }
                type++;
                return type;
            } break;
                
            default:
                type++;
                return type;
        }
    }
    return type;
}

/// Returns the number of times a character occurs in a null-terminated stringb
static size_t characterCount(const char *str, const char c) {
    size_t ret = 0;
    while (*str) {
        if (*str++ == c) {
            ret++;
        }
    }
    return ret;
}

@implementation CDMethodModel

+ (instancetype)modelWithMethod:(struct objc_method_description)methd isClass:(BOOL)isClass {
    return [[self alloc] initWithMethod:methd isClass:isClass];
}

- (instancetype)initWithMethod:(struct objc_method_description)methd isClass:(BOOL)isClass {
    if (self = [self init]) {
        _backing = methd;
        _isClass = isClass;
        _name = NSStringFromSelector(methd.name);
        
        const char *typedesc = methd.types;
        /* this code is heavily modified from, but based on encoding_getArgumentInfo */
        const char *type = typedesc;
        typedesc = seekOverType(typedesc);
        _returnType = [CDTypeParser stringForEncodingStart:type end:typedesc variable:nil error:NULL];
        
        NSUInteger const expectedArguments = characterCount(sel_getName(methd.name), ':');
        NSMutableArray<NSString *> *arguments = [NSMutableArray arrayWithCapacity:expectedArguments + 2];
        
        // skip stack size
        while (isnumber(*typedesc)) {
            typedesc++;
        }
        
        while (*typedesc) {
            type = typedesc;
            typedesc = seekOverType(type);
            [arguments addObject:[CDTypeParser stringForEncodingStart:type end:typedesc variable:nil error:NULL]];
            
            // Skip GNU runtime's register parameter hint
            if (*typedesc == '+') {
                typedesc++;
            }
            // Skip negative sign in offset
            if (*typedesc == '-') {
                typedesc++;
            }
            while (isnumber(*typedesc)) {
                typedesc++;
            }
        }
        
        _argumentTypes = [arguments subarrayWithRange:NSMakeRange(arguments.count - expectedArguments, expectedArguments)];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        __typeof(self) casted = (__typeof(casted))object;
        return [self.name isEqual:casted.name] &&
        [self.argumentTypes isEqual:casted.argumentTypes] &&
        [self.returnType isEqual:casted.returnType];
    }
    return NO;
}

- (NSString *)description {
    NSMutableString *ret = [NSMutableString string];
    if (self.isClass) {
        [ret appendString:@"+"];
    } else {
        [ret appendString:@"-"];
    }
    [ret appendFormat:@" (%@)", self.returnType];
    if (self.argumentTypes.count) {
        NSArray<NSString *> *brokenupName = [self.name componentsSeparatedByString:@":"];
        [self.argumentTypes enumerateObjectsUsingBlock:^(NSString *argumentType, NSUInteger idx, BOOL *stop) {
            [ret appendFormat:@"%@:(%@)a%@ ", brokenupName[idx], argumentType, @(idx).stringValue];
        }];
        // remove the last space
        [ret deleteCharactersInRange:NSMakeRange(ret.length - 1, 1)];
    } else {
        [ret appendString:self.name];
    }
    return ret;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {signature: '%@', argumentTypes: %@, "
            "returnType: '%@', isClass: %@}",
            [self class], self, self.name, self.argumentTypes,
            self.returnType, self.isClass ? @"YES" : @"NO"];
}

@end
