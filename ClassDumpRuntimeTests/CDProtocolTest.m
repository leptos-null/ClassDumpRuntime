//
//  CDProtocolTest.m
//  ClassDumpTests
//
//  Created by Leptos on 3/3/24.
//  Copyright © 2024 Leptos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ClassDumpRuntime/ClassDumpRuntime.h>

@interface CDProtocolTest : XCTestCase

@end

@protocol CDRandomProvider <NSObject>
- (id)randomValue;
@end

@protocol CDRollProvider <CDRandomProvider>
- (int)randomValue;
@end

@protocol CDRandomProbability <NSObject>
- (float)randomValue;
@end

// this class only exists so that we can see how
// the compiler handles these protocol conformances
@interface CDRollProbability : NSObject <CDRollProvider, CDRandomProbability>
@end

@implementation CDRollProbability
- (int)randomValue {
    return 0;
}
@end

// this class only exists so that we can see how
// the compiler handles these protocol conformances
@interface CDRandomRoll : NSObject <CDRandomProbability, CDRollProvider>
@end

@implementation CDRandomRoll
- (float)randomValue {
    return 0;
}
@end


@implementation CDProtocolTest

- (void)testRollProbability {
    CDClassModel *classModel = [CDClassModel modelWithClass:[CDRollProbability class]];
    NSArray<CDMethodModel *> *requiredMethods = [CDProtocolModel requiredInstanceMethodsToConform:classModel.protocols];
    XCTAssert(requiredMethods.count > 1);
    CDMethodModel *requiredMethod = requiredMethods[0];
    XCTAssert([requiredMethod.name isEqualToString:@"randomValue"]);
    
    CDParseType *returnType = requiredMethod.returnType;
    XCTAssert([returnType isMemberOfClass:[CDPrimitiveType class]]);
    CDPrimitiveType *primitiveReturnType = (__kindof CDParseType *)returnType;
    XCTAssert(primitiveReturnType.rawType == CDPrimitiveRawTypeInt);
}

- (void)testRandomRoll {
    CDClassModel *classModel = [CDClassModel modelWithClass:[CDRandomRoll class]];
    NSArray<CDMethodModel *> *requiredMethods = [CDProtocolModel requiredInstanceMethodsToConform:classModel.protocols];
    XCTAssert(requiredMethods.count > 1);
    CDMethodModel *requiredMethod = requiredMethods[0];
    XCTAssert([requiredMethod.name isEqualToString:@"randomValue"]);
    
    CDParseType *returnType = requiredMethod.returnType;
    XCTAssert([returnType isMemberOfClass:[CDPrimitiveType class]]);
    CDPrimitiveType *primitiveReturnType = (__kindof CDParseType *)returnType;
    XCTAssert(primitiveReturnType.rawType == CDPrimitiveRawTypeFloat);
}

@end
