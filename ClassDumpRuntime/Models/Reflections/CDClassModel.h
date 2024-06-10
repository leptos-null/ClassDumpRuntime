//
//  CDClassModel.h
//  ClassDumpRuntime
//
//  Created by Leptos on 4/7/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ClassDumpRuntime/CDIvarModel.h>
#import <ClassDumpRuntime/CDPropertyModel.h>
#import <ClassDumpRuntime/CDMethodModel.h>
#import <ClassDumpRuntime/CDProtocolModel.h>
#import <ClassDumpRuntime/CDGenerationOptions.h>

NS_HEADER_AUDIT_BEGIN(nullability)

@interface CDClassModel : NSObject
// the Class property must be unsafe_unretained because not all
// classes can be stored with either a strong or weak reference
/// The Obj-C runtime @c Class
@property (unsafe_unretained, nonatomic, readonly) Class backing;
/// The name of the class, e.g. @c NSObject
@property (strong, nonatomic, readonly) NSString *name;
/// The protocols the class conforms to
@property (strong, nonatomic, readonly, nullable) NSArray<CDProtocolModel *> *protocols;

@property (strong, nonatomic, readonly, nullable) NSArray<CDPropertyModel *> *classProperties;
@property (strong, nonatomic, readonly, nullable) NSArray<CDPropertyModel *> *instanceProperties;

@property (strong, nonatomic, readonly, nullable) NSArray<CDMethodModel *> *classMethods;
@property (strong, nonatomic, readonly, nullable) NSArray<CDMethodModel *> *instanceMethods;
/// Instance variables, including values synthesized from properties
@property (strong, nonatomic, readonly, nullable) NSArray<CDIvarModel *> *ivars;

- (instancetype)initWithClass:(Class)cls;
+ (instancetype)modelWithClass:(Class)cls;

/// Generate an @c interface for the class
/// @param comments Generate comments with information such as the
///   image or category the declaration was found in
/// @param synthesizeStrip Remove methods and ivars synthesized from properties
- (NSString *)linesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip;
/// Generate an @c interface for the class
/// @param comments Generate comments with information such as the
///   image or category the declaration was found in
/// @param synthesizeStrip Remove methods and ivars synthesized from properties
- (CDSemanticString *)semanticLinesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip;

/// Generate an @c interface for the class
- (CDSemanticString *)semanticLinesWithOptions:(CDGenerationOptions *)options NS_REFINED_FOR_SWIFT;

/// Classes the class references in the declaration
///
/// In other words, all the classes that the compiler would need to see
/// for the header to pass the type checking stage of compilation.
- (NSSet<NSString *> *)classReferences;
/// Protocols the class references in the declaration
///
/// In other words, all the protocols that the compiler would need to see
/// for the header to pass the type checking stage of compilation.
- (NSSet<NSString *> *)protocolReferences;

@end

NS_HEADER_AUDIT_END(nullability)
