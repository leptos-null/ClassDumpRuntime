//
//  CDGenerationOptions.h
//  ClassDump
//
//  Created by Leptos on 2/25/24.
//  Copyright © 2024 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Options with which a header file may be generated with
@interface CDGenerationOptions : NSObject
/// @c YES means hide properties and methods that are required by a protocol the type conforms to
///
/// This property applies to both classes and protocols.
@property (nonatomic) BOOL stripProtocolConformance;
/// @c YES means hide properties and methods that are inherited from the class hierachy
///
/// This property only applies to classes. Protocols can require conformances to other
/// protocols, however they do not have inheritance.
/// Eligible properties are only hidden if the types match between the property in the
/// current class and class nearest in the hierachy.
/// For example, if `AAView` has a property `AALayer *layer`
/// and a subclass `BBView` has a property `BBLayer *layer`,
/// the property would not be hidden since the types are different.
/// @see stripProtocolConformance
@property (nonatomic) BOOL stripOverrides;
/// @c YES means hide duplicate occurrences of a property or method,
/// @c NO means transcribe the objects reported by the runtime
@property (nonatomic) BOOL stripDuplicates;
/// @c YES means hide methods and ivars that are synthesized from a property
///
/// This property applies to both classes and protocols.
@property (nonatomic) BOOL stripSynthesized;
/// @c YES means hide @c .cxx_construct method,
/// @c NO means show the method if it exists
///
/// This property only applies to classes.
@property (nonatomic) BOOL stripCtorMethod;
/// @c YES means hide @c .cxx_destruct method,
/// @c NO means show the method if it exists
///
/// This property only applies to classes.
@property (nonatomic) BOOL stripDtorMethod;
/// @c YES means add comments above each eligible declaration
/// with the symbol name and image path the object is found in,
/// @c NO means do not add comments for symbol or image source
///
/// This property applies to both classes and protocols.
@property (nonatomic) BOOL addSymbolImageComments;

@end
