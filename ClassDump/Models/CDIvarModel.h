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

@property (nonatomic, readonly) Ivar backing;

@property (strong, nonatomic, readonly) NSString *name;

@property (strong, nonatomic, readonly) NSString *line;

- (instancetype)initWithIvar:(Ivar)ivar;
+ (instancetype)modelWithIvar:(Ivar)ivar;

@end
