//
//  CDIvarModel.m
//  ClassDump
//
//  Created by Leptos on 4/8/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "CDIvarModel.h"
#import "../Services/CDTypeParser.h"

@implementation CDIvarModel

+ (instancetype)modelWithIvar:(Ivar)ivar {
    return [[self alloc] initWithIvar:ivar];
}

- (instancetype)initWithIvar:(Ivar)ivar {
    if (self = [self init]) {
        _backing = ivar;
        _name = @(ivar_getName(ivar));
        _line = [CDTypeParser stringForEncoding:ivar_getTypeEncoding(ivar) variable:self.name];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        __typeof(self) casted = (__typeof(casted))object;
        Ivar const sVar = self.backing, cVar = casted.backing;
        return [self.name isEqual:casted.name] &&
        (strstr(ivar_getTypeEncoding(sVar), ivar_getTypeEncoding(cVar)) == 0);
    }
    return NO;
}

- (NSString *)description {
    return self.line;
}

@end
