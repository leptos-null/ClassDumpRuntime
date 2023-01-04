//
//  CDProtocolModel.m
//  ClassDump
//
//  Created by Leptos on 4/7/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "CDProtocolModel.h"

#import <dlfcn.h>

@implementation CDProtocolModel {
    NSArray<NSString *> *_classPropertySynthesizedMethods;
    NSArray<NSString *> *_instancePropertySynthesizedMethods;
}

+ (instancetype)modelWithProtocol:(Protocol *)prcl {
    return [[self alloc] initWithProtocol:prcl];
}

- (instancetype)initWithProtocol:(Protocol *)prcl {
    if (self = [self init]) {
        _backing = prcl;
        _name = @(protocol_getName(prcl));
        
        unsigned int count, index;
        
        Protocol *__unsafe_unretained *protocolList = protocol_copyProtocolList(prcl, &count);
        if (protocolList) {
            NSMutableArray<CDProtocolModel *> *protocols = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                /* circular dependecies are illegal */
                Protocol *objc_protocol = protocolList[index];
                [protocols addObject:[CDProtocolModel modelWithProtocol:objc_protocol]];
            }
            free(protocolList);
            _protocols = [protocols copy];
        }
        
        NSMutableArray<NSString *> *classSynthMeths = [NSMutableArray array];
        NSMutableArray<NSString *> *instcSynthMeths = [NSMutableArray array];
        
#if 0 /* this appears to not be working properly, depending on version combinations between runtime enviorment and target image */
        objc_property_t *reqClassProps = protocol_copyPropertyList2(prcl, &count, YES, NO);
        if (reqClassProps) {
            NSMutableArray<CDPropertyModel *> *properties = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                CDPropertyModel *propertyRep = [CDPropertyModel modelWithProperty:reqClassProps[index] isClass:YES];
                [properties addObject:propertyRep];
                NSString *synthMethodName;
                if ((synthMethodName = propertyRep.getter)) {
                    [classSynthMeths addObject:synthMethodName];
                }
                if ((synthMethodName = propertyRep.setter)) {
                    [classSynthMeths addObject:synthMethodName];
                }
            }
            free(reqClassProps);
            _requiredClassProperties = [properties copy];
        }
#endif
        struct objc_method_description *reqClassMeths = protocol_copyMethodDescriptionList(prcl, YES, NO, &count);
        if (reqClassMeths) {
            NSMutableArray<CDMethodModel *> *methods = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                [methods addObject:[CDMethodModel modelWithMethod:reqClassMeths[index] isClass:YES]];
            }
            free(reqClassMeths);
            _requiredClassMethods = [methods copy];
        }
        
        objc_property_t *reqInstProps = protocol_copyPropertyList2(prcl, &count, YES, YES);
        if (reqInstProps) {
            NSMutableArray<CDPropertyModel *> *properties = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                CDPropertyModel *propertyRep = [CDPropertyModel modelWithProperty:reqInstProps[index] isClass:NO];
                [properties addObject:propertyRep];
                NSString *synthMethodName;
                if ((synthMethodName = propertyRep.getter)) {
                    [instcSynthMeths addObject:synthMethodName];
                }
                if ((synthMethodName = propertyRep.setter)) {
                    [instcSynthMeths addObject:synthMethodName];
                }
            }
            free(reqInstProps);
            _requiredInstanceProperties = [properties copy];
        }
        struct objc_method_description *reqInstMeths = protocol_copyMethodDescriptionList(prcl, YES, YES, &count);
        if (reqInstMeths) {
            NSMutableArray<CDMethodModel *> *methods = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                [methods addObject:[CDMethodModel modelWithMethod:reqInstMeths[index] isClass:NO]];
            }
            free(reqInstMeths);
            _requiredInstanceMethods = [methods copy];
        }
        
        objc_property_t *optClassProps = protocol_copyPropertyList2(prcl, &count, NO, NO);
        if (optClassProps) {
            NSMutableArray<CDPropertyModel *> *properties = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                CDPropertyModel *propertyRep = [CDPropertyModel modelWithProperty:optClassProps[index] isClass:YES];
                [properties addObject:propertyRep];
                NSString *synthMethodName;
                if ((synthMethodName = propertyRep.getter)) {
                    [classSynthMeths addObject:synthMethodName];
                }
                if ((synthMethodName = propertyRep.setter)) {
                    [classSynthMeths addObject:synthMethodName];
                }
            }
            free(optClassProps);
            _optionalClassProperties = [properties copy];
        }
        struct objc_method_description *optClassMeths = protocol_copyMethodDescriptionList(prcl, NO, NO, &count);
        if (optClassMeths) {
            NSMutableArray<CDMethodModel *> *methods = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                [methods addObject:[CDMethodModel modelWithMethod:(optClassMeths[index]) isClass:YES]];
            }
            free(optClassMeths);
            _requiredClassMethods = [methods copy];
        }
        
        objc_property_t *optInstProps = protocol_copyPropertyList2(prcl, &count, NO, YES);
        if (optInstProps) {
            NSMutableArray<CDPropertyModel *> *properties = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                CDPropertyModel *propertyRep = [CDPropertyModel modelWithProperty:optInstProps[index] isClass:NO];
                [properties addObject:propertyRep];
                NSString *synthMethodName;
                if ((synthMethodName = propertyRep.getter)) {
                    [instcSynthMeths addObject:synthMethodName];
                }
                if ((synthMethodName = propertyRep.setter)) {
                    [instcSynthMeths addObject:synthMethodName];
                }
            }
            free(optInstProps);
            _optionalInstanceProperties = [properties copy];
        }
        struct objc_method_description *optInstMeths = protocol_copyMethodDescriptionList(prcl, NO, YES, &count);
        if (optInstMeths) {
            NSMutableArray<CDMethodModel *> *methods = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                [methods addObject:[CDMethodModel modelWithMethod:optInstMeths[index] isClass:NO]];
            }
            free(optInstMeths);
            _optionalInstanceMethods = [methods copy];
        }
        
        _classPropertySynthesizedMethods = [classSynthMeths copy];
        _instancePropertySynthesizedMethods = [instcSynthMeths copy];
    }
    return self;
}

