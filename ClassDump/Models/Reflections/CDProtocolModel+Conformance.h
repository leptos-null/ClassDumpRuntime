//
//  CDProtocolModel+Conformance.h
//  ClassDump
//
//  Created by Leptos on 3/3/24.
//  Copyright © 2024 Leptos. All rights reserved.
//

#import <ClassDump/CDProtocolModel.h>

@interface CDProtocolModel (Conformance)

/// The class properties required for a type conforming to the given protocols to provide
///
/// A property with a given name will only appear once in this collection.
+ (NSArray<CDPropertyModel *> *)requiredClassPropertiesToConform:(NSArray<CDProtocolModel *> *)protocols;
/// The instance properties required for a type conforming to the given protocols to provide
///
/// A property with a given name will only appear once in this collection.
+ (NSArray<CDPropertyModel *> *)requiredInstancePropertiesToConform:(NSArray<CDProtocolModel *> *)protocols;

/// The class methods required for a type conforming to the given protocols to provide
///
/// A method with a given selector will only appear once in this collection.
+ (NSArray<CDMethodModel *> *)requiredClassMethodsToConform:(NSArray<CDProtocolModel *> *)protocols;
/// The instance methods required for a type conforming to the given protocols to provide
///
/// A method with a given selector will only appear once in this collection.
+ (NSArray<CDMethodModel *> *)requiredInstanceMethodsToConform:(NSArray<CDProtocolModel *> *)protocols;

@end
