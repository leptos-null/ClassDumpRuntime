//
//  CDUtilities.h
//  ClassDump
//
//  Created by Leptos on 5/10/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDUtilities : NSObject

/// Attempts to find all mach-o images
+ (NSArray<NSString *> *)dynamicMachImages;

@end
