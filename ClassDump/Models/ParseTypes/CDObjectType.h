//
//  CDObjectType.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import <ClassDump/CDParseType.h>

/// Type representing an Objective-C object
@interface CDObjectType : CDParseType
/// The name of the class of the object
///
/// If this value is @c nil the type is @c id
@property (nullable, strong, nonatomic) NSString *className;
/// The names of the protocols the object conforms to
@property (nullable, strong, nonatomic) NSArray<NSString *> *protocolNames;

@end
