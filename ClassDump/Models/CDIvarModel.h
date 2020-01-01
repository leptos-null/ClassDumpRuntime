//
//  CDIvarModel.h
//  ClassDump
//
//  Created by Leptos on 4/8/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface CDIvarModel : NSObject
/// The Obj-C runtime @c Ivar
@property (nonatomic, readonly) Ivar backing;
/// The name of the ivar, e.g. @c _name
@property (strong, nonatomic, readonly) NSString *name;
/// The declaration of the ivar, not including leading space or a trailing semicolon
@property (strong, nonatomic, readonly) NSString *line;

- (instancetype)initWithIvar:(Ivar)ivar;
+ (instancetype)modelWithIvar:(Ivar)ivar;

@end
