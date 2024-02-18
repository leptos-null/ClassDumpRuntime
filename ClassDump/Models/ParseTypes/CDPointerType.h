//
//  CDPointerType.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import <ClassDump/CDParseType.h>

/// Type representing a pointer
@interface CDPointerType : CDParseType
/// The type that this pointer points to
@property (nullable, strong, nonatomic) CDParseType *pointee;

+ (nonnull instancetype)pointerToPointee:(nonnull CDParseType *)pointee;

@end
