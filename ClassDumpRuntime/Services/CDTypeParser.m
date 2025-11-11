//
//  CDTypeParser.m
//  ClassDumpRuntime
//
//  Created by Leptos on 3/24/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "CDTypeParser.h"

#import "../Models/ParseTypes/CDPrimitiveType.h"
#import "../Models/ParseTypes/CDObjectType.h"
#import "../Models/ParseTypes/CDBlockType.h"
#import "../Models/ParseTypes/CDRecordType.h"
#import "../Models/ParseTypes/CDPointerType.h"
#import "../Models/ParseTypes/CDArrayType.h"
#import "../Models/ParseTypes/CDBitFieldType.h"

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

@implementation CDTypeParser

// References:
// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
// https://gcc.gnu.org/onlinedocs/gcc-4.8.2/gcc/Type-encoding.html

// originally based off of `SkipFirstType`
// https://github.com/apple-oss-distributions/objc4/blob/689525d556/runtime/objc-typeencoding.mm#L64-L105
+ (const char *)endOfTypeEncoding:(const char *)encoding {
    while (*encoding) {
        switch (*encoding) {
                /* known primitive types */
            case '*':
            case 'c':
            case 'i':
            case 's':
            case 'l':
            case 'q':
            case 't':
            case 'C':
            case 'I':
            case 'S':
            case 'L':
            case 'Q':
            case 'T':
            case ' ':
            case 'f':
            case 'd':
            case 'D':
            case 'B':
            case 'v':
            case '#':
            case ':':
            case '?':
                // once we see an underlying type, there's nothing else in the encoding
                encoding++;
                return encoding;
                
                /* type modifiers */
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
                encoding++;
                break;
                
            case '@': {
                encoding++;
                if (*encoding == '"') {
                    encoding++;
                    while (*encoding != '"') {
                        encoding++;
                    }
                    encoding++;
                } else if (*encoding == '?') {
                    encoding++;
                    if (*encoding == '<') {
                        unsigned openTokens = 1;
                        while (openTokens) {
                            switch (*++encoding) {
                                case '<':
                                    openTokens++;
                                    break;
                                case '>':
                                    openTokens--;
                                    break;
                            }
                        }
                        encoding++;
                    }
                }
                return encoding;
            } break;
                
            case 'b': {
                encoding++;
                while (isnumber(*encoding)) {
                    encoding++;
                }
                return encoding;
            } break;
                
            case '[': {
                unsigned openTokens = 1;
                while (openTokens) {
                    switch (*++encoding) {
                        case '[':
                            openTokens++;
                            break;
                        case ']':
                            openTokens--;
                            break;
                    }
                }
                encoding++;
                return encoding;
            } break;
                
            case '{': {
                unsigned openTokens = 1;
                while (openTokens) {
                    switch (*++encoding) {
                        case '{':
                            openTokens++;
                            break;
                        case '}':
                            openTokens--;
                            break;
                    }
                }
                encoding++;
                return encoding;
            } break;
                
            case '(': {
                unsigned openTokens = 1;
                while (openTokens) {
                    switch (*++encoding) {
                        case '(':
                            openTokens++;
                            break;
                        case ')':
                            openTokens--;
                            break;
                    }
                }
                encoding++;
                return encoding;
            } break;
                
            default:
                // don't modify, this isn't actually a type
                return encoding;
        }
    }
    return encoding;
}

+ (CDParseType *)typeForEncoding:(const char *)encoding {
    return [self typeForEncodingStart:encoding end:encoding + strlen(encoding) error:NULL];
}

