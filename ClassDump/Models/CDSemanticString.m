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

@property (strong, nonatomic) CDSemanticStringStaple *next;

@end

@implementation CDSemanticStringStaple
@end

// This implementation is designed to be perfomance sensitive.
// Since we don't require random-access, the string is composed by a linked list.
@implementation CDSemanticString {
    CDSemanticStringStaple *_head;
    CDSemanticStringStaple *_tail;
}

- (instancetype)init {
    if (self = [super init]) {
        _length = 0;
        _head = nil;
        _tail = nil;
    }
    return self;
}

- (void)appendSemanticString:(CDSemanticString *)semanticString {
    if (_head == nil) {
        _head = semanticString->_head;
        _tail = semanticString->_tail;
        _length = semanticString->_length;
        return;
    }
    CDSemanticStringStaple *appendTail = semanticString->_tail;
    if (appendTail != nil) {
        _tail.next = semanticString->_head;
        _tail = appendTail;
    }
    _length += semanticString.length;
}

- (void)appendString:(NSString *)string semanticType:(CDSemanticType)type {
    if (string.length > 0) {
        CDSemanticStringStaple *staple = [CDSemanticStringStaple new];
        staple.string = string;
        staple.type = type;
        staple.next = nil;
        
        if (_head == nil) {
            _head = staple;
        }
        _tail.next = staple;
        _tail = staple;
        
        _length += string.length;
    }
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

- (NSString *)string {
    NSMutableString *build = [NSMutableString string];
    for (CDSemanticStringStaple *staple = _head; staple != nil; staple = staple.next) {
        [build appendString:staple.string];
    }
    return [build copy];
}

@end
