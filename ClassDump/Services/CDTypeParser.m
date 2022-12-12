//
//  CDTypeParser.m
//  ClassDump
//
//  Created by Leptos on 3/24/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "CDTypeParser.h"

#import "CDPrimitiveType.h"
#import "CDObjectType.h"
#import "CDRecordType.h"
#import "CDPointerType.h"
#import "CDArrayType.h"
#import "CDBitFieldType.h"

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
            case '"':
            case ']':
            case '}':
            case ')':
                /* don't modify, this isn't actually a type */
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
                encoding++;
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
                CDObjectType *objType = [CDObjectType new];
                
                if (chr[1] == '"') {
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
                } else if (chr[1] == '?') {
                    objType.isBlock = YES;
                    chr++;
                }
                NSAssert(type == nil, @"Overwriting type");
                type = objType;
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
    NSAssert(type != nil, @"type should be set");
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