- (NSString *)linesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip {
    return [[self semanticLinesWithComments:comments synthesizeStrip:synthesizeStrip] string];
}

- (CDSemanticString *)semanticLinesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip {
    CDSemanticString *build = [CDSemanticString new];
    
    if (comments) {
        NSString *comment = nil;
        Dl_info info;
        if (dladdr((__bridge void *)self.backing, &info)) {
            comment = [NSString stringWithFormat:@"/* %s in %s */", info.dli_sname ?: "(anonymous)", info.dli_fname];
        } else {
            comment = @"/* no symbol found */";
        }
        [build appendString:comment semanticType:CDSemanticTypeComment];
        [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
    }
    [build appendString:@"@protocol" semanticType:CDSemanticTypeKeyword];
    [build appendString:@" " semanticType:CDSemanticTypeStandard];
    [build appendString:self.name semanticType:CDSemanticTypeDeclared];
    
    NSArray<CDProtocolModel *> *protocols = self.protocols;
    NSUInteger const protocolCount = protocols.count;
    if (protocolCount > 0) {
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
        [build appendString:@"<" semanticType:CDSemanticTypeStandard];
        [protocols enumerateObjectsUsingBlock:^(CDProtocolModel *protocol, NSUInteger idx, BOOL *stop) {
            [build appendString:protocol.name semanticType:CDSemanticTypeDeclared];
            if ((idx + 1) < protocolCount) {
                [build appendString:@", " semanticType:CDSemanticTypeStandard];
            }
        }];
        [build appendString:@">" semanticType:CDSemanticTypeStandard];
    }
    [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
    
    [self _appendLines:build properties:self.requiredClassProperties comments:comments];
    [self _appendLines:build methods:self.requiredClassMethods synthesized:(synthesizeStrip ? _classPropertySynthesizedMethods : nil) comments:comments];
    
    [self _appendLines:build properties:self.requiredInstanceProperties comments:comments];
    [self _appendLines:build methods:self.requiredInstanceMethods synthesized:(synthesizeStrip ? _instancePropertySynthesizedMethods : nil) comments:comments];
    
    if (self.optionalClassProperties.count || self.optionalClassMethods.count ||
        self.optionalInstanceProperties.count || self.optionalInstanceMethods.count) {
        [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
        [build appendString:@"@optional" semanticType:CDSemanticTypeKeyword];
        [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
    }
    
    [self _appendLines:build properties:self.optionalClassProperties comments:comments];
    [self _appendLines:build methods:self.optionalClassMethods synthesized:(synthesizeStrip ? _classPropertySynthesizedMethods : nil) comments:comments];
    
    [self _appendLines:build properties:self.optionalInstanceProperties comments:comments];
    [self _appendLines:build methods:self.optionalInstanceMethods synthesized:(synthesizeStrip ? _instancePropertySynthesizedMethods : nil) comments:comments];
    
    [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
    [build appendString:@"@end" semanticType:CDSemanticTypeKeyword];
    [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
    
    return build;
}

- (void)_appendLines:(CDSemanticString *)build properties:(NSArray<CDPropertyModel *> *)properties comments:(BOOL)comments {
    if (properties.count) {
        [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
        
        Dl_info info;
        for (CDPropertyModel *prop in properties) {
            if (comments) {
                NSString *comment = nil;
                if (dladdr(prop.backing, &info)) {
                    comment = [NSString stringWithFormat:@"/* in %s */", info.dli_fname];
                } else {
                    comment = @"/* no symbol found */";
                }
                [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
                [build appendString:comment semanticType:CDSemanticTypeComment];
                [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
            }
            [build appendSemanticString:[prop semanticString]];
            [build appendString:@";\n" semanticType:CDSemanticTypeStandard];
        }
    }
}

- (void)_appendLines:(CDSemanticString *)build methods:(NSArray<CDMethodModel *> *)methods synthesized:(NSArray<NSString *> *)synthesized comments:(BOOL)comments {
    if (methods.count) {
        [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
        
        Dl_info info;
        for (CDMethodModel *methd in methods) {
            if ([synthesized containsObject:methd.name]) {
                continue;
            }
            if (comments) {
                NSString *comment = nil;
                if (dladdr(methd.backing.types, &info)) {
                    comment = [NSString stringWithFormat:@"/* in %s */", info.dli_fname];
                } else {
                    comment = @"/* no symbol found */";
                }
                [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
                [build appendString:comment semanticType:CDSemanticTypeComment];
                [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
            }
            [build appendSemanticString:[methd semanticString]];
            [build appendString:@";\n" semanticType:CDSemanticTypeStandard];
        }
    }
}

- (NSString *)description {
    return self.name;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {name: '%@', protocols: %@, "
            "requiredClassProperties: %@, requiredInstanceProperties: %@, "
            "requiredClassMethods: %@, requiredInstanceMethods: %@, "
            "optionalClassProperties: %@, optionalInstanceProperties: %@, "
            "optionalClassMethods: %@, optionalInstanceMethods: %@}",
            [self class], self, self.name, self.protocols,
            self.requiredClassProperties, self.requiredInstanceProperties,
            self.requiredClassMethods, self.requiredInstanceMethods,
            self.optionalClassProperties, self.optionalInstanceProperties,
            self.optionalClassMethods, self.optionalInstanceMethods];
}

@end
