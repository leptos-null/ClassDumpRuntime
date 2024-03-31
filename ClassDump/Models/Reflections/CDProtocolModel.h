//
//  CDProtocolModel.h
//  ClassDump
//
//  Created by Leptos on 4/7/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !__has_include(<ClassDump/ClassDump.h>)
#import "CDPropertyModel.h"
#import "CDMethodModel.h"
#else
#import <ClassDump/CDPropertyModel.h>
#import <ClassDump/CDMethodModel.h>
#endif

@interface CDProtocolModel : NSObject
/// The Obj-C runtime @c Protocol
@property (strong, nonatomic, readonly) Protocol *backing;
/// The name of the protocol, e.g. @c NSObject
@property (strong, nonatomic, readonly) NSString *name;
/// The protocols the protocol conforms to
@property (strong, nonatomic, readonly) NSArray<CDProtocolModel *> *protocols;

@property (strong, nonatomic, readonly) NSArray<CDPropertyModel *> *requiredClassProperties;
@property (strong, nonatomic, readonly) NSArray<CDPropertyModel *> *requiredInstanceProperties;

@property (strong, nonatomic, readonly) NSArray<CDMethodModel *> *requiredClassMethods;
@property (strong, nonatomic, readonly) NSArray<CDMethodModel *> *requiredInstanceMethods;

@property (strong, nonatomic, readonly) NSArray<CDPropertyModel *> *optionalClassProperties;
@property (strong, nonatomic, readonly) NSArray<CDPropertyModel *> *optionalInstanceProperties;

@property (strong, nonatomic, readonly) NSArray<CDMethodModel *> *optionalClassMethods;
@property (strong, nonatomic, readonly) NSArray<CDMethodModel *> *optionalInstanceMethods;

- (instancetype)initWithProtocol:(Protocol *)prcl;
+ (instancetype)modelWithProtocol:(Protocol *)prcl;

/// Generate an @c interface for the protocol
/// @param comments Generate comments with information such as the
///   image the declaration was found in
/// @param synthesizeStrip Remove methods and ivars synthesized from properties
- (NSString *)linesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip;

- (CDSemanticString *)semanticLinesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip;

/// Classes the protocol references in the declaration
///
/// In other words, all the classes that the compiler would need to see
/// for the header to pass the type checking stage of compilation.
- (NSSet<NSString *> *)classReferences;
/// Protocols the protocol references in the declaration
///
/// In other words, all the protocols that the compiler would need to see
/// for the header to pass the type checking stage of compilation.
- (NSSet<NSString *> *)protocolReferences;

@end
