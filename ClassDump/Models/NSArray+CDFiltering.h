//
//  NSArray+CDFiltering.h
//  ClassDump
//
//  Created by Leptos on 2/26/24.
//  Copyright © 2024 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<__covariant ObjectType> (CDFiltering)

- (NSArray<ObjectType> *)cd_uniqueObjects;
- (NSArray<ObjectType> *)cd_filterObjectsIgnoring:(NSSet<ObjectType> *)ignoreSet;

@end
