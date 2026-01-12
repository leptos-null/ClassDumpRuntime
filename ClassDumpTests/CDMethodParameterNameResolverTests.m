//
//  CDMethodParameterNameResolverTests.m
//  ClassDumpTests
//
//  Created by Leptos on 1/11/26.
//  Copyright © 2026 Leptos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ClassDump/ClassDump.h>

@interface CDMethodParameterNameResolverTests : XCTestCase

@end

@implementation CDMethodParameterNameResolverTests

- (void)testTransformWriteToURL {
    NSArray<NSString *> *selectorComponents = @[
        @"writeToURL",
        @"error"
    ];
    
    CDMethodParameterNameResolver const resolver = CDMethodParameterNameSimpleTransformResolver;
    XCTAssert([resolver(selectorComponents, 0) isEqualToString:@"url"]);
    XCTAssert([resolver(selectorComponents, 1) isEqualToString:@"error"]);
}

@end
