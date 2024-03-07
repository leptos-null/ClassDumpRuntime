//
//  CDPointerType.h
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

/// Type representing a pointer
@interface CDPointerType : CDParseType
/// The type that this pointer points to
@property (nullable, strong, nonatomic) CDParseType *pointee;

+ (nonnull instancetype)pointerToPointee:(nonnull CDParseType *)pointee;

@end
