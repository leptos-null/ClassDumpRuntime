//
//  CDPropertyModel.m
//  ClassDump
//
//  Created by Leptos on 3/24/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "CDPropertyModel.h"
#import "../../Services/CDTypeParser.h"

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
        NSMutableArray<CDPropertyAttribute *> *attributes = [NSMutableArray array];
        if (isClass) {
            [attributes addObject:[CDPropertyAttribute attributeWithName:@"class" value:nil]];
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
            
            NSUInteger const valueLen = propSeek - attribHead;
            if (valueLen > 0) {
                attributeValue = [[NSString alloc] initWithBytes:attribHead length:valueLen encoding:NSUTF8StringEncoding];
            }
            
            /* per https://github.com/llvm/llvm-project/blob/b7f97d3661/clang/lib/AST/ASTContext.cpp#L7878-L7973
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
             *      kPropertyNonAtomic         = 'N', // property non-atomic
             *      kPropertyOptional          = '?', // property optional
             * };
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
                    _type = [CDTypeParser typeForEncodingStart:attribHead end:propSeek error:NULL];
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
                case '?':
                    // @optional in a protocol
                    break;
                default:
                    NSAssert(NO, @"Unknown attribute code: %c", switchOnMe);
                    break;
            }
            
            if (attributeName) {
                [attributes addObject:[CDPropertyAttribute attributeWithName:attributeName value:attributeValue]];
            }
        }
        
        _attributes = [attributes copy];
        if (!isDynamic) {
            if (!self.getter) {
                _getter = [self.name copy];
            }
            if (!self.setter && !isReadOnly) {
                // per https://github.com/llvm/llvm-project/blob/86616443bf/clang/lib/Basic/IdentifierTable.cpp#L756-L762
                unichar const realFirstChar = [self.name characterAtIndex:0];
                NSString *firstChar = [NSString stringWithCharacters:&realFirstChar length:1];
                _setter = [NSString stringWithFormat:@"set%@%@:", firstChar.uppercaseString, [self.name substringFromIndex:1]];
            }
        }
    }
    return self;
}

- (void)overrideType:(CDParseType *)type {
    _type = type;
}

- (CDSemanticString *)semanticString {
    CDSemanticString *build = [CDSemanticString new];
    [build appendString:@"@property" semanticType:CDSemanticTypeKeyword];
    [build appendString:@" " semanticType:CDSemanticTypeStandard];
    
    NSArray<CDPropertyAttribute *> *attributes = self.attributes;
    NSUInteger const attributeCount = attributes.count;
    if (attributeCount > 0) {
        [build appendString:@"(" semanticType:CDSemanticTypeStandard];
        [attributes enumerateObjectsUsingBlock:^(CDPropertyAttribute *attribute, NSUInteger idx, BOOL *stop) {
            [build appendString:attribute.name semanticType:CDSemanticTypeKeyword];
            
            NSString *attributeValue = attribute.value;
            if (attributeValue != nil) {
                [build appendString:@"=" semanticType:CDSemanticTypeStandard];
                [build appendString:attributeValue semanticType:CDSemanticTypeVariable];
            }
            if ((idx + 1) < attributeCount) {
                [build appendString:@", " semanticType:CDSemanticTypeStandard];
            }
        }];
        [build appendString:@") " semanticType:CDSemanticTypeStandard];
    }
    [build appendSemanticString:[self.type semanticStringForVariableName:self.name]];
    return build;
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

- (NSUInteger)hash {
    return self.name.hash;
}

- (NSString *)description {
    return [[self semanticString] string];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {type: %@, attributes: %@, "
            "ivar: '%@', getter: '%@', setter: '%@'}",
            [self class], self, self.type, self.attributes,
            self.iVar, self.getter, self.setter];
}

@end