+ (CDParseType *)typeForEncodingStart:(const char *const)start end:(const char *const)end error:(inout BOOL *)error {
    __kindof CDParseType *type = nil;
    NSMutableArray<NSNumber *> *modifiers = [NSMutableArray array];
    
    // clang encoding:
    //   https://github.com/llvm/llvm-project/blob/1ce8e3543b/clang/lib/AST/ASTContext.cpp#L8202
    // gcc encoding:
    //   https://github.com/gcc-mirror/gcc/blob/c6b12b802c/gcc/objc/objc-encoding.cc
    
    for (const char *chr = start; chr < end; chr++) {
        switch (*chr) {
            case '^': {
                chr++;
                
                CDParseType *pointee = nil;
                if (chr == end) {
                    pointee = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeVoid];
                } else {
                    BOOL pointeeError = NO;
                    pointee = [self typeForEncodingStart:chr end:end error:&pointeeError];
                    chr = end; // we've consumed the rest of the token
                    
                    if (pointeeError) {
                        if (error) {
                            *error = pointeeError;
                        }
                        return nil;
                    }
                }
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPointerType pointerToPointee:pointee];
            } break;
            case '*': {
                CDParseType *pointee = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeChar];
                
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPointerType pointerToPointee:pointee];
            } break;
            case 'c':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeChar];
                break;
            case 'i':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeInt];
                break;
            case 's':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeShort];
                break;
            case 'l':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeLong];
                break;
            case 'q':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeLongLong];
                break;
            case 't':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeInt128];
                break;
            case 'C':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeUnsignedChar];
                break;
            case 'I':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeUnsignedInt];
                break;
            case 'S':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeUnsignedShort];
                break;
            case 'L':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeUnsignedLong];
                break;
            case 'Q':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeUnsignedLongLong];
                break;
            case 'T':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeUnsignedInt128];
                break;
            case ' ':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeBlank];
                break;
            case 'f':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeFloat];
                break;
            case 'd':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeDouble];
                break;
            case 'D':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeLongDouble];
                break;
            case 'B':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeBool];
                break;
            case 'v':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeVoid];
                break;
            case '#':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeClass];
                break;
            case ':':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeSel];
                break;
            case 'r':
                [modifiers addObject:@(CDTypeModifierConst)];
                break;
            case 'n':
                [modifiers addObject:@(CDTypeModifierIn)];
                break;
            case 'N':
                [modifiers addObject:@(CDTypeModifierInOut)];
                break;
            case 'o':
                [modifiers addObject:@(CDTypeModifierOut)];
                break;
            case 'O':
                [modifiers addObject:@(CDTypeModifierBycopy)];
                break;
            case 'R':
                [modifiers addObject:@(CDTypeModifierByref)];
                break;
            case 'V':
                [modifiers addObject:@(CDTypeModifierOneway)];
                break;
            case 'A':
                [modifiers addObject:@(CDTypeModifierAtomic)];
                break;
            case 'j':
                [modifiers addObject:@(CDTypeModifierComplex)];
                break;
            case '@': {
                if (chr[1] == '"') {
                    CDObjectType *objType = [CDObjectType new];
                    
                    chr += 2;
                    const char *const chrcpy = chr;
                    const char *protocolHead = NULL;
                    while (*chr != '"') {
                        if (*chr == '<' && !protocolHead) {
                            protocolHead = chr;
                        }
                        chr++;
                    }
                    
                    if (!protocolHead) {
                        objType.className = [[NSString alloc] initWithBytes:chrcpy length:(chr - chrcpy) encoding:NSUTF8StringEncoding];
                    } else {
                        ptrdiff_t const baseTypeLength = (protocolHead - chrcpy);
                        
                        if (baseTypeLength) {
                            objType.className = [[NSString alloc] initWithBytes:chrcpy length:baseTypeLength encoding:NSUTF8StringEncoding];
                        }
                        
                        NSMutableArray *protocolNames = [NSMutableArray array];
                        const char *protocolSearch = protocolHead;
                        while (chr > protocolSearch) {
                            while (*protocolSearch != '>') {
                                protocolSearch++;
                            }
                            protocolHead++; // skip the leading '<'
                            NSString *protocolName = [[NSString alloc] initWithBytes:protocolHead length:(protocolSearch - protocolHead) encoding:NSUTF8StringEncoding];
                            [protocolNames addObject:protocolName];
                            
                            protocolSearch++; // move over the trailing '>'
                            if (protocolSearch == chr) {
                                break;
                            }
                            assert(protocolSearch[0] == '<');
                            protocolHead = protocolSearch;
                        }
                        
                        objType.protocolNames = protocolNames;
                    }
                    NSAssert(type == nil, @"Overwriting type");
                    type = objType;
                } else if (chr[1] == '?') {
                    CDBlockType *blockType = [CDBlockType new];
                    chr++;
                    
                    if (chr[1] == '<') {
                        // chr is pointing to '?'
                        // jump over '?' and '<'
                        chr += 2;
                        
                        const char *parameterEncoding = [self endOfTypeEncoding:chr];
                        blockType.returnType = [self typeForEncodingStart:chr end:parameterEncoding error:NULL];
                        chr = parameterEncoding;
                        
                        NSAssert(chr[0] == '@' && chr[1] == '?', @"First block parameter should be itself");
                        chr += 2; // skip first block parameter
                        
                        // what we expect is that the input string looks something like:
                        //   "@?<@?____>"
                        //         ^
                        // chr is currently pointing here. Initialize `paramEnd` on the
                        // character before, since `paramEnd` is incremented before being read,
                        // which would be an issue if the input string is
                        //   "@?<@?>"
                        //         ^
                        // because chr points here, and we'd end up walking past the end of the type.
                        const char *paramEnd = chr - 1;
                        unsigned openTokens = 1;
                        while (openTokens) {
                            switch (*++paramEnd) {
                                case '<':
                                    openTokens++;
                                    break;
                                case '>':
                                    openTokens--;
                                    break;
                            }
                        }
                        
                        NSMutableArray<CDParseType *> *parameterTypes = [NSMutableArray array];
                        while (chr < paramEnd) {
                            const char *tokenEnd = [self endOfTypeEncoding:chr];
                            [parameterTypes addObject:[self typeForEncodingStart:chr end:tokenEnd error:NULL]];
                            chr = tokenEnd;
                        }
                        chr = paramEnd;
                        
                        blockType.parameterTypes = parameterTypes;
                    }
                    
                    NSAssert(type == nil, @"Overwriting type");
                    type = blockType;
                } else {
                    NSAssert(type == nil, @"Overwriting type");
                    type = [CDObjectType new];
                }
            } break;
            case 'b': {
                chr++; // fastforward over 'b'
                
                CDBitFieldType *bitField = [CDBitFieldType new];
                bitField.width = strtoul(chr, (char **)&chr, 10);
                
                NSAssert(type == nil, @"Overwriting type");
                type = bitField;
            } break;
            case '[': {
                const char *const chrcpy = chr;
                unsigned openTokens = 1;
                while (openTokens) {
                    switch (*++chr) {
                        case '[':
                            openTokens++;
                            break;
                        case ']':
                            openTokens--;
                            break;
                    }
                }
                
                CDArrayType *arrayType = [CDArrayType new];
                
                char *tokenStart = NULL;
                arrayType.size = strtoul(chrcpy + 1, &tokenStart, 10);
                
                BOOL typeError = NO;
                arrayType.type = [self typeForEncodingStart:tokenStart end:chr error:&typeError];
                
                if (typeError) {
                    if (error) {
                        *error = typeError;
                    }
                    return nil;
                }
                NSAssert(type == nil, @"Overwriting type");
                type = arrayType;
            } break;
            case '{': {
                const char *const chrcpy = chr;
                unsigned openTokens = 1;
                while (openTokens) {
                    switch (*++chr) {
                        case '{':
                            openTokens++;
                            break;
                        case '}':
                            openTokens--;
                            break;
                    }
                }
                NSAssert(type == nil, @"Overwriting type");
                type = [self recordTypeForEncodingStart:chrcpy end:chr + 1];
            } break;
            case '(': {
                const char *const chrcpy = chr;
                unsigned openTokens = 1;
                while (openTokens) {
                    switch (*++chr) {
                        case '(':
                            openTokens++;
                            break;
                        case ')':
                            openTokens--;
                            break;
                    }
                }
                NSAssert(type == nil, @"Overwriting type");
                type = [self recordTypeForEncodingStart:chrcpy end:chr + 1];
            } break;
            case '?':
                NSAssert(type == nil, @"Overwriting type");
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeFunction];
                break;
            default: {
                NSAssert(NO, @"Unknown encoding");
                if (error) {
                    *error = YES;
                }
                return nil;
            } break;
        }
    }
    
    if (type == nil) {
        type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeEmpty];
    }
    type.modifiers = modifiers;
    return type;
}

