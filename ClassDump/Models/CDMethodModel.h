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

@property (nonatomic, readonly) struct objc_method_description backing;

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSArray<NSString *> *argumentTypes;

@property (strong, nonatomic, readonly) NSString *returnType;

@property (nonatomic, readonly) BOOL isClass;

- (instancetype)initWithMethod:(struct objc_method_description)methd isClass:(BOOL)isClass;
+ (instancetype)modelWithMethod:(struct objc_method_description)methd isClass:(BOOL)isClass;

@end
