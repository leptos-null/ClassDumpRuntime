//
//  CDProtocolModel.m
//  ClassDump
//
//  Created by Leptos on 4/7/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "CDProtocolModel.h"
#import <dlfcn.h>
#import <pthread.h>

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
    Dl_info info;
    
    NSMutableString *ret = [NSMutableString string];
    if (comments) {
        dladdr(protocol_getName(self.backing), &info);
        [ret appendFormat:@"/* %s in %s */\n", info.dli_sname ? info.dli_sname : "(runtime)", info.dli_fname];
    }
    [ret appendString:@"@protocol "];
    [ret appendString:self.name];
    if (self.protocols.count) {
        [ret appendString:@" <"];
        [ret appendString:[self.protocols componentsJoinedByString:@", "]];
        [ret appendString:@">"];
    }
    [ret appendString:@"\n"];
    
    if (self.requiredClassProperties.count) {
        [ret appendString:@"\n"];
        for (CDPropertyModel *model in self.requiredClassProperties) {
            if (comments) {
                dladdr(model.backing, &info);
                [ret appendFormat:@"\n/* in %s */\n", info.dli_fname];
            }
            [ret appendFormat:@"%@;\n", model];
        }
    }
    
    if (self.requiredClassMethods.count) {
        [ret appendString:@"\n"];
        for (CDMethodModel *model in self.requiredClassMethods) {
            if (synthesizeStrip && [_classPropertySynthesizedMethods containsObject:model.name]) {
                continue;
            }
            if (comments) {
                dladdr(model.backing.types, &info);
                [ret appendFormat:@"\n/* in %s */\n", info.dli_fname];
            }
            [ret appendFormat:@"%@;\n", model];
        }
    }
    
    if (self.requiredInstanceProperties.count) {
        [ret appendString:@"\n"];
        for (CDPropertyModel *model in self.requiredInstanceProperties) {
            if (comments) {
                dladdr(model.backing, &info);
                [ret appendFormat:@"\n/* in %s */\n", info.dli_fname];
            }
            [ret appendFormat:@"%@;\n", model];
        }
    }
    
    if (self.requiredInstanceMethods.count) {
        [ret appendString:@"\n"];
        for (CDMethodModel *model in self.requiredInstanceMethods) {
            if (synthesizeStrip && [_instancePropertySynthesizedMethods containsObject:model.name]) {
                continue;
            }
            if (comments) {
                dladdr(model.backing.types, &info);
                [ret appendFormat:@"\n/* in %s */\n", info.dli_fname];
            }
            [ret appendFormat:@"%@;\n", model];
        }
    }
    if (self.optionalClassProperties.count || self.optionalClassMethods.count ||
        self.optionalInstanceProperties.count || self.optionalInstanceMethods.count) {
        [ret appendString:@"\n@optional\n"];
    }
    
    if (self.optionalClassProperties.count) {
        [ret appendString:@"\n"];
        for (CDPropertyModel *model in self.optionalClassProperties) {
            if (comments) {
                dladdr(model.backing, &info);
                [ret appendFormat:@"\n/* in %s */\n", info.dli_fname];
            }
            [ret appendFormat:@"%@;\n", model];
        }
    }
    
    if (self.optionalClassMethods.count) {
        [ret appendString:@"\n"];
        for (CDMethodModel *model in self.optionalClassMethods) {
            if (synthesizeStrip && [_classPropertySynthesizedMethods containsObject:model.name]) {
                continue;
            }
            if (comments) {
                dladdr(model.backing.types, &info);
                [ret appendFormat:@"\n/* in %s */\n", info.dli_fname];
            }
            [ret appendFormat:@"%@;\n", model];
        }
    }
    
    if (self.optionalInstanceProperties.count) {
        [ret appendString:@"\n"];
        for (CDPropertyModel *model in self.optionalInstanceProperties) {
            if (comments) {
                dladdr(model.backing, &info);
                [ret appendFormat:@"\n/* in %s */\n", info.dli_fname];
            }
            [ret appendFormat:@"%@;\n", model];
        }
    }
    
    if (self.optionalInstanceMethods.count) {
        [ret appendString:@"\n"];
        for (CDMethodModel *model in self.optionalInstanceMethods) {
            if (synthesizeStrip && [_instancePropertySynthesizedMethods containsObject:model.name]) {
                continue;
            }
            if (comments) {
                dladdr(model.backing.types, &info);
                [ret appendFormat:@"\n/* in %s */\n", info.dli_fname];
            }
            [ret appendFormat:@"%@;\n", model];
        }
    }
    
    [ret appendString:@"\n@end\n"];
    return [ret copy];
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
