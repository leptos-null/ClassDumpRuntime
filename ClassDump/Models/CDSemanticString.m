//
//  CDSemanticString.m
//  ClassDump
//
//  Created by Leptos on 1/1/23.
//  Copyright © 2023 Leptos. All rights reserved.
//

#import "CDSemanticString.h"

@interface CDSemanticStringStaple : NSObject
@property (strong, nonatomic) NSString *string;
@property (nonatomic) CDSemanticType type;
@end

@implementation CDSemanticStringStaple
@end


@implementation CDSemanticString {
    NSMutableArray<CDSemanticStringStaple *> *_components;
}

- (instancetype)init {
    if (self = [super init]) {
        _length = 0;
        _components = [NSMutableArray array];
    }
    return self;
}

- (void)appendSemanticString:(CDSemanticString *)semanticString {
    [_components addObjectsFromArray:semanticString->_components];
    _length += semanticString.length;
}

- (void)appendString:(NSString *)string semanticType:(CDSemanticType)type {
    if (string.length > 0) {
        CDSemanticStringStaple *staple = [CDSemanticStringStaple new];
        staple.string = string;
        staple.type = type;
        [_components addObject:staple];
        _length += string.length;
    }
}

- (BOOL)startsWithChar:(char)character {
    char *bytes = &character;
    NSString *suffix = [[NSString alloc] initWithBytesNoCopy:bytes length:1 encoding:NSASCIIStringEncoding freeWhenDone:NO];
    return [_components.firstObject.string hasPrefix:suffix];
}

- (BOOL)endWithChar:(char)character {
    char *bytes = &character;
    NSString *suffix = [[NSString alloc] initWithBytesNoCopy:bytes length:1 encoding:NSASCIIStringEncoding freeWhenDone:NO];
    return [_components.lastObject.string hasSuffix:suffix];
}

- (void)enumerateTypesUsingBlock:(void (NS_NOESCAPE ^)(NSString *string, CDSemanticType type))block {
    for (CDSemanticStringStaple *staple in _components) {
        block(staple.string, staple.type);
    }
}

- (void)enumerateLongestEffectiveRangesUsingBlock:(void (NS_NOESCAPE ^)(NSString *string, CDSemanticType type))block {
    CDSemanticType activeStapleType = CDSemanticTypeStandard;
    NSMutableString *concatString = nil;
    for (CDSemanticStringStaple *staple in _components) {
        if ((concatString == nil) || (staple.type != activeStapleType)) {
            if (concatString != nil) {
                block([concatString copy], activeStapleType);
            }
            concatString = [NSMutableString stringWithString:staple.string];
            activeStapleType = staple.type;
        } else {
            [concatString appendString:staple.string];
        }
    }
    if (concatString != nil) {
        block([concatString copy], activeStapleType);
    }
}

- (NSString *)string {
    NSMutableString *build = [NSMutableString string];
    for (CDSemanticStringStaple *staple in _components) {
        [build appendString:staple.string];
    }
    return [build copy];
}

@end
