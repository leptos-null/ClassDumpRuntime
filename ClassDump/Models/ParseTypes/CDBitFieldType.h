//
//  CDBitFieldType.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import <ClassDump/CDParseType.h>

NS_HEADER_AUDIT_BEGIN(nullability)

/// Type representing a bit-field in a record
@interface CDBitFieldType : CDParseType
/// Width of the bit-fields (in bits)
@property (nonatomic) NSUInteger width;

@end

NS_HEADER_AUDIT_END(nullability)
