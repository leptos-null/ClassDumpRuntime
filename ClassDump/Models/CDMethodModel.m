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

static const char *skipFirstType(const char *type) {
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
                /* don't modify */
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

static unsigned int encoding_getNumberOfArguments(const char *typedesc) {
    // First, skip the return type
    typedesc = skipFirstType(typedesc);
    
    // Next, skip stack size
    while (isnumber(*typedesc)) {
        typedesc++;
    }
    // Now, we have the arguments - count how many
    unsigned nargs = 0;
    while (*typedesc) {
        // Traverse argument type
        typedesc = skipFirstType(typedesc);
        
        // Skip GNU runtime's register parameter hint
        if (*typedesc == '+') {
            typedesc++;
        }
        // Traverse (possibly negative) argument offset
        if (*typedesc == '-') {
            typedesc++;
        }
        
        while (isnumber(*typedesc)) {
            typedesc++;
        }
        // Made it past an argument
        nargs++;
    }
    
    return nargs;
}

static unsigned int encoding_getArgumentInfo(const char *typedesc, unsigned int arg, const char **type, int *offset) {
    unsigned nargs = 0;
    int self_offset = 0;
    bool offset_is_negative = NO;
    
    // First, skip the return type
    typedesc = skipFirstType(typedesc);
    
    // Next, skip stack size
    while (isnumber(*typedesc)) {
        typedesc++;
    }
    
    // Now, we have the arguments - position typedesc to the appropriate argument
    while (*typedesc && nargs != arg) {
        
        // Skip argument type
        typedesc = skipFirstType(typedesc);
        
        if (nargs == 0) {
            // Skip GNU runtime's register parameter hint
            if (*typedesc == '+') {
                typedesc++;
            }
            // Skip negative sign in offset
            if (*typedesc == '-') {
                offset_is_negative = YES;
                typedesc++;
            } else {
                offset_is_negative = NO;
            }
            
            while (isnumber(*typedesc)) {
                self_offset = self_offset * 10 + (*typedesc++ - '0');
            }
            if (offset_is_negative) {
                self_offset = -(self_offset);
            }
        } else {
            // Skip GNU runtime's register parameter hint
            if (*typedesc == '+') {
                typedesc++;
            }
            // Skip (possibly negative) argument offset
            if (*typedesc == '-')
                typedesc += 1;
            while ((*typedesc >= '0') && (*typedesc <= '9'))
                typedesc += 1;
        }
        
        nargs += 1;
    }
    
    if (*typedesc) {
        int arg_offset = 0;
        
        *type = typedesc;
        typedesc = skipFirstType(typedesc);
        
        if (arg == 0) {
            *offset = 0;
        } else {
            // Skip GNU register parameter hint
            if (*typedesc == '+') {
                typedesc++;
            }
            
            // Pick up (possibly negative) argument offset
            if (*typedesc == '-') {
                offset_is_negative = YES;
                typedesc++;
            } else {
                offset_is_negative = NO;
            }
            
            while (isnumber(*typedesc)) {
                arg_offset = arg_offset * 10 + (*typedesc++ - '0');
            }
            if (offset_is_negative) {
                arg_offset = -(arg_offset);
            }
            *offset = arg_offset - self_offset;
        }
        
    } else {
        *type = 0;
        *offset = 0;
    }
    
    return nargs;
}

/// Returns the method's return type string on the heap.
static char *encoding_copyReturnType(const char *t) {
    size_t len;
    const char *end;
    char *result;
    
    if (!t) {
        return NULL;
    }
    
    end = skipFirstType(t);
    len = end - t;
    result = malloc(len + 1);
    strncpy(result, t, len);
    result[len] = '\0';
    return result;
}

/// Returns a single argument's type string on the heap. Argument 0 is `self`; argument 1 is typically `_cmd`.
static char *encoding_copyArgumentType(const char *t, unsigned int index) {
    size_t len;
    const char *end;
    char *result;
    int offset;
    
    if (!t) {
        return NULL;
    }
    
    encoding_getArgumentInfo(t, index, &t, &offset);
    
    if (!t) {
        return NULL;
    }
    
    end = skipFirstType(t);
    len = end - t;
    result = malloc(len + 1);
    strncpy(result, t, len);
    result[len] = '\0';
    return result;
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
        
        char *returnType = encoding_copyReturnType(methd.types);
        _returnType = [CDTypeParser stringForEncoding:returnType variable:nil];
        free(returnType);
        returnType = NULL;
        
        NSArray<NSString *> *brokenupName = [self.name componentsSeparatedByString:@":"];
        unsigned int visibleArgs = (__typeof(visibleArgs))brokenupName.count - 1;
        
        unsigned int meth_argCount = encoding_getNumberOfArguments(methd.types);
        // in the event that SEL _cmd is missing:
        //  method:name:
        //   0: self
        //   1: arg1
        //   2: arg2
        //  visibleArgs = 2
        //  meth_argCount = 3
        unsigned int argOffset = (meth_argCount - visibleArgs);
        if (argOffset > INT_MAX) {
            // bad encoding, most likely a bad encoding. just skip for now
        } else {
            NSMutableArray<NSString *> *visibleArgTypes = [NSMutableArray arrayWithCapacity:visibleArgs];
            for (unsigned int argIndex = 0; argIndex < visibleArgs; argIndex++) {
                char *meth_argType = encoding_copyArgumentType(methd.types, argIndex + argOffset);
                [visibleArgTypes addObject:[CDTypeParser stringForEncoding:meth_argType variable:nil]];
                free(meth_argType);
            }
            _argumentTypes = [visibleArgTypes copy];
        }
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:self.class]) {
        __typeof(self) casted = (__typeof(casted))object;
        return [self.name isEqual:casted.name] && [self.argumentTypes isEqual:casted.argumentTypes] && [self.returnType isEqual:casted.returnType];
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

@end
