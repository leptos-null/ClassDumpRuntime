//
//  CDProtocolModel.h
//  ClassDump
//
//  Created by Leptos on 4/7/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDPropertyModel.h"
#import "CDMethodModel.h"

@interface CDProtocolModel : NSObject

@property (strong, nonatomic, readonly) Protocol *backing;

@property (strong, nonatomic, readonly) NSString *name;

@property (strong, nonatomic, readonly) NSArray<CDProtocolModel *> *protocols;

@property (strong, nonatomic, readonly) NSArray<CDPropertyModel *> *requiredClassProperties;
@property (strong, nonatomic, readonly) NSArray<CDPropertyModel *> *requiredInstanceProperties;

@property (strong, nonatomic, readonly) NSArray<CDMethodModel *> *requiredClassMethods;
@property (strong, nonatomic, readonly) NSArray<CDMethodModel *> *requiredInstanceMethods;

@property (strong, nonatomic, readonly) NSArray<CDPropertyModel *> *optionalClassProperties;
@property (strong, nonatomic, readonly) NSArray<CDPropertyModel *> *optionalInstanceProperties;

@property (strong, nonatomic, readonly) NSArray<CDMethodModel *> *optionalClassMethods;
@property (strong, nonatomic, readonly) NSArray<CDMethodModel *> *optionalInstanceMethods;

- (instancetype)initWithProtocol:(Protocol *)prcl;
+ (instancetype)modelWithProtocol:(Protocol *)prcl;

- (NSString *)linesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip;

@end
