//
//  CDProtocolModel+Conformance.m
//  ClassDump
//
//  Created by Leptos on 3/3/24.
//  Copyright © 2024 Leptos. All rights reserved.
//

#import "CDProtocolModel+Conformance.h"

#import <objc/message.h>

@implementation CDProtocolModel (Conformance)

+ (NSArray<CDPropertyModel *> *)requiredClassPropertiesToConform:(NSArray<CDProtocolModel *> *)protocols {
    return [self _genericRequiredForConformance:protocols property:@selector(requiredClassProperties) identifiable:^NSString *(CDPropertyModel *model) {
        return model.name;
    }];
}
+ (NSArray<CDPropertyModel *> *)requiredInstancePropertiesToConform:(NSArray<CDProtocolModel *> *)protocols {
    return [self _genericRequiredForConformance:protocols property:@selector(requiredInstanceProperties) identifiable:^NSString *(CDPropertyModel *model) {
        return model.name;
    }];
}

+ (NSArray<CDMethodModel *> *)requiredClassMethodsToConform:(NSArray<CDProtocolModel *> *)protocols {
    return [self _genericRequiredForConformance:protocols property:@selector(requiredClassMethods) identifiable:^NSString *(CDMethodModel *model) {
        return model.name;
    }];
}
+ (NSArray<CDMethodModel *> *)requiredInstanceMethodsToConform:(NSArray<CDProtocolModel *> *)protocols {
    return [self _genericRequiredForConformance:protocols property:@selector(requiredInstanceMethods) identifiable:^NSString *(CDMethodModel *model) {
        return model.name;
    }];
}

// returns NSArray<T>
// mode: KeyPath<CDProtocolModel, NSArray<T>>
// identifiable: (T) -> T.ID
+ (NSArray *)_genericRequiredForConformance:(NSArray<CDProtocolModel *> *)protocols property:(SEL)mode identifiable:(id(NS_NOESCAPE ^)(id))identifiableResolver {
    NSMutableArray *build = [NSMutableArray array];
    NSMutableSet *trackingSet = [NSMutableSet set];
    [self _genericRequiredForConformance:protocols build:build tracking:trackingSet property:mode identifiable:identifiableResolver];
    return build;
}

+ (void)_genericRequiredForConformance:(NSArray<CDProtocolModel *> *)protocols build:(NSMutableArray *)build tracking:(NSMutableSet *)trackingSet property:(SEL)mode identifiable:(id(NS_NOESCAPE ^)(id))identifiableResolver {
    // the order here is very important for protocols that have
    // confliciting declarations for a given identifier
    for (CDProtocolModel *protocol in protocols) {
        NSArray *recursiveResolve = ((id (*)(id, SEL))objc_msgSend)(protocol, mode);
        for (id object in recursiveResolve) {
            id const identifier = identifiableResolver(object);
            
            if ([trackingSet containsObject:identifier]) {
                continue;
            }
            [trackingSet addObject:identifier];
            [build addObject:object];
        }
        [self _genericRequiredForConformance:protocol.protocols build:build tracking:trackingSet property:mode identifiable:identifiableResolver];
    }
}

@end
