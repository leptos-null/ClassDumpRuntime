//
//  CDPropertyModel.h
//  ClassDump
//
//  Created by Leptos on 3/24/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface CDPropertyModel : NSObject
/// The Obj-C runtime @c objc_property_t
@property (nonatomic, readonly) objc_property_t backing;
/// The name of the property, e.g. @c name
@property (strong, nonatomic, readonly) NSString *name;
/// The type of the property including the name, e.g. @c NSString @c *type
@property (strong, nonatomic, readonly) NSString *type;
/// The attributes of the property, e.g. @c strong, @c nonatomic, @c readonly
@property (strong, nonatomic, readonly) NSArray<NSString *> *attributes;
/// The name of the backing instance variable
@property (strong, nonatomic, readonly) NSString *iVar;
/// The signature of the getter method, e.g. @c count
@property (strong, nonatomic, readonly) NSString *getter;
/// The signature of the setter method, e.g. @c setName:
@property (strong, nonatomic, readonly) NSString *setter;

- (instancetype)initWithProperty:(objc_property_t)property isClass:(BOOL)isClass;
+ (instancetype)modelWithProperty:(objc_property_t)property isClass:(BOOL)isClass;

/// Override the @c type of the property.
/// Used when the corresponding ivar is found with more type information;
/// e.g. An ivar may know the type is @c NSString @c *
/// however the property only has @c id as the type
- (void)overrideType:(NSString *)type;

@end
