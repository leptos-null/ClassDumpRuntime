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

@property (nonatomic, readonly) objc_property_t backing;

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSString *type;

@property (strong, nonatomic, readonly) NSArray<NSString *> *attributes;

@property (strong, nonatomic, readonly) NSString *iVar;
@property (strong, nonatomic, readonly) NSString *getter;
@property (strong, nonatomic, readonly) NSString *setter;

- (instancetype)initWithProperty:(objc_property_t)property isClass:(BOOL)isClass;
+ (instancetype)modelWithProperty:(objc_property_t)property isClass:(BOOL)isClass;

- (void)overrideType:(NSString *)type;

@end
