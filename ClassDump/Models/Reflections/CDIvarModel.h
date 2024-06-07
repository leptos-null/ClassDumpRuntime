//
//  CDIvarModel.h
//  ClassDump
//
//  Created by Leptos on 4/8/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import <ClassDump/CDParseType.h>

NS_HEADER_AUDIT_BEGIN(nullability)

@interface CDIvarModel : NSObject
/// The Obj-C runtime @c Ivar
@property (nonatomic, readonly) Ivar backing;
/// The name of the ivar, e.g. @c _name
@property (strong, nonatomic, readonly) NSString *name;
/// The type of the ivar
@property (strong, nonatomic, readonly) CDParseType *type;

- (instancetype)initWithIvar:(Ivar)ivar;
+ (instancetype)modelWithIvar:(Ivar)ivar;

- (CDSemanticString *)semanticString;

@end

NS_HEADER_AUDIT_END(nullability)
