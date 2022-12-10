//
//  CDRecordType.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import "CDParseType.h"
#import "CDVariableModel.h"

/// Type representing a @c struct or @c union
@interface CDRecordType : CDParseType
/// The fields of the record
@property (strong, nonatomic) NSArray<CDVariableModel *> *fields;
/// @c YES if the receiver represents a @c union
/// otherwise the receiver represents a @c struct
@property (nonatomic) BOOL isUnion;

@end
