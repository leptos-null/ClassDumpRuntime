//
//  CDObjCTests.m
//  ClassDumpTests
//
//  Created by Leptos on 1/23/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ClassDump/ClassDump.h>

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

@property (weak, nonatomic) id<NSCacheDelegate> cacheDelegate;
@property (nonatomic) id<NSProgressReporting, NSFastEnumeration> progressReportingEnumeration;
@property (nonatomic) NSUUID<NSMutableCopying, NSFastEnumeration> *mutableUUID;
@property (weak, nonatomic) NSURL<NSDiscardableContent> *discardableURL;

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
    XCTAssert(_model.classMethods.count == 2);
    XCTAssert(_model.ivars.count == 5);
}

- (void)testProtocol {
    CDProtocolModel *protocol = _model.protocols.firstObject;
    XCTAssert([protocol.name isEqualToString:@"CDDemoProtocol"]);
    
    NSArray<CDMethodModel *> *requiredInstanceMethods = protocol.requiredInstanceMethods;
    NSArray<CDMethodModel *> *optionalInstanceMethods = protocol.optionalInstanceMethods;
    
    XCTAssert(protocol.requiredClassMethods.count == 0);
    XCTAssert(requiredInstanceMethods.count == 1);
    XCTAssert(protocol.optionalClassMethods.count == 0);
    XCTAssert(optionalInstanceMethods.count == 1);
    
    CDMethodModel *requiredInstanceMethod = requiredInstanceMethods.firstObject;
    XCTAssert([requiredInstanceMethod.name isEqualToString:@"happenedWithError:"]);
    XCTAssert(requiredInstanceMethod.argumentTypes.count == 1);
    XCTAssert([[requiredInstanceMethod.argumentTypes[0] stringForVariableName:nil] isEqualToString:@"id"]);
    XCTAssert(!requiredInstanceMethod.isClass);
    
    CDMethodModel *optionalInstanceMethod = optionalInstanceMethods.firstObject;
    XCTAssert([optionalInstanceMethod.name isEqualToString:@"happening"]);
    XCTAssert(optionalInstanceMethod.argumentTypes.count == 0);
    XCTAssert(!optionalInstanceMethod.isClass);
}

- (void)testClassProperty {
    CDPropertyModel *clsProp = _model.classProperties.firstObject;
    XCTAssert([clsProp.name isEqualToString:@"fun"]);
    XCTAssert(clsProp.iVar == nil);
    XCTAssert([clsProp.getter isEqualToString:@"isFun"]);
    XCTAssert([clsProp.setter isEqualToString:@"setFun:"]);
}

- (void)testInstanceProperty {
    BOOL found = NO;
    for (CDPropertyModel *prop in _model.instanceProperties) {
        if ([prop.name isEqualToString:@"charlie"]) {
            XCTAssert(!found, @"Found property multiple times");
            found = YES;
            
            XCTAssert([prop.iVar isEqualToString:@"_charlie"]);
            XCTAssert([prop.getter isEqualToString:@"charlie"]);
            XCTAssert([prop.setter isEqualToString:@"setCharlie:"]);
            XCTAssert([[prop.type stringForVariableName:prop.name] isEqualToString:@"NSString *charlie"]);
        }
    }
    XCTAssert(found, @"Failed to find property");
}

- (void)testPropertyProtocols {
    for (CDPropertyModel *prop in _model.instanceProperties) {
        if ([prop.name isEqualToString:@"charlie"]) {
            XCTAssert([[prop.type stringForVariableName:prop.name] isEqualToString:@"NSString *charlie"]);
        } else if ([prop.name isEqualToString:@"cacheDelegate"]) {
            XCTAssert([[prop.type stringForVariableName:prop.name] isEqualToString:@"id<NSCacheDelegate> cacheDelegate"]);
        } else if ([prop.name isEqualToString:@"progressReportingEnumeration"]) {
            XCTAssert([[prop.type stringForVariableName:prop.name] isEqualToString:@"id<NSProgressReporting, NSFastEnumeration> progressReportingEnumeration"]);
        } else if ([prop.name isEqualToString:@"mutableUUID"]) {
            XCTAssert([[prop.type stringForVariableName:prop.name] isEqualToString:@"NSUUID<NSMutableCopying, NSFastEnumeration> *mutableUUID"]);
        } else if ([prop.name isEqualToString:@"discardableURL"]) {
            XCTAssert([[prop.type stringForVariableName:prop.name] isEqualToString:@"NSURL<NSDiscardableContent> *discardableURL"]);
        }
    }
}

- (void)testMethod {
    BOOL found = NO;
    for (CDMethodModel *mthd in _model.instanceMethods) {
        if ([mthd.name isEqualToString:@"alfa:error:"]) {
            XCTAssert(!found, @"Found method multiple times");
            found = YES;
            
            XCTAssert(mthd.argumentTypes.count == 2);
            XCTAssert([[mthd.argumentTypes[0] stringForVariableName:nil] isEqualToString:@"int **"]);
            XCTAssert([[mthd.argumentTypes[1] stringForVariableName:nil] isEqualToString:@"inout id *"]);
            XCTAssert([[mthd.returnType stringForVariableName:nil] isEqualToString:@"id"]);
            XCTAssert(!mthd.isClass);
        }
    }
    XCTAssert(found, @"Failed to find method");
}

- (void)testIvar {
    BOOL found = NO;
    for (CDIvarModel *ivar in _model.ivars) {
        if ([ivar.name isEqualToString:@"_charlie"]) {
            XCTAssert(!found, @"Found ivar multiple times");
            found = YES;
            
            XCTAssert([[ivar.type stringForVariableName:ivar.name] isEqualToString:@"NSString *_charlie"]);
        }
    }
    XCTAssert(found, @"Failed to find ivar");
}

@end
