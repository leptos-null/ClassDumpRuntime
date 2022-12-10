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

@implementation CDTypeParser

// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
// https://gcc.gnu.org/onlinedocs/gcc-4.8.2/gcc/Type-encoding.html
// https://github.com/gcc-mirror/gcc/blob/master/gcc/objc/objc-encoding.cc
// https://github.com/llvm/llvm-project/blob/main/clang/lib/AST/ASTContext.cpp

+ (CDParseType *)typeForEncoding:(const char *)encoding {
    return [self typeForEncodingStart:encoding end:encoding + strlen(encoding) error:NULL];
}

+ (CDParseType *)typeForEncodingStart:(const char *const)start end:(const char *const)end error:(inout BOOL *)error {
    __kindof CDParseType *type;
    NSMutableArray<NSNumber *> *modifiers = [NSMutableArray array];
    
    // see getObjCEncodingForTypeImpl in llvm/clang/lib/AST/ASTContext.cpp
    for (const char *chr = start; chr < end; chr++) {
        switch (*chr) {
            case '^': {
                BOOL pointeeError = NO;
                CDParseType *pointee = [self typeForEncodingStart:chr + 1 end:end error:&pointeeError];
                if (pointeeError) {
                    if (error) {
                        *error = pointeeError;
                    }
                    return nil;
                }
                if (pointee == NULL) {
                    // TODO
                    pointee = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeVoid];
                }
                type = [CDPointerType pointerToPointee:pointee];
            } break;
            case '*': {
                CDParseType *pointee = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeChar];
                
                type = [CDPointerType pointerToPointee:pointee];
            } break;
            case 'c':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeChar];
                break;
            case 'i':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeInt];
                break;
            case 's':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeShort];
                break;
            case 'l':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeLong];
                break;
            case 'q':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeLongLong];
                break;
            case 't':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeInt128];
                break;
            case 'C':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeUnsignedChar];
                break;
            case 'I':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeUnsignedInt];
                break;
            case 'S':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeUnsignedShort];
                break;
            case 'L':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeUnsignedLong];
                break;
            case 'Q':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeUnsignedLongLong];
                break;
            case 'T':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeUnsignedInt128];
                break;
            case 'f':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeFloat];
                break;
            case 'd':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeDouble];
                break;
            case 'D':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeLongDouble];
                break;
            case 'B':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeBool];
                break;
            case 'v':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeVoid];
                break;
            case '#':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeClass];
                break;
            case ':':
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
                type = objType;
            } break;
            case 'b': {
                chr++; // fastforward over 'b'
                
                CDBitFieldType *bitField = [CDBitFieldType new];
                bitField.width = strtoul(chr, (char **)&chr, 10);
                
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
                type = [self recordTypeForEncodingStart:chrcpy end:chr + 1];
            } break;
            case '?':
                type = [CDPrimitiveType primitiveWithRawType:CDPrimitiveRawTypeFunction];
                break;
            default: {
                if (error) {
                    *error = YES;
                }
                return nil;
            } break;
        }
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
        char nameBuff[nameOffset];
        nameBuff[0] = ' '; // start with a space
        strncpy(nameBuff + 1, start + 1, sizeof(nameBuff) - 1);
        nameBuff[sizeof(nameBuff) - 1] = 0;
        record.name = @(nameBuff);
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
        
        unsigned pointerCount = 0;
        const char *const beforeIndirection = chr;
        while (*chr == '^') {
            pointerCount++;
            chr++;
        }
        
        if (*chr == '@' && chr[1] == '"') {
            chr += 2; /* fastforward over '@' and the first '"' */
            while (*chr != '"') {
                chr++;
            }
        } else if (*chr == '@' && chr[1] == '?') {
            chr++;
        } else if (*chr == '[') {
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
        } else if (*chr == '{') {
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
        } else if (*chr == '(') {
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
        } else if (*chr == 'b') {
            chr++;
            while (isnumber(*chr)) {
                chr++;
            }
            /* unlike arrays, structs, unions, and quotes, this doesn't have a close, so we have to rewind */
            chr--;
        }
        chr++;
        
        BOOL subError = NO;
        variableModel.type = [self typeForEncodingStart:beforeIndirection end:chr error:&subError];
        if (subError) {
            return nil;
        }
    }
    record.fields = fields;
    return record;
}

+ (NSString *)stringForEncoding:(const char *)encoding variable:(NSString *)varName {
    return [self stringForEncodingStart:encoding end:encoding + strlen(encoding) variable:varName error:NULL];
}

