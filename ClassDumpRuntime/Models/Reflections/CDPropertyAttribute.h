//
//  CDPropertyAttribute.h
//  ClassDumpRuntime
//
//  Created by Leptos on 1/6/23.
//  Copyright © 2023 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_HEADER_AUDIT_BEGIN(nullability)

@interface CDPropertyAttribute : NSObject
/// The name of a property attribute, e.g. @c strong, @c nonatomic, @c getter
@property (strong, nonatomic, readonly) NSString *name;
/// The value of a property attribute, e.g. the method name for @c getter= or @c setter=
@property (strong, nonatomic, readonly, nullable) NSString *value;

- (instancetype)initWithName:(NSString *)name value:(nullable NSString *)value;
+ (instancetype)attributeWithName:(NSString *)name value:(nullable NSString *)value;

@end

NS_HEADER_AUDIT_END(nullability)
