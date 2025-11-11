//
//  CDGenerationOptions.m
//  ClassDumpRuntime
//
//  Created by Leptos on 2/25/24.
//  Copyright © 2024 Leptos. All rights reserved.
//

#import "CDGenerationOptions.h"

@implementation CDGenerationOptions

- (id)copyWithZone:(NSZone *)zone {
    CDGenerationOptions *options = [CDGenerationOptions new];
    options.stripProtocolConformance = _stripProtocolConformance;
    options.stripOverrides = _stripOverrides;
    options.stripDuplicates = _stripDuplicates;
    options.stripSynthesized = _stripSynthesized;
    options.stripCtorMethod = _stripCtorMethod;
    options.stripDtorMethod = _stripDtorMethod;
    options.addSymbolImageComments = _addSymbolImageComments;
    options.addIvarOffsetComments = _addIvarOffsetComments;
    options.expandIvarRecordTypeMembers = _expandIvarRecordTypeMembers;
    return options;
}

@end
