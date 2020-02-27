//
//  CDParsePrimitiveTests.m
//  ClassDumpTests
//
//  Created by Leptos on 12/21/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../ClassDump/ClassDump.h"
#import "../ClassDump/Services/CDTypeParser.h"

@interface CDParsePrimitiveTests : XCTestCase

@end

@implementation CDParsePrimitiveTests

- (void)testVoid {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(void) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"void var"]);
}

- (void)testChar {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(char) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"char var"]);
    parsed = [CDTypeParser stringForEncoding:@encode(unsigned char) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"unsigned char var"]);
}

- (void)testShort {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(short) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"short var"]);
    parsed = [CDTypeParser stringForEncoding:@encode(unsigned short) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"unsigned short var"]);
}

- (void)testInt {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(int) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"int var"]);
    parsed = [CDTypeParser stringForEncoding:@encode(unsigned int) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"unsigned int var"]);
}

#if __SIZEOF_LONG__ != __SIZEOF_LONG_LONG__
- (void)testLong {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(long) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"long var"]);
    
    parsed = [CDTypeParser stringForEncoding:@encode(unsigned long) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"unsigned long var"]);
}
#endif

- (void)testLongLong {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(long long) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"long long var"]);
    parsed = [CDTypeParser stringForEncoding:@encode(unsigned long long) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"unsigned long long var"]);
}

#ifdef __SIZEOF_INT128__
- (void)testInt128 {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(__int128) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"__int128 var"]);
    parsed = [CDTypeParser stringForEncoding:@encode(unsigned __int128) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"unsigned __int128 var"]);
}
#endif

- (void)testFloating {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(float) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"float var"]);
    parsed = [CDTypeParser stringForEncoding:@encode(double) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"double var"]);
    
#ifdef __SIZEOF_LONG_DOUBLE__
    parsed = [CDTypeParser stringForEncoding:@encode(long double) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"long double var"]);
#endif
}

- (void)testObjcTypes {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(Class) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"Class var"]);
    parsed = [CDTypeParser stringForEncoding:@encode(SEL) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"SEL var"]);
#if __OBJC_BOOL_IS_BOOL
    parsed = [CDTypeParser stringForEncoding:@encode(BOOL) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"BOOL var"]);
#endif
}

@end
