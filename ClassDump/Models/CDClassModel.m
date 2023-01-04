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
    return [[self semanticLinesWithComments:comments synthesizeStrip:synthesizeStrip] string];
}

- (CDSemanticString *)semanticLinesWithComments:(BOOL)comments synthesizeStrip:(BOOL)synthesizeStrip {
    Dl_info info;
    
    CDSemanticString *build = [CDSemanticString new];
    if (comments) {
        NSString *comment = nil;
        if (dladdr((__bridge const void *)self.backing, &info)) {
            comment = [NSString stringWithFormat:@"/* %s in %s */", info.dli_sname ?: "(anonymous)", info.dli_fname];
        } else {
            comment = @"/* no symbol found */";
        }
        [build appendString:comment semanticType:CDSemanticTypeComment];
        [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
    }
    [build appendString:@"@interface" semanticType:CDSemanticTypeKeyword];
    [build appendString:@" " semanticType:CDSemanticTypeStandard];
    [build appendString:self.name semanticType:CDSemanticTypeDeclared];
    
    Class superclass = class_getSuperclass(self.backing);
    if (superclass) {
        [build appendString:@" : " semanticType:CDSemanticTypeStandard];
        [build appendString:NSStringFromClass(superclass) semanticType:CDSemanticTypeDeclared];
    }
    
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
    
    NSArray<NSString *> *synthedClassMethds = nil, *synthedInstcMethds = nil, *synthedVars = nil;
    if (synthesizeStrip) {
        synthedClassMethds = _classPropertySynthesizedMethods;
        synthedInstcMethds = _instancePropertySynthesizedMethods;
        synthedVars = _instancePropertySynthesizedVars;
    }
    
    if (self.ivars.count - synthedVars.count) {
        [build appendString:@" {\n" semanticType:CDSemanticTypeStandard];
        for (CDIvarModel *ivar in self.ivars) {
            if ([synthedVars containsObject:ivar.name]) {
                continue;
            }
            if (comments) {
                NSString *comment = nil;
                if (dladdr(ivar.backing, &info)) {
                    comment = [NSString stringWithFormat:@"/* in %s */", info.dli_fname];
                } else {
                    comment = @"/* no symbol found */";
                }
                [build appendString:@"\n    " semanticType:CDSemanticTypeStandard];
                [build appendString:comment semanticType:CDSemanticTypeComment];
                [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
            }
            [build appendString:@"    " semanticType:CDSemanticTypeStandard];
            [build appendSemanticString:[ivar semanticString]];
            [build appendString:@";\n" semanticType:CDSemanticTypeStandard];
        }
        [build appendString:@"}" semanticType:CDSemanticTypeStandard];
    }
    
    [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
    
    // todo: add stripping of protocol conformance
    
    [self _appendLines:build properties:self.classProperties comments:comments];
    [self _appendLines:build properties:self.instanceProperties comments:comments];
    
    [self _appendLines:build methods:self.classMethods synthesized:synthedClassMethds comments:comments];
    [self _appendLines:build methods:self.instanceMethods synthesized:synthedInstcMethds comments:comments];
    
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
    if (methods.count - synthesized.count) {
        [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
        
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
                
                NSString *comment = nil;
                if (dladdr(methdImp, &info)) {
                    comment = [NSString stringWithFormat:@"/* %s in %s */", info.dli_sname ?: "(anonymous)", info.dli_fname];
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
            "classProperties: %@, instanceProperties: %@, classMethods: %@, instanceMethods: %@, ivars: %@}",
            [self class], self, self.name, self.protocols,
            self.classProperties, self.instanceProperties, self.classMethods, self.instanceMethods, self.ivars];
}

@end
