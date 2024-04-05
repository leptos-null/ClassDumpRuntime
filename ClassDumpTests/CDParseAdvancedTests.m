//
//  CDParseAdvancedTests.m
//  ClassDumpTests
//
//  Created by Leptos on 1/1/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ClassDump/ClassDump.h>

@interface CDParseAdvancedTests : XCTestCase

@end

@implementation CDParseAdvancedTests

- (void)testComplex {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(_Complex float)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"_Complex float var"]);
}

- (void)testAtomic {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(_Atomic int)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"_Atomic int var"]);
}

- (void)testFunction {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(int (*)(char))];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"void /* function */ *var"]);
    XCTAssert([[type stringForVariableName:nil] isEqualToString:@"void /* function */ *"]);
}

- (void)testConstAttribute {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(const char *)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"const char *var"]);
}

- (void)testInlineArray {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(char[8])];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"char var[8]"]);
    XCTAssert([[type stringForVariableName:nil] isEqualToString:@"char[8]"]);
}

- (void)testMutliDemensionalArray {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(int[8][2][4])];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"int var[8][2][4]"]);
    XCTAssert([[type stringForVariableName:nil] isEqualToString:@"int[8][2][4]"]);
}

- (void)testPointerArray {
    // this is an array of 4 pointers to long long
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(long long *[4])];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"long long *var[4]"]);
    XCTAssert([[type stringForVariableName:nil] isEqualToString:@"long long *[4]"]);
}

- (void)testArrayPointer {
    // this is a pointer to array of 2 int elements
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(int (*)[2])];
    XCTExpectFailure(@"Multiple levels of pointers/ arrays known to decode in the reverse order");
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"int (*var)[2]"]);
    XCTAssert([[type stringForVariableName:nil] isEqualToString:@"int (*)[2]"]);
}

- (void)testPointerArrayPointers {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(int *(*)[2])];
    XCTExpectFailure(@"Multiple levels of pointers/ arrays known to decode in the reverse order");
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"int *(*var)[2]"]);
    XCTAssert([[type stringForVariableName:nil] isEqualToString:@"int *(*)[2]"]);
}

- (void)testPointerArrayPointersPointer {
    /* pointer to an array of pointers to pointers
     *
     * int **pp;
     * int **ppa[2] = { pp, pp };
     * int **(*ppap)[2] = &ppa;
     */
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(int **(*)[2])];
    XCTExpectFailure(@"Multiple levels of pointers/ arrays known to decode in the reverse order");
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"int **(*var)[2]"]);
    XCTAssert([[type stringForVariableName:nil] isEqualToString:@"int **(*)[2]"]);
}

- (void)testPointerArrayPointersArray {
    /* array of pointers to an array of pointers
     *
     * int *ip;
     * int *ipa[2] = { ip, ip };
     * int *(*ipap)[2] = &ipa;
     * int *(*ipapa[4])[2] = { ipap, ipap, ipap, ipap };
     */
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(int *(*[4])[2])];
    XCTExpectFailure(@"Multiple levels of pointers/ arrays known to decode in the reverse order");
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"int *(*var[4])[2]"]);
    XCTAssert([[type stringForVariableName:nil] isEqualToString:@"int *(*[4])[2]"]);
}

- (void)testPointerArrayPointersArrayPointer {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(int *(*(*)[4])[2])];
    XCTExpectFailure(@"Multiple levels of pointers/ arrays known to decode in the reverse order");
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"int *(*(*var)[4])[2]"]);
    XCTAssert([[type stringForVariableName:nil] isEqualToString:@"int *(*(*)[4])[2]"]);
}

- (void)testArrayPointerArray {
    /* array of pointers to an array
     *
     * int i;
     * int ia[2] = { i, i };
     * int (*iap)[2] = &ia;
     * int (*iapa[4])[2] = { iap, iap, iap, iap };
     */
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(int (*[4])[2])];
    XCTExpectFailure(@"Multiple levels of pointers/ arrays known to decode in the reverse order");
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"int (*var[4])[2]"]);
    XCTAssert([[type stringForVariableName:nil] isEqualToString:@"int (*[4])[2]"]);
}

- (void)testMutliDemensionalArrayStruct {
    struct TestStruct {
        int a[1];
        float b[2][3];
        long long *c[4];
    };
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(struct TestStruct [5])];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"struct TestStruct { "
               "int x0[1]; "
               "float x1[2][3]; "
               "long long *x2[4]; "
               "} var[5]"]);
}

- (void)testStruct {
    struct TestStruct {
        int a;
        float b;
        long long c;
    };
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(struct TestStruct)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"struct TestStruct { "
               "int x0; float x1; long long x2; "
               "} var"]);
}

- (void)testUnion {
    union TestUnion {
        int fixed;
        float floating;
    };
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(union TestUnion)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"union TestUnion { "
               "int x0; float x1; "
               "} var"]);
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
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(union TestUnion)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"union TestUnion { "
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
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(struct BitfieldTest)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"struct BitfieldTest { "
               "unsigned int x0 : 18; unsigned char x1 : 2; "
               "unsigned int x2 : 30; unsigned long x3 : 34; "
               "unsigned char x4 : 1; unsigned __int128 x5 : 100; "
               "unsigned short x6 : 10; unsigned short x7 : 15; "
               "} var"]);
}

- (void)testModifiedFields {
    struct ModifiersTest {
        _Atomic BOOL a;
        _Complex float b;
        _Atomic _Complex int c;
    };
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(struct ModifiersTest)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"struct ModifiersTest { "
               "_Atomic BOOL x0; _Complex float x1; _Atomic _Complex int x2; "
               "} var"]);
}

- (void)testPointers {
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(void **)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"void **var"]);
    
    type = [CDTypeParser typeForEncoding:@encode(int *)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"int *var"]);
    
    type = [CDTypeParser typeForEncoding:@encode(char **)];
    XCTAssert([[type stringForVariableName:@"var"] isEqualToString:@"char **var"]);
}

@end
