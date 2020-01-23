//
//  CDPropertyModel.m
//  ClassDump
//
//  Created by Leptos on 3/24/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "CDPropertyModel.h"
#import "../Services/CDTypeParser.h"

@implementation CDPropertyModel

+ (instancetype)modelWithProperty:(objc_property_t)property isClass:(BOOL)isClass {
    return [[self alloc] initWithProperty:property isClass:isClass];
}

- (instancetype)initWithProperty:(objc_property_t)property isClass:(BOOL)isClass {
    if (self = [self init]) {
        _backing = property;
        _name = @(property_getName(property));
        
        BOOL isReadOnly = NO, isDynamic = NO;
        
        const char *const propAttribs = property_getAttributes(property);
        NSMutableArray<NSString *> *attributes = [NSMutableArray array];
        if (isClass) {
            [attributes addObject:@"class"];
        }
        
        for (const char *propSeek = propAttribs; propSeek < (propAttribs + strlen(propAttribs)); propSeek++) {
            const char switchOnMe = *propSeek++;
            
            NSString *attributeName = nil;
            NSString *attributeValue = nil;
            
            const char *const attribHead = propSeek;
            while (*propSeek && *propSeek != ',') {
                switch (*propSeek) {
                    case '"': {
                        propSeek = strchr(++propSeek, '"');
                    } break;
                    case '{': {
                        unsigned openTokens = 1;
                        while (openTokens) {
                            switch (*++propSeek) {
                                case '{':
                                    openTokens++;
                                    break;
                                case '}':
                                    openTokens--;
                                    break;
                            }
                        }
                    } break;
                    case '(': {
                        unsigned openTokens = 1;
                        while (openTokens) {
                            switch (*++propSeek) {
                                case '(':
                                    openTokens++;
                                    break;
                                case ')':
                                    openTokens--;
                                    break;
                            }
                        }
                    } break;
                }
                propSeek++;
            }
            
            long valueLen = propSeek - attribHead;
            if (valueLen > 0) {
                attributeValue = [[NSString alloc] initWithBytes:attribHead length:valueLen encoding:NSUTF8StringEncoding];
            }
            
            /*
             * this enum is in llvm/clang/lib/AST/ASTContext.cpp
             * see getObjCEncodingForPropertyDecl
             *
             *  enum PropertyAttributes {
             *      kPropertyReadOnly          = 'R', // property is read-only.
             *      kPropertyBycopy            = 'C', // property is a copy of the value last assigned
             *      kPropertyByref             = '&', // property is a reference to the value last assigned
             *      kPropertyDynamic           = 'D', // property is dynamic
             *      kPropertyGetter            = 'G', // followed by getter selector name
             *      kPropertySetter            = 'S', // followed by setter selector name
             *      kPropertyInstanceVariable  = 'V', // followed by instance variable  name
             *      kPropertyType              = 'T', // followed by old-style type encoding.
             *      kPropertyWeak              = 'W', // 'weak' property
             *      kPropertyStrong            = 'P', // property GC'able
             *      kPropertyNonAtomic         = 'N'  // property non-atomic
             *  };
             */
            switch (switchOnMe) {
                case 'R':
                    attributeName = @"readonly";
                    isReadOnly = YES;
                    break;
                case 'C':
                    attributeName = @"copy";
                    break;
                case '&':
                    attributeName = @"retain";
                    break;
                case 'D':
                    isDynamic = YES;
                    break;
                case 'G':
                    attributeName = @"getter";
                    _getter = attributeValue;
                    break;
                case 'S':
                    attributeName = @"setter";
                    _setter = attributeValue;
                    break;
                case 'V':
                    _iVar = attributeValue;
                    break;
                case 'T':
                    _type = [CDTypeParser stringForEncodingStart:attribHead end:propSeek variable:self.name error:NULL];
                    break;
                case 'W':
                    attributeName = @"weak";
                    break;
                case 'P':
                    // eligible for garbage collection, no notation
                    break;
                case 'N':
                    attributeName = @"nonatomic";
                    break;
                default:
                    NSLog(@"Unknown attribute code: %c", switchOnMe);
                    assert(0);
                    break;
            }
            
            if (attributeName) {
                if (attributeValue) {
                    attributeName = [attributeName stringByAppendingString:@"="];
                    attributeName = [attributeName stringByAppendingString:attributeValue];
                }
                [attributes addObject:attributeName];
            }
        }
        
        _attributes = [attributes copy];
        if (!isDynamic) {
            if (!self.getter) {
                _getter = [self.name copy];
            }
            if (!self.setter && !isReadOnly) {
                // this is likely not the correct implementation
                // someone recommended this, so until there's another solution
                // this is the implementation that will be used
                // preferably a link to the Clang implementation or the Obj-C spec
                // should be here before this is "production ready"
                unichar realFirstChar = [self.name characterAtIndex:0];
                NSString *firstChar = [NSString stringWithCharacters:&realFirstChar length:1];
                _setter = [NSString stringWithFormat:@"set%@%@:", firstChar.uppercaseString, [self.name substringFromIndex:1]];
            }
        }
    }
    return self;
}

- (void)overrideType:(NSString *)type {
    _type = type;
}

static BOOL _NSStringNullableEqual(NSString *a, NSString *b) {
    return (!a && !b) || [a isEqual:b];
}
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        __typeof(self) casted = (__typeof(casted))object;
        return [self.name isEqual:casted.name] && [self.attributes isEqual:casted.attributes] &&
        _NSStringNullableEqual(self.iVar, casted.iVar) &&
        _NSStringNullableEqual(self.getter, casted.getter) &&
        _NSStringNullableEqual(self.setter, casted.setter);
    }
    return NO;
}

- (NSString *)description {
    NSMutableString *ret = [NSMutableString stringWithString:@"@property "];
    NSArray<NSString *> *attributes = self.attributes;
    if (attributes.count != 0) {
        [ret appendFormat:@"(%@) ", [attributes componentsJoinedByString:@", "]];
    }
    [ret appendString:self.type];
    return ret;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {type: '%@', attributes: %@, "
            "ivar: '%@', getter: '%@', setter: '%@'}",
            [self class], self, self.type, self.attributes,
            self.iVar, self.getter, self.setter];
}

@end
