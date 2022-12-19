//
//  CDClassModel.m
//  ClassDump
//
//  Created by Leptos on 4/7/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "CDClassModel.h"
#import "../Services/CDTypeParser.h"

#import <dlfcn.h>

@implementation CDClassModel {
    NSArray<NSString *> *_classPropertySynthesizedMethods;
    NSArray<NSString *> *_instancePropertySynthesizedMethods;
    NSArray<NSString *> *_instancePropertySynthesizedVars;
}

+ (instancetype)modelWithClass:(Class)cls {
    return [[self alloc] initWithClass:cls];
}

- (instancetype)initWithClass:(Class)cls {
    if (self = [self init]) {
        _backing = cls;
        _name = @(class_getName(cls));
        
        Class metaClass = object_getClass(cls);
        
        unsigned int count, index;
        
        Protocol *__unsafe_unretained *protocolList = class_copyProtocolList(cls, &count);
        if (protocolList) {
            NSMutableArray<CDProtocolModel *> *protocols = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                Protocol *objc_protocol = protocolList[index];
                [protocols addObject:[CDProtocolModel modelWithProtocol:objc_protocol]];
            }
            free(protocolList);
            _protocols = [protocols copy];
        }
        
        objc_property_t *classPropertyList = class_copyPropertyList(metaClass, &count);
        if (classPropertyList) {
            NSMutableArray<NSString *> *synthMeths = [NSMutableArray array];
            NSMutableArray<CDPropertyModel *> *properties = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                objc_property_t objc_property = classPropertyList[index];
                CDPropertyModel *propertyRep = [CDPropertyModel modelWithProperty:objc_property isClass:YES];
                [properties addObject:propertyRep];
                NSString *synthMethodName;
                if ((synthMethodName = propertyRep.getter)) {
                    [synthMeths addObject:synthMethodName];
                }
                if ((synthMethodName = propertyRep.setter)) {
                    [synthMeths addObject:synthMethodName];
                }
            }
            free(classPropertyList);
            _classPropertySynthesizedMethods = [synthMeths copy];
            _classProperties = [properties copy];
        }
        
        objc_property_t *propertyList = class_copyPropertyList(cls, &count);
        if (propertyList) {
            NSMutableArray<NSString *> *synthMeths = [NSMutableArray array];
            NSMutableArray<NSString *> *syntVars = [NSMutableArray array];
            NSMutableArray<CDPropertyModel *> *properties = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                objc_property_t objc_property = propertyList[index];
                CDPropertyModel *propertyRep = [CDPropertyModel modelWithProperty:objc_property isClass:NO];
                [properties addObject:propertyRep];
                NSString *synthCompName;
                if ((synthCompName = propertyRep.getter)) {
                    [synthMeths addObject:synthCompName];
                }
                if ((synthCompName = propertyRep.setter)) {
                    [synthMeths addObject:synthCompName];
                }
                if ((synthCompName = propertyRep.iVar)) {
                    [syntVars addObject:synthCompName];
                }
            }
            free(propertyList);
            _instancePropertySynthesizedMethods = [synthMeths copy];
            _instancePropertySynthesizedVars = [syntVars copy];
            _instanceProperties = [properties copy];
        }
        
        Ivar *ivarList = class_copyIvarList(cls, &count);
        if (ivarList) {
            NSMutableArray<CDIvarModel *> *ivars = [NSMutableArray arrayWithCapacity:count];
            
            NSMutableArray<CDPropertyModel *> *eligibleProperties = [NSMutableArray arrayWithArray:self.instanceProperties];
            NSUInteger eligiblePropertiesCount = eligibleProperties.count;
            
            for (index = 0; index < count; index++) {
                CDIvarModel *model = [CDIvarModel modelWithIvar:ivarList[index]];
                
                for (NSUInteger eligibleIndex = 0; eligibleIndex < eligiblePropertiesCount; eligibleIndex++) {
                    CDPropertyModel *propModel = eligibleProperties[eligibleIndex];
                    if ([propModel.iVar isEqualToString:model.name]) {
                        [propModel overrideType:model.type];
                        
                        eligiblePropertiesCount--;
                        // constant time operation
                        // since we decremented eligiblePropertiesCount, this object is now unreachable
                        [eligibleProperties exchangeObjectAtIndex:eligibleIndex withObjectAtIndex:eligiblePropertiesCount];
                        
                        break;
                    }
                }
                [ivars addObject:model];
            }
            free(ivarList);
            _ivars = [ivars copy];
        }
        
        Method *classMethodList = class_copyMethodList(metaClass, &count);
        if (classMethodList) {
            NSMutableArray<CDMethodModel *> *methods = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                [methods addObject:[CDMethodModel modelWithMethod:*method_getDescription(classMethodList[index]) isClass:YES]];
            }
            _classMethods = [methods copy];
            free(classMethodList);
        }
        
        Method *methodList = class_copyMethodList(cls, &count);
        if (methodList) {
            NSMutableArray<CDMethodModel *> *methods = [NSMutableArray arrayWithCapacity:count];
            for (index = 0; index < count; index++) {
                [methods addObject:[CDMethodModel modelWithMethod:*method_getDescription(methodList[index]) isClass:NO]];
            }
            _instanceMethods = [methods copy];
            free(methodList);
        }
        
    }
    return self;
}

