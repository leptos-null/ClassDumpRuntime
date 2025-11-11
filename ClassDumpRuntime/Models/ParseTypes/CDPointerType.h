//
//  CDPointerType.h
//  ClassDumpRuntime
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import <ClassDumpRuntime/CDParseType.h>

NS_HEADER_AUDIT_BEGIN(nullability)

/// Type representing a pointer
@interface CDPointerType : CDParseType
/// The type that this pointer points to
@property (nullable, strong, nonatomic) CDParseType *pointee;

+ (instancetype)pointerToPointee:(nonnull CDParseType *)pointee;

@end

NS_HEADER_AUDIT_END(nullability)
