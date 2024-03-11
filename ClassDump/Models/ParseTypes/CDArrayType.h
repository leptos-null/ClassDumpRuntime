//
//  CDArrayType.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#if SWIFT_PACKAGE
#import "CDParseType.h"
#else
#import <ClassDump/CDParseType.h>
#endif

/// Type representing a C array
@interface CDArrayType : CDParseType
/// Type of elements in the array
@property (strong, nonatomic) CDParseType *type;
/// Number of elements in the array
@property (nonatomic) NSUInteger size;

@end
