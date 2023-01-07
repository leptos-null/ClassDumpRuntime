//
//  CDPropertyAttribute.h
//  ClassDump
//
//  Created by Leptos on 1/6/23.
//  Copyright © 2023 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDPropertyAttribute : NSObject
/// The name of a property attribute, e.g. @c strong, @c nonatomic, @c getter
@property (strong, nonatomic, readonly) NSString *name;
/// The value of a property attribute, e.g. the method name for @c getter= or @c setter=
@property (strong, nonatomic, readonly) NSString *value;

- (instancetype)initWithName:(NSString *)name value:(NSString *)value;
+ (instancetype)attributeWithName:(NSString *)name value:(NSString *)value;

@end
