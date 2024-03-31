//
//  CDBitFieldType.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#if !__has_include(<ClassDump/ClassDump.h>)
#import "CDParseType.h"
#else
#import <ClassDump/CDParseType.h>
#endif

/// Type representing a bit-field in a record
@interface CDBitFieldType : CDParseType
/// Width of the bit-fields (in bits)
@property (nonatomic) NSUInteger width;

@end
