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

@property (nonatomic) CDSemanticStringStaple *next;

@end

@implementation CDSemanticStringStaple
@end


@implementation CDSemanticString {
    CDSemanticStringStaple *_head;
    CDSemanticStringStaple *_tail;
}

- (instancetype)init {
    if (self = [super init]) {
        _length = 0;
    }
    return self;
}

- (void)dealloc {
    CDSemanticStringStaple *head = _head;
    _head = nil; // i.e. release
    while (head != nil) {
        /* `head` gets released because it's no longer referenced here */
        head = head.next;
    }
}

- (void)appendSemanticString:(CDSemanticString *)semanticString {
    if (_tail) {
        _tail.next = semanticString->_head;
    } else {
        _head = semanticString->_head;
    }
    _tail = semanticString->_tail;
    _length += semanticString.length;
}

- (void)appendString:(NSString *)string semanticType:(CDSemanticType)type {
    if (string.length > 0) {
        CDSemanticStringStaple *staple = [CDSemanticStringStaple new];
        staple.string = string;
        staple.type = type;
        
        _tail.next = staple;
        _tail = staple;
        
        if (_head == nil) {
            _head = staple;
        }
        
        _length += string.length;
    }
}

- (BOOL)startsWithChar:(char)character {
    char *bytes = &character;
    NSString *prefix = [[NSString alloc] initWithBytesNoCopy:bytes length:1 encoding:NSASCIIStringEncoding freeWhenDone:NO];
    return [_head.string hasPrefix:prefix];
}

- (BOOL)endWithChar:(char)character {
    char *bytes = &character;
    NSString *suffix = [[NSString alloc] initWithBytesNoCopy:bytes length:1 encoding:NSASCIIStringEncoding freeWhenDone:NO];
    return [_tail.string hasSuffix:suffix];
}

- (void)enumerateTypesUsingBlock:(void (NS_NOESCAPE ^)(NSString *string, CDSemanticType type))block {
    for (CDSemanticStringStaple *staple = _head; staple != nil; staple = staple.next) {
        block(staple.string, staple.type);
    }
}

- (void)enumerateLongestEffectiveRangesUsingBlock:(void (NS_NOESCAPE ^)(NSString *string, CDSemanticType type))block {
    CDSemanticType activeStapleType = CDSemanticTypeStandard;
    NSMutableString *concatString = nil;
    for (CDSemanticStringStaple *staple = _head; staple != nil; staple = staple.next) {
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
    for (CDSemanticStringStaple *staple = _head; staple != nil; staple = staple.next) {
        [build appendString:staple.string];
    }
    return [build copy];
}

@end
