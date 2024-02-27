//
//  NSArray+CDFiltering.m
//  ClassDump
//
//  Created by Leptos on 2/26/24.
//  Copyright © 2024 Leptos. All rights reserved.
//

#import "NSArray+CDFiltering.h"

@implementation NSArray (CDFiltering)

- (NSArray *)cd_uniqueObjects {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id object in self) {
        if ([result containsObject:object]) {
            continue;
        }
        [result addObject:object];
    }
    
    return result;
}

- (NSArray *)cd_filterObjectsIgnoring:(NSSet *)ignoreSet {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id object in self) {
        if ([ignoreSet containsObject:object]) {
            continue;
        }
        [result addObject:object];
    }
    
    return result;
}

@end
