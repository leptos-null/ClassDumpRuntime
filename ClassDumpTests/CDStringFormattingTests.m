//
//  CDStringFormattingTests.m
//  ClassDumpTests
//
//  Created by Leptos on 1/3/26.
//  Copyright © 2026 Leptos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../ClassDump/Services/CDStringFormatting.h"

@interface CDStringFormattingTests : XCTestCase

@end

@implementation CDStringFormattingTests

- (void)testSingleDigit {
    XCTAssert([NSStringFromNSUInteger(0) isEqualToString:@"0"]);
    XCTAssert([NSStringFromNSUInteger(1) isEqualToString:@"1"]);
    XCTAssert([NSStringFromNSUInteger(2) isEqualToString:@"2"]);
    XCTAssert([NSStringFromNSUInteger(3) isEqualToString:@"3"]);
    XCTAssert([NSStringFromNSUInteger(4) isEqualToString:@"4"]);
    XCTAssert([NSStringFromNSUInteger(5) isEqualToString:@"5"]);
    XCTAssert([NSStringFromNSUInteger(6) isEqualToString:@"6"]);
    XCTAssert([NSStringFromNSUInteger(7) isEqualToString:@"7"]);
    XCTAssert([NSStringFromNSUInteger(8) isEqualToString:@"8"]);
    XCTAssert([NSStringFromNSUInteger(9) isEqualToString:@"9"]);
}

- (void)testDoubleDigit {
    XCTAssert([NSStringFromNSUInteger(10) isEqualToString:@"10"]);
    XCTAssert([NSStringFromNSUInteger(11) isEqualToString:@"11"]);
    XCTAssert([NSStringFromNSUInteger(12) isEqualToString:@"12"]);
    XCTAssert([NSStringFromNSUInteger(13) isEqualToString:@"13"]);
    XCTAssert([NSStringFromNSUInteger(14) isEqualToString:@"14"]);
    XCTAssert([NSStringFromNSUInteger(15) isEqualToString:@"15"]);
    XCTAssert([NSStringFromNSUInteger(16) isEqualToString:@"16"]);
    XCTAssert([NSStringFromNSUInteger(17) isEqualToString:@"17"]);
    XCTAssert([NSStringFromNSUInteger(18) isEqualToString:@"18"]);
    XCTAssert([NSStringFromNSUInteger(19) isEqualToString:@"19"]);
}

- (void)testBaseMultiple {
    XCTAssert([NSStringFromNSUInteger(100) isEqualToString:@"100"]);
    XCTAssert([NSStringFromNSUInteger(1000) isEqualToString:@"1000"]);
    XCTAssert([NSStringFromNSUInteger(10000000) isEqualToString:@"10000000"]);
}

- (void)testRandom {
    // random number
    XCTAssert([NSStringFromNSUInteger(1113096422) isEqualToString:@"1113096422"]);
}

- (void)testMax {
    NSUInteger const max = -1;
#if __LP64__ || NS_BUILD_32_LIKE_64
    XCTAssertEqual(max, 18446744073709551615ul);
    XCTAssert([NSStringFromNSUInteger(max) isEqualToString:@"18446744073709551615"]);
#else
    XCTAssertEqual(max, 4294967295u);
    XCTAssert([NSStringFromNSUInteger(max) isEqualToString:@"4294967295"]);
#endif
}

- (void)testMaxMinusOne {
    NSUInteger const maxMinusOne = -2;
#if __LP64__ || NS_BUILD_32_LIKE_64
    XCTAssertEqual(maxMinusOne, 18446744073709551614ul);
    XCTAssert([NSStringFromNSUInteger(maxMinusOne) isEqualToString:@"18446744073709551614"]);
#else
    XCTAssertEqual(maxMinusOne, 4294967294u);
    XCTAssert([NSStringFromNSUInteger(maxMinusOne) isEqualToString:@"4294967294"]);
#endif
}

@end
