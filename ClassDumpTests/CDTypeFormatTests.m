//
//  CDTypeFormatTests.m
//  ClassDumpTests
//
//  Created by Leptos on 1/15/26.
//  Copyright © 2026 Leptos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ClassDump/ClassDump.h>

@interface CDTypeFormatTests : XCTestCase

@end

@implementation CDTypeFormatTests

- (void)testNesting {
    struct TestNesting {
        unsigned char magic[4];
        union TestNesting_Identifier {
            unsigned char bytes[16];
            unsigned long long wide[2];
        } identifier;
        struct TestNesting_Range {
            unsigned int start;
            unsigned int end;
        } ranges[4];
    };
    
    CDParseType *type = [CDTypeParser typeForEncoding:@encode(struct TestNesting)];
    
    CDTypeFormatOptions *formatOptions = [CDTypeFormatOptions new];
    formatOptions.multilineRecords = YES;
    formatOptions.indentString = @"    ";
    NSString *formattedType = [[type semanticStringForVariableName:nil indentationLevel:0 formatOptions:formatOptions] string];
    XCTAssert([formattedType isEqualToString:@"struct TestNesting {\n"
               "    unsigned char x0[4];\n"
               "    union TestNesting_Identifier {\n"
               "        unsigned char x0[16];\n"
               "        unsigned long long x1[2];\n"
               "    } x1;\n"
               "    struct TestNesting_Range {\n"
               "        unsigned int x0;\n"
               "        unsigned int x1;\n"
               "    } x2[4];\n"
               "}"]);
}

@end
