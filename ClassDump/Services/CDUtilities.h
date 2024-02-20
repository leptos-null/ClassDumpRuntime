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
+ (nonnull NSArray<NSString *> *)dyldSharedCacheImagePaths;

/// Names of all registered Obj-C classes
+ (nonnull NSArray<NSString *> *)classNames;
/// Determines if the Obj-C class with the given name is safe to reference
+ (BOOL)isClassSafeToInspect:(nonnull NSString *)className;

@end
