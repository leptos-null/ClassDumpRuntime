//
//  CDParsePrimitiveTests.m
//  ClassDumpTests
//
//  Created by Leptos on 12/21/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ClassDumpRuntime/ClassDumpRuntime.h>

@interface CDParsePrimitiveTests : XCTestCase

@end

@implementation CDParsePrimitiveTests

- (void)testVoid {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(void)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"void var"]);
}

- (void)testChar {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(char)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"char var"]);
    type = [CDTypeParser typeForEncoding:@encode(unsigned char)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"unsigned char var"]);
}

- (void)testShort {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(short)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"short var"]);
    type = [CDTypeParser typeForEncoding:@encode(unsigned short)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"unsigned short var"]);
}

- (void)testInt {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(int)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"int var"]);
    type = [CDTypeParser typeForEncoding:@encode(unsigned int)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"unsigned int var"]);
}

#if __SIZEOF_LONG__ != __SIZEOF_LONG_LONG__
- (void)testLong {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(long)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"long var"]);
    
    type = [CDTypeParser typeForEncoding:@encode(unsigned long)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"unsigned long var"]);
}
#endif

- (void)testLongLong {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(long long)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"long long var"]);
    type = [CDTypeParser typeForEncoding:@encode(unsigned long long)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"unsigned long long var"]);
}

#ifdef __SIZEOF_INT128__
- (void)testInt128 {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(__int128)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"__int128 var"]);
    type = [CDTypeParser typeForEncoding:@encode(unsigned __int128)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"unsigned __int128 var"]);
}
#endif

- (void)testFloating {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(float)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"float var"]);
    type = [CDTypeParser typeForEncoding:@encode(double)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"double var"]);
    
#ifdef __SIZEOF_LONG_DOUBLE__
    type = [CDTypeParser typeForEncoding:@encode(long double)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"long double var"]);
#endif
}

- (void)testObjcTypes {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(Class)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"Class var"]);
    type = [CDTypeParser typeForEncoding:@encode(SEL)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"SEL var"]);
#if __OBJC_BOOL_IS_BOOL
    type = [CDTypeParser typeForEncoding:@encode(BOOL)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"BOOL var"]);
#endif
}

@end
