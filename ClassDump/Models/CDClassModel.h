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

@property (weak, nonatomic, readonly) Class backing;

@property (strong, nonatomic, readonly) NSString *name;

@property (strong, nonatomic, readonly) NSArray<CDProtocolModel *> *protocols;

@property (strong, nonatomic, readonly) NSArray<CDPropertyModel *> *classProperties;
@property (strong, nonatomic, readonly) NSArray<CDPropertyModel *> *instanceProperties;

@property (strong, nonatomic, readonly) NSArray<CDMethodModel *> *classMethods;
@property (strong, nonatomic, readonly) NSArray<CDMethodModel *> *instanceMethods;

@property (strong, nonatomic, readonly) NSArray<CDIvarModel *> *ivars;

- (instancetype)initWithClass:(Class)cls;
+ (instancetype)modelWithClass:(Class)cls;

- (NSString *)linesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip;

@end
