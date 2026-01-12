//
//  CDMethodParameterNameResolver.m
//  ClassDump
//
//  Created by Leptos on 1/11/26.
//  Copyright © 2026 Leptos. All rights reserved.
//

#import "CDMethodParameterNameResolver.h"
#import "../Services/CDStringFormatting.h"

NSString *CDMethodParameterNameNumberedResolver(NSArray<NSString *> *selectorComponents, NSUInteger componentIndex) {
    return [@"a" stringByAppendingString:NSStringFromNSUInteger(componentIndex)];
}

// Splits a string into words assuming the `spelling` is snake case, camel case, or Pascal case.
static NSArray<NSString *> *splitWordsProgrammingSpelling(NSString *spelling) {
    NSMutableArray<NSString *> *const build = [NSMutableArray array];
    NSMutableString *const head = [NSMutableString string];
    
    void (^const pushIfNeeded)(void) = ^{
        if (head.length == 0) {
            return;
        }
        [build addObject:[head copy]];
        [head setString:@""];
    };
    
    NSCharacterSet *const uppercaseCharacterSet = [NSCharacterSet uppercaseLetterCharacterSet];
    
    BOOL lastWasUppercase = NO;
    
    NSUInteger const characterCount = spelling.length;
    
    for (NSUInteger characterIndex = 0; characterIndex < characterCount; characterIndex++) {
        unichar const chr = [spelling characterAtIndex:characterIndex];
        
        // i.e. snake case
        if (chr == '_') {
            pushIfNeeded();
            continue;
        }
        BOOL const isUppercase = [uppercaseCharacterSet characterIsMember:chr];
        if (isUppercase && !lastWasUppercase) {
            pushIfNeeded();
        }
        
        [head appendString:[[NSString alloc] initWithCharacters:&chr length:1]];
        lastWasUppercase = isUppercase;
    }
    
    pushIfNeeded();
    return [build copy];
}

NSString *CDMethodParameterNameSimpleTransformResolver(NSArray<NSString *> *selectorComponents, NSUInteger componentIndex) {
    NSString *const selectorComponent = selectorComponents[componentIndex];
    
    if ([selectorComponent isEqualToString:@"completionHandler"]) {
        return @"completionHandler";
    }
    NSArray<NSString *> *const words = splitWordsProgrammingSpelling(selectorComponent);
    NSString *const lastWord = words.lastObject;
    if (lastWord == nil) {
        return nil;
    }
    if ([lastWord isEqualToString:@"URL"]) {
        return @"url";
    }
    
    NSString *lastWordLowerCase = lastWord.lowercaseString;
    if ([lastWordLowerCase isEqualToString:@"named"]) {
        return @"name";
    }
    NSSet<NSString *> *const reservedIdentifiers = CDReservedLanguageKeywords();
    if ([reservedIdentifiers containsObject:lastWordLowerCase]) {
        return nil;
    }
    return lastWordLowerCase;
}


NSSet<NSString *> *const CDReservedLanguageKeywords(void) {
    static NSSet<NSString *> *values = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        values = [NSSet setWithArray:@[
            @"alignas",
            @"alignof",
            @"auto",
            @"bool",
            @"break",
            @"case",
            @"char",
            @"const",
            @"constexpr",
            @"continue",
            @"default",
            @"do",
            @"double",
            @"else",
            @"enum",
            
            @"extern",
            @"false",
            @"float",
            @"for",
            @"goto",
            @"if",
            @"inline",
            @"int",
            @"long",
            @"nullptr",
            @"register",
            @"restrict",
            @"return",
            @"short",
            @"signed",
            
            @"sizeof",
            @"static",
            @"static_assert",
            @"struct",
            @"switch",
            @"thread_local",
            @"true",
            @"typedef",
            @"typeof",
            @"typeof_unqual",
            @"union",
            @"unsigned",
            @"void",
            @"volatile",
            @"while",
            
            @"_Alignas",
            @"_Alignof",
            @"_Atomic",
            @"_BitInt",
            @"_Bool",
            @"_Complex",
            @"_Decimal128",
            @"_Decimal32",
            @"_Decimal64",
            @"_Generic",
            @"_Imaginary",
            @"_Noreturn",
            @"_Static_assert",
            @"_Thread_local",
        ]];
    });
    return values;
}
