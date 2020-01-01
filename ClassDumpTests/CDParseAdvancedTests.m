//
//  CDParseAdvancedTests.m
//  ClassDumpTests
//
//  Created by Leptos on 1/1/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../ClassDump/ClassDump.h"
#import "../ClassDump/Services/CDTypeParser.h"

@interface CDParseAdvancedTests : XCTestCase

@end

@implementation CDParseAdvancedTests

- (void)testComplex {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(_Complex float) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"_Complex float var"]);
}

- (void)testAtomic {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(_Atomic int) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"_Atomic int var"]);
}

- (void)testInlineArray {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(char[8]) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"char var[8]"]);
}

- (void)testStruct {
    struct TestStruct {
        int a;
        float b;
        long long c;
    };
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(struct TestStruct) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"struct TestStruct { int x0; float x1; long long x2; } var"]);
}

- (void)testUnion {
    union TestUnion {
        int fixed;
        float floating;
    };
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(union TestUnion) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"union TestUnion { int x0; float x1; } var"]);
}

- (void)testNestedStructsUnions {
    union TestUnion {
        char bytes[16];
        struct demo_sockaddr_in {
            unsigned char sin_len;
            unsigned char sin_family;
            unsigned short sin_port;
            union {
                char bytes[4];
                int addr;
            } sin_addr;
            char sin_zero[8];
        } socket_addr;
        int words[4];
    };
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(union TestUnion) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"union TestUnion { "
               "char x0[16]; "
               "struct demo_sockaddr_in { "
               "unsigned char x0; "
               "unsigned char x1; "
               "unsigned short x2; "
               "union { char x0[4]; int x1; } x3; "
               "char x4[8]; "
               "} x1; "
               "int x2[4]; "
               "} var"]);
}

- (void)testBitfields {
    struct BitfieldTest {
        unsigned a : 18;
        unsigned b : 2;
        unsigned c : 30;
        unsigned long d : 34;
        unsigned e : 1;
        unsigned __int128 f : 100;
        unsigned g : 10;
        unsigned h : 15;
    };
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(struct BitfieldTest) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"struct BitfieldTest { "
               "unsigned int x0 : 18; unsigned char x1 : 2; "
               "unsigned int x2 : 30; unsigned long x3 : 34; "
               "unsigned char x4 : 1; unsigned __int128 x5 : 100; "
               "unsigned short x6 : 10; unsigned short x7 : 15; } var"]);
}

- (void)testPointers {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(void **) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"void **var"]);
    
    parsed = [CDTypeParser stringForEncoding:@encode(int *) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"int *var"]);
    
    parsed = [CDTypeParser stringForEncoding:@encode(char **) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"char **var"]);
}

@end