+ (NSString *)stringForEncodingStart:(const char *const)start end:(const char *const)end variable:(NSString *)varName error:(inout BOOL *)error {
    NSInteger pointerCounter = 0;
    NSString *type = nil;
    NSMutableArray<NSString *> *prefixMods = [NSMutableArray array]; // only applicable to Obj-C method arguments
    NSString *subjectPostfix = nil; // this can _only_ be "[#]" *OR* " : #"
    
    // known bug: the `const` attribute applies to types other than Obj-C method arguments.
    //   it can also occur anywhere in the encoding, not just in the front. the position in the
    //   encoding relays where the const was in the type, i.e. `int *const` != `const int *`
    // this doesn't seem to have much of an impact, because clang seems to only include a leading `const`
    
    // see getObjCEncodingForTypeImpl in llvm/clang/lib/AST/ASTContext.cpp
    for (const char *chr = start; chr < end; chr++) {
        switch (*chr) {
            case '^':
                pointerCounter++;
                type = @"void"; // in c++, just ^ means pointer, so we have to fill in an incomplete type
                break;
            case '*':
                pointerCounter++;
                // '*' means "char *", no break
            case 'c':
                type = @"char";
                break;
            case 'i':
                type = @"int";
                break;
            case 's':
                type = @"short";
                break;
            case 'l':
                type = @"long";
                break;
            case 'q':
                type = @"long long";
                break;
            case 't':
                type = @"__int128";
                break;
            case 'C':
                type = @"unsigned char";
                break;
            case 'I':
                type = @"unsigned int";
                break;
            case 'S':
                type = @"unsigned short";
                break;
            case 'L':
                type = @"unsigned long";
                break;
            case 'Q':
                type = @"unsigned long long";
                break;
            case 'T':
                type = @"unsigned __int128";
                break;
            case 'f':
                type = @"float";
                break;
            case 'd':
                type = @"double";
                break;
            case 'D':
                type = @"long double";
                break;
            case 'B':
                type = @"BOOL"; // or bool or _Bool
                break;
            case 'v':
                type = @"void";
                break;
            case '#':
                type = @"Class";
                break;
            case ':':
                type = @"SEL";
                break;
            case 'r':
                // todo: see bug comment above
                [prefixMods addObject:@"const"];
                break;
            case 'n':
                [prefixMods addObject:@"in"];
                break;
            case 'N':
                [prefixMods addObject:@"inout"];
                break;
            case 'o':
                [prefixMods addObject:@"out"];
                break;
            case 'O':
                [prefixMods addObject:@"bycopy"];
                break;
            case 'R':
                [prefixMods addObject:@"byref"];
                break;
            case 'V':
                [prefixMods addObject:@"oneway"];
                break;
            case 'A':
                [prefixMods addObject:@"_Atomic"];
                break;
            case 'j':
                [prefixMods addObject:@"_Complex"];
                break;
            case '@': {
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
                        type = [[NSString alloc] initWithBytes:chrcpy length:(chr - chrcpy) encoding:NSUTF8StringEncoding];
                        pointerCounter++;
                    } else {
                        ptrdiff_t const baseTypeLength = (protocolHead - chrcpy);
                        NSString *baseType;
                        if (baseTypeLength) {
                            baseType = [[NSString alloc] initWithBytes:chrcpy length:baseTypeLength encoding:NSUTF8StringEncoding];
                            pointerCounter++;
                        } else {
                            baseType = @"id";
                        }
                        
                        NSMutableString *buildConforms = [NSMutableString stringWithString:baseType];
                        [buildConforms appendString:@"<"];
                        
                        const char *protocolSearch = protocolHead;
                        while (chr > protocolSearch) {
                            while (*protocolSearch != '>') {
                                protocolSearch++;
                            }
                            protocolHead++; // skip the leading '<'
                            NSString *protocolName = [[NSString alloc] initWithBytes:protocolHead length:(protocolSearch - protocolHead) encoding:NSUTF8StringEncoding];
                            [buildConforms appendString:protocolName];
                            
                            protocolSearch++; // move over the trailing '>'
                            if (protocolSearch == chr) {
                                break;
                            }
                            assert(protocolSearch[0] == '<');
                            protocolHead = protocolSearch;
                            
                            [buildConforms appendString:@", "];
                        }
                        
                        [buildConforms appendString:@">"];
                        type = [buildConforms copy];
                    }
                } else if (chr[1] == '?') {
                    type = @"id /* block */";
                    chr++;
                } else {
                    type = @"id";
                }
            } break;
            case 'b': {
                chr++; // fastforward over 'b'
                const char *const chrcpy = chr;
                while (isnumber(*chr)) {
                    chr++;
                }
                const NSUInteger numLength = chr - chrcpy;
                NSString *soloBox = [[NSString alloc] initWithBytes:chrcpy length:numLength encoding:NSUTF8StringEncoding];
                subjectPostfix = [@" : " stringByAppendingString:soloBox];
                
                int bitWidth = soloBox.intValue;
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
                    NSLog(@"bit width is larger than maximum platform width");
                }
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
                
                size_t numSize = 1;
                while (isnumber(chrcpy[numSize])) {
                    numSize++;
                }
                char arrayLength[numSize + 2]; // the number, plus open bracket, plus close bracket, null term is included in size
                strncpy(arrayLength, chrcpy, numSize); // stealing the token's open bracket
                arrayLength[numSize] = ']';
                arrayLength[sizeof(arrayLength) - 1] = 0;
                subjectPostfix = @(arrayLength);
                // known bug: This implementation results in multi-demensional arrays being printed in reverse
                //   e.g. `int var[1][2][3]` will be decoded as `int var[3][2][1]`
                varName = [self stringForEncodingStart:(chrcpy + numSize) end:chr variable:varName error:error];
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
                
                type = [self structureForEncodingStart:chrcpy end:chr + 1];
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
                type = [self structureForEncodingStart:chrcpy end:chr + 1];
            } break;
            case '?':
                assert(pointerCounter);
                type = @"void /* function */";
                break;
            default: {
                if (error) {
                    *error = YES;
                } else {
                    NSLog(@"Bad encoding char: %c", *chr);
                }
                NSString *badEncRet = @"BAD_ENCODING";
                if (varName) {
                    badEncRet = [[badEncRet stringByAppendingString:@" "] stringByAppendingString:varName];
                }
                return badEncRet;
            } break;
        }
    }
    
    char pointerBuffer[pointerCounter + 1];
    memset(pointerBuffer, '*', pointerCounter);
    pointerBuffer[pointerCounter] = 0;
    
    NSMutableString *ret = [NSMutableString string];
    for (NSString *prefixMod in prefixMods) {
        [ret appendString:prefixMod];
        [ret appendString:@" "];
    }
    if (type) {
        [ret appendString:type];
    }
    if ((varName && type) || pointerCounter) {
        [ret appendString:@" "];
    }
    [ret appendString:@(pointerBuffer)];
    if (varName) {
        [ret appendString:varName];
    }
    if (subjectPostfix) {
        [ret appendString:subjectPostfix];
    }
    return [ret copy];
}

