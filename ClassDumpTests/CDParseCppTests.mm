//
//  CDParseCppTests.mm
//  ClassDumpTests
//
//  Created by Leptos on 1/1/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../ClassDump/ClassDump.h"
#import "../ClassDump/Services/CDTypeParser.h"

@interface CDParseCppTests : XCTestCase

@end

@implementation CDParseCppTests

class User {
    char *name;
    unsigned level;
};
class SuperUser : User {
    unsigned permissions;
};

template<class _T>
class BinaryArray {
    _T inlineArray[2];
};

namespace ClassDump {
    class Chocolate {
        float cocoaPercent;
    };
}

- (void)testClass {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(SuperUser) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"struct SuperUser { char *x0; unsigned int x1; unsigned int x2; } var"]);
}

- (void)testGenerics {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(BinaryArray<User>) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"struct BinaryArray<User> { struct User { char *x0; unsigned int x1; } x0[2]; } var"]);
}

- (void)testNamespace {
    NSString *parsed = [CDTypeParser stringForEncoding:@encode(ClassDump::Chocolate) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"struct Chocolate { float x0; } var"]);
    
    parsed = [CDTypeParser stringForEncoding:@encode(BinaryArray<ClassDump::Chocolate>) variable:@"var"];
    XCTAssert([parsed isEqualToString:@"struct BinaryArray<ClassDump::Chocolate> { "
               "struct Chocolate { float x0; } x0[2]; } var"]);
}

@end
