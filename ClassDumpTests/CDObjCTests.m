//
//  CDObjCTests.m
//  ClassDumpTests
//
//  Created by Leptos on 1/23/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../ClassDump/ClassDump.h"
#import "../ClassDump/Services/CDTypeParser.h"

@interface CDObjCTests : XCTestCase

@end

@protocol CDDemoProtocol <NSObject>
@optional
- (void)happening;
@required
- (void)happenedWithError:(NSError *)error;
@end

@interface CDDemoClass : NSObject <CDDemoProtocol>

@property (class, getter=isFun) BOOL fun;

@property (nonatomic) NSString *charlie;

- (id)alfa:(int *const *)alfa error:(inout id *)err;

@end

@implementation CDDemoClass

+ (BOOL)isFun {
    return YES;
}
+ (void)setFun:(BOOL)fun {
    NSParameterAssert(fun);
}
- (id)alfa:(int *const *)alfa error:(inout id *)err {
    return nil;
}

- (void)happenedWithError:(NSError *)error {
}

@end

@implementation CDObjCTests {
    CDClassModel *_model;
}

- (void)setUp {
    _model = [CDClassModel modelWithClass:[CDDemoClass class]];
}

- (void)testClass {
    XCTAssert([_model.name isEqualToString:@"CDDemoClass"]);
    XCTAssert(_model.protocols.count == 1);
    XCTAssert(_model.classProperties.count == 1);
    XCTAssert(_model.ivars.count == 1);
    XCTAssert(_model.classMethods.count == 2);
}

- (void)testProtocol {
    CDProtocolModel *protocol = _model.protocols.firstObject;
    XCTAssert([protocol.name isEqualToString:@"CDDemoProtocol"]);
    XCTAssert(protocol.requiredClassMethods.count == 0);
    XCTAssert(protocol.requiredInstanceMethods.count == 1);
    XCTAssert(protocol.optionalClassMethods.count == 0);
    XCTAssert(protocol.optionalInstanceMethods.count == 1);
}

- (void)testClassProperty {
    CDPropertyModel *clsProp = _model.classProperties.firstObject;
    XCTAssert([clsProp.name isEqualToString:@"fun"]);
    XCTAssert(clsProp.iVar == nil);
    XCTAssert([clsProp.getter isEqualToString:@"isFun"]);
    XCTAssert([clsProp.setter isEqualToString:@"setFun:"]);
}

- (void)testInstanceProperty {
    CDPropertyModel *instProp = _model.instanceProperties.firstObject;
    XCTAssert([instProp.name isEqualToString:@"charlie"]);
    XCTAssert([instProp.iVar isEqualToString:@"_charlie"]);
    XCTAssert([instProp.getter isEqualToString:@"charlie"]);
    XCTAssert([instProp.setter isEqualToString:@"setCharlie:"]);
    XCTAssert([instProp.type isEqualToString:@"NSString *charlie"]);
}

- (void)testMethod {
    BOOL found = NO;
    for (CDMethodModel *mthd in _model.instanceMethods) {
        if ([mthd.name isEqualToString:@"alfa:error:"]) {
            XCTAssert(!found, @"Found method multiple times");
            found = YES;
            
            XCTAssert([mthd.argumentTypes[0] isEqualToString:@"int **"]);
            XCTAssert([mthd.argumentTypes[1] isEqualToString:@"inout id *"]);
            XCTAssert([mthd.returnType isEqualToString:@"id"]);
            XCTAssert(!mthd.isClass);
        }
    }
    XCTAssert(found, @"Failed to find method");
}

- (void)testIvar {
    CDIvarModel *ivar = _model.ivars.firstObject;
    XCTAssert([ivar.name isEqualToString:@"_charlie"]);
    XCTAssert([ivar.line isEqualToString:@"NSString *_charlie"]);
}

@end