+ (CDRecordType *)recordTypeForEncodingStart:(const char *const)start end:(const char *const)end {
    const char *const endToken = end - 1;
    const char firstChar = *start;
    const char lastChar = *endToken;
    
    BOOL const isStruct = (firstChar == '{' && lastChar == '}');
    BOOL const isUnion = (firstChar == '(' && lastChar == ')');
    NSAssert(isStruct || isUnion, @"Expected either a struct or union");
    NSAssert(isStruct != isUnion, @"Record cannot be both a struct and union");
    
    CDRecordType *record = [CDRecordType new];
    record.isUnion = isUnion;
    
    size_t nameOffset = 1;
    while (start[nameOffset] != '=' && start[nameOffset] != '}') {
        nameOffset++;
    }
    nameOffset++;
    
    // anonymous indicator
    if (nameOffset != 3 && start[1] != '?') {
        record.name = [[NSString alloc] initWithBytes:(start + 1) length:(nameOffset - 2) encoding:NSUTF8StringEncoding];
    }
    // no content, usually caused by multiple levels of indirection
    if (nameOffset == (end - start)) {
        return record;
    }
    
    NSMutableArray<CDVariableModel *> *fields = [NSMutableArray array];
    
    for (const char *chr = start + nameOffset; chr < endToken;) {
        CDVariableModel *variableModel = [CDVariableModel new];
        
        if (*chr == '"') {
            const char *const chrcpy = ++chr;
            while (*chr != '"') {
                chr++;
            }
            variableModel.name = [[NSString alloc] initWithBytes:chrcpy length:(chr - chrcpy) encoding:NSUTF8StringEncoding];
            chr++;
        }
        
        const char *const chrcpy = chr;
        chr = [self endOfTypeEncoding:chrcpy];
        
        BOOL subError = NO;
        variableModel.type = [self typeForEncodingStart:chrcpy end:chr error:&subError];
        if (subError) {
            return nil;
        }
        [fields addObject:variableModel];
    }
    record.fields = fields;
    return record;
}

@end
