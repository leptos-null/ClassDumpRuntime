//
//  CDProtocolModel.h
//  ClassDumpRuntime
//
//  Created by Leptos on 4/7/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ClassDumpRuntime/CDPropertyModel.h>
#import <ClassDumpRuntime/CDMethodModel.h>
#import <ClassDumpRuntime/CDGenerationOptions.h>

NS_HEADER_AUDIT_BEGIN(nullability)

@interface CDProtocolModel : NSObject
/// The Obj-C runtime @c Protocol
@property (strong, nonatomic, readonly) Protocol *backing;
/// The name of the protocol, e.g. @c NSObject
@property (strong, nonatomic, readonly) NSString *name;
/// The protocols the protocol conforms to
@property (strong, nonatomic, readonly, nullable) NSArray<CDProtocolModel *> *protocols;

@property (strong, nonatomic, readonly, nullable) NSArray<CDPropertyModel *> *requiredClassProperties;
@property (strong, nonatomic, readonly, nullable) NSArray<CDPropertyModel *> *requiredInstanceProperties;

@property (strong, nonatomic, readonly, nullable) NSArray<CDMethodModel *> *requiredClassMethods;
@property (strong, nonatomic, readonly, nullable) NSArray<CDMethodModel *> *requiredInstanceMethods;

@property (strong, nonatomic, readonly, nullable) NSArray<CDPropertyModel *> *optionalClassProperties;
@property (strong, nonatomic, readonly, nullable) NSArray<CDPropertyModel *> *optionalInstanceProperties;

@property (strong, nonatomic, readonly, nullable) NSArray<CDMethodModel *> *optionalClassMethods;
@property (strong, nonatomic, readonly, nullable) NSArray<CDMethodModel *> *optionalInstanceMethods;

- (instancetype)initWithProtocol:(Protocol *)prcl;
+ (instancetype)modelWithProtocol:(Protocol *)prcl;

/// Generate an @c interface for the protocol
/// @param comments Generate comments with information such as the
///   image the declaration was found in
/// @param synthesizeStrip Remove methods and ivars synthesized from properties
- (NSString *)linesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip;
/// Generate an @c interface for the protocol
/// @param comments Generate comments with information such as the
///   image the declaration was found in
/// @param synthesizeStrip Remove methods and ivars synthesized from properties
- (CDSemanticString *)semanticLinesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip;

/// Generate an @c interface for the protocol
- (CDSemanticString *)semanticLinesWithOptions:(CDGenerationOptions *)options;

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


NS_HEADER_AUDIT_END(nullability)
