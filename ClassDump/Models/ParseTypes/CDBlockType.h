//
//  CDBlockType.h
//  ClassDump
//
//  Created by Leptos on 12/15/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import <ClassDump/CDParseType.h>

NS_HEADER_AUDIT_BEGIN(nullability)

/// Type representing a block
@interface CDBlockType : CDParseType
/// The type that this block returns
@property (nullable, strong, nonatomic) CDParseType *returnType;
/// The types of the parameters to this block
@property (nullable, strong, nonatomic) NSArray<CDParseType *> *parameterTypes;

@end

NS_HEADER_AUDIT_END(nullability)
