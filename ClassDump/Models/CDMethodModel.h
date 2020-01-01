//
//  CDMethodModel.h
//  ClassDump
//
//  Created by Leptos on 4/7/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface CDMethodModel : NSObject
/// The Obj-C runtime @c objc_method_description
@property (nonatomic, readonly) struct objc_method_description backing;
/// The signature of the method, e.g. @c initWithMethod:isClass:
@property (strong, nonatomic, readonly) NSString *name;
/// The types of the arguments to the method, e.g. @c [id, @c BOOL]
@property (strong, nonatomic, readonly) NSArray<NSString *> *argumentTypes;
/// The return type of the method
@property (strong, nonatomic, readonly) NSString *returnType;
/// If the method is a class method, otherwise an instance method
@property (nonatomic, readonly) BOOL isClass;

- (instancetype)initWithMethod:(struct objc_method_description)methd isClass:(BOOL)isClass;
+ (instancetype)modelWithMethod:(struct objc_method_description)methd isClass:(BOOL)isClass;

@end
