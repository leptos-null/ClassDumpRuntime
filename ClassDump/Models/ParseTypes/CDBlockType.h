//
//  CDBlockType.h
//  ClassDump
//
//  Created by Leptos on 12/15/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#if SWIFT_PACKAGE
#import "CDParseType.h"
#else
#import <ClassDump/CDParseType.h>
#endif

/// Type representing a block
@interface CDBlockType : CDParseType
/// The type that this block returns
@property (nullable, strong, nonatomic) CDParseType *returnType;
/// The types of the parameters to this block
@property (nullable, strong, nonatomic) NSArray<CDParseType *> *parameterTypes;

@end
