//
//  CDTypeFormatOptions.h
//  ClassDump
//
//  Created by Leptos on 1/14/26.
//  Copyright © 2026 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDTypeFormatOptions : NSObject
/// The string to use for one level of indentation
///
/// If this value is @c nil a default string will be used.
@property (copy, nonatomic, nullable) NSString *indentString;
/// @c YES means each field of a record is on a separate line,
/// @c NO means an entire record is on one line
@property (nonatomic) BOOL multilineRecords;

@end
