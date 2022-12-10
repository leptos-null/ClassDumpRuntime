//
//  CDPointerType.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDParseType.h"

/// Type representing a pointer
@interface CDPointerType : CDParseType
/// The type that this pointer points to
@property (strong, nonatomic) CDParseType *pointee;

@end