- (NSString *)linesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip {
    Dl_info info;
    
    NSMutableString *ret = [NSMutableString string];
    if (comments) {
        if (dladdr((__bridge const void *)self.backing, &info)) {
            [ret appendFormat:@"/* %s in %s */\n", info.dli_sname ?: "(anonymous)", info.dli_fname];
        } else {
            [ret appendString:@"/* no symbol found */\n"];
        }
    }
    [ret appendString:@"@interface "];
    [ret appendString:self.name];
    Class superclass = class_getSuperclass(self.backing);
    if (superclass) {
        [ret appendFormat:@" : %s", class_getName(superclass)];
    }
    
    if (self.protocols.count) {
        [ret appendString:@" <"];
        [ret appendString:[self.protocols componentsJoinedByString:@", "]];
        [ret appendString:@">"];
    }
    
    NSArray<NSString *> *synthedClassMethds = nil, *synthedInstcMethds = nil, *synthedVars = nil;
    if (synthesizeStrip) {
        synthedClassMethds = _classPropertySynthesizedMethods;
        synthedInstcMethds = _instancePropertySynthesizedMethods;
        synthedVars = _instancePropertySynthesizedVars;
    }
    
    if (self.ivars.count - synthedVars.count) {
        [ret appendString:@" {\n"];
        for (CDIvarModel *ivar in self.ivars) {
            if ([synthedVars containsObject:ivar.name]) {
                continue;
            }
            if (comments) {
                if (dladdr(ivar.backing, &info)) {
                    [ret appendFormat:@"\n    /* in %s */\n", info.dli_fname];
                } else {
                    [ret appendString:@"\n    /* no symbol found */\n"];
                }
            }
            [ret appendFormat:@"    %@;\n", ivar];
        }
        [ret appendString:@"}"];
    }
    
    [ret appendString:@"\n"];
    
    // todo: add stripping of protocol conformance
    
    [self _appendLines:ret properties:self.classProperties comments:comments];
    [self _appendLines:ret properties:self.instanceProperties comments:comments];
    
    [self _appendLines:ret methods:self.classMethods synthesized:synthedClassMethds comments:comments];
    [self _appendLines:ret methods:self.instanceMethods synthesized:synthedInstcMethds comments:comments];
    
    [ret appendString:@"\n@end\n"];
    return [ret copy];
}

- (void)_appendLines:(NSMutableString *)ret properties:(NSArray<CDPropertyModel *> *)properties comments:(BOOL)comments {
    if (properties.count) {
        [ret appendString:@"\n"];
        
        Dl_info info;
        for (CDPropertyModel *prop in properties) {
            if (comments) {
                if (dladdr(prop.backing, &info)) {
                    [ret appendFormat:@"\n/* in %s */\n", info.dli_fname];
                } else {
                    [ret appendString:@"\n/* no symbol found */\n"];
                }
            }
            [ret appendFormat:@"%@;\n", prop];
        }
    }
}

- (void)_appendLines:(NSMutableString *)ret methods:(NSArray<CDMethodModel *> *)methods synthesized:(NSArray<NSString *> *)synthesized comments:(BOOL)comments {
    if (methods.count - synthesized.count) {
        [ret appendString:@"\n"];
        
        Dl_info info;
        for (CDMethodModel *methd in self.classMethods) {
            if ([synthesized containsObject:methd.name]) {
                continue;
            }
            if (comments) {
                Method objcMethod = NULL;
                if (methd.isClass) {
                    objcMethod = class_getClassMethod(self.backing, methd.backing.name);
                } else {
                    objcMethod = class_getInstanceMethod(self.backing, methd.backing.name);
                }
                IMP const methdImp = method_getImplementation(objcMethod);
                if (dladdr(methdImp, &info)) {
                    [ret appendFormat:@"\n/* %s in %s */\n", info.dli_sname ?: "(anonymous)", info.dli_fname];
                } else {
                    [ret appendString:@"\n/* no symbol found */\n"];
                }
            }
            [ret appendFormat:@"%@;\n", methd];
        }
    }
}

- (NSString *)description {
    return self.name;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {name: '%@', protocols: %@, "
            "classProperties: %@, instanceProperties: %@, classMethods: %@, instanceMethods: %@, ivars: %@}",
            [self class], self, self.name, self.protocols,
            self.classProperties, self.instanceProperties, self.classMethods, self.instanceMethods, self.ivars];
}

@end
