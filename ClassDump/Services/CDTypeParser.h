//
//  CDTypeParser.h
//  ClassDump
//
//  Created by Leptos on 3/24/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDTypeParser : NSObject

+ (NSString *)stringForEncoding:(const char *)encoding variable:(NSString *)varName;
+ (NSString *)stringForEncodingStart:(const char *)start end:(const char *)end variable:(NSString *)varName error:(BOOL *)error;

@end
