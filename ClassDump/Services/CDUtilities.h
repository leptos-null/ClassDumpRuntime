//
//  CDUtilities.h
//  ClassDump
//
//  Created by Leptos on 5/10/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_HEADER_AUDIT_BEGIN(nullability)

@interface CDUtilities : NSObject

/// The paths of the images in the loaded dyld shared cache
+ (NSArray<NSString *> *)dyldSharedCacheImagePaths;

/// Names of all registered Obj-C classes
+ (NSArray<NSString *> *)classNames;
/// Determines if the Obj-C class with the given name is safe to reference
+ (BOOL)isClassSafeToInspect:(NSString *)className;

@end

NS_HEADER_AUDIT_END(nullability)