// parser for structs or unions
+ (NSString *)structureForEncodingStart:(const char *const)start end:(const char *const)end {
    const char *const endToken = end - 1;
    const char firstChar = *start;
    const char lastChar = *endToken;
    
    BOOL const isStruct = (firstChar == '{' && lastChar == '}');
    BOOL const isUnion = (firstChar == '(' && lastChar == ')');
    if (!(isStruct || isUnion)) {
        NSLog(@"Not a valid struct or union encoding: %s", start);
        assert(0);
        return nil;
    }
    NSMutableString *ret = [NSMutableString string];
    if (isStruct) {
        [ret appendString:@"struct"];
    }
    if (isUnion) {
        [ret appendString:@"union"];
    }
    
    size_t nameOffset = 1;
    while (start[nameOffset] != '=' && start[nameOffset] != '}') {
        nameOffset++;
    }
    nameOffset++;
    
    // anonymous indicator
    if (nameOffset != 3 && start[1] != '?') {
        char nameBuff[nameOffset];
        nameBuff[0] = ' '; // start with a space
        strncpy(nameBuff + 1, start + 1, sizeof(nameBuff) - 1);
        nameBuff[sizeof(nameBuff) - 1] = 0;
        [ret appendString:@(nameBuff)];
    }
    // no content, usually caused by multiple levels of indirection
    if (nameOffset == (end - start)) {
        return [ret copy];
    }
    
    [ret appendString:@" { "];
    
    unsigned fieldName = 0;
    
    for (const char *chr = start + nameOffset; chr < endToken;) {
        NSString *variableName = nil;
        if (*chr == '"') {
            const char *const chrcpy = ++chr;
            while (*chr != '"') {
                chr++;
            }
            variableName = [[NSString alloc] initWithBytes:chrcpy length:(chr - chrcpy) encoding:NSUTF8StringEncoding];
            chr++;
        } else {
            variableName = [NSString stringWithFormat:@"x%u", fieldName++];
        }
        
        unsigned pointerCount = 0;
        const char *const beforeIndirection = chr;
        while (*chr == '^') {
            pointerCount++;
            chr++;
        }
        
        if (*chr == '@' && chr[1] == '"') {
            chr += 2; /* fastforward over '@' and the first '"' */
            while (*chr != '"') {
                chr++;
            }
        } else if (*chr == '@' && chr[1] == '?') {
            chr++;
        } else if (*chr == '[') {
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
        } else if (*chr == '{') {
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
        } else if (*chr == '(') {
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
        } else if (*chr == 'b') {
            chr++;
            while (isnumber(*chr)) {
                chr++;
            }
            /* unlike arrays, structs, unions, and quotes, this doesn't have a close, so we have to rewind */
            chr--;
        }
        chr++;
        BOOL subError = NO;
        [ret appendString:[self stringForEncodingStart:beforeIndirection end:chr variable:variableName error:&subError]];
        [ret appendString:@"; "];
        if (subError) {
            break;
        }
    }
    [ret appendString:@"}"];
    return ret;
}

@end
