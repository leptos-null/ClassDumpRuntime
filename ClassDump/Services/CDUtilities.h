//
//  CDUtilities.h
//  ClassDump
//
//  Created by Leptos on 5/10/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDUtilities : NSObject

/// The paths of the images in the loaded dyld shared cache
+ (NSArray<NSString *> *)dyldSharedCacheImagePaths;

/// Names of the Obj-C classes which are safe to access
+ (NSArray<NSString *> *)safeClassNames;

@end
