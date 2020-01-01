//
//  CDClassModel.h
//  ClassDump
//
//  Created by Leptos on 4/7/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDIvarModel.h"
#import "CDPropertyModel.h"
#import "CDMethodModel.h"
#import "CDProtocolModel.h"

@interface CDClassModel : NSObject
/// The Obj-C runtime @c Class
@property (weak, nonatomic, readonly) Class backing;
/// The name of the class, e.g. @c NSObject
@property (strong, nonatomic, readonly) NSString *name;
/// The protocols the class conforms to
@property (strong, nonatomic, readonly) NSArray<CDProtocolModel *> *protocols;

@property (strong, nonatomic, readonly) NSArray<CDPropertyModel *> *classProperties;
@property (strong, nonatomic, readonly) NSArray<CDPropertyModel *> *instanceProperties;

@property (strong, nonatomic, readonly) NSArray<CDMethodModel *> *classMethods;
@property (strong, nonatomic, readonly) NSArray<CDMethodModel *> *instanceMethods;
/// Instance variables, including values synthesized from properties
@property (strong, nonatomic, readonly) NSArray<CDIvarModel *> *ivars;

- (instancetype)initWithClass:(Class)cls;
+ (instancetype)modelWithClass:(Class)cls;
/// Generate an @c interface for the class
/// @param comments Generate comments with information such as the
///   image or category the declaration was found in
/// @param synthesizeStrip Remove methods and ivars synthesized from properties
- (NSString *)linesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip;

@end
