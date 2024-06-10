//
//  CDClassModel.m
//  ClassDumpRuntime
//
//  Created by Leptos on 4/7/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "CDClassModel.h"
#import "CDProtocolModel+Conformance.h"
#import "../../Services/CDTypeParser.h"
#import "../NSArray+CDFiltering.h"

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
        _name = NSStringFromClass(cls);
        
        Class const metaClass = object_getClass(cls);
        
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
    CDGenerationOptions *options = [CDGenerationOptions new];
    options.addSymbolImageComments = comments;
    options.stripSynthesized = synthesizeStrip;
    return [self semanticLinesWithOptions:options];
}

- (CDSemanticString *)semanticLinesWithOptions:(CDGenerationOptions *)options {
    Dl_info info;
    
    CDSemanticString *build = [CDSemanticString new];
    
    NSSet<NSString *> *forwardClasses = [self _forwardDeclarableClassReferences];
    NSUInteger const forwardClassCount = forwardClasses.count;
    if (forwardClassCount > 0) {
        [build appendString:@"@class" semanticType:CDSemanticTypeKeyword];
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
        
        NSUInteger classNamesRemaining = forwardClassCount;
        for (NSString *className in forwardClasses) {
            [build appendString:className semanticType:CDSemanticTypeClass];
            classNamesRemaining--;
            if (classNamesRemaining > 0) {
                [build appendString:@", " semanticType:CDSemanticTypeStandard];
            }
        }
        [build appendString:@";\n" semanticType:CDSemanticTypeStandard];
    }
    
    NSSet<NSString *> *forwardProtocols = [self _forwardDeclarableProtocolReferences];
    NSUInteger const forwardProtocolCount = forwardProtocols.count;
    if (forwardProtocolCount > 0) {
        [build appendString:@"@protocol" semanticType:CDSemanticTypeKeyword];
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
        
        NSUInteger protocolNamesRemaining = forwardProtocolCount;
        for (NSString *protocolNames in forwardProtocols) {
            [build appendString:protocolNames semanticType:CDSemanticTypeProtocol];
            protocolNamesRemaining--;
            if (protocolNamesRemaining > 0) {
                [build appendString:@", " semanticType:CDSemanticTypeStandard];
            }
        }
        [build appendString:@";\n" semanticType:CDSemanticTypeStandard];
    }
    
    if (forwardClassCount > 0 || forwardProtocolCount > 0) {
        [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
    }
    
    if (options.addSymbolImageComments) {
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
    [build appendString:self.name semanticType:CDSemanticTypeClass];
    
    Class superclass = class_getSuperclass(self.backing);
    if (superclass) {
        [build appendString:@" : " semanticType:CDSemanticTypeStandard];
        [build appendString:NSStringFromClass(superclass) semanticType:CDSemanticTypeClass];
    }
    
    NSArray<CDProtocolModel *> *protocols = self.protocols;
    NSUInteger const protocolCount = protocols.count;
    if (protocolCount > 0) {
        [build appendString:@" " semanticType:CDSemanticTypeStandard];
        [build appendString:@"<" semanticType:CDSemanticTypeStandard];
        [protocols enumerateObjectsUsingBlock:^(CDProtocolModel *protocol, NSUInteger idx, BOOL *stop) {
            [build appendString:protocol.name semanticType:CDSemanticTypeProtocol];
            if ((idx + 1) < protocolCount) {
                [build appendString:@", " semanticType:CDSemanticTypeStandard];
            }
        }];
        [build appendString:@">" semanticType:CDSemanticTypeStandard];
    }
    
    NSArray<NSString *> *synthedClassMethds = nil, *synthedInstcMethds = nil, *synthedVars = nil;
    if (options.stripSynthesized) {
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
            if (options.addSymbolImageComments) {
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
            [build appendString:@";" semanticType:CDSemanticTypeStandard];
            if (options.addIvarOffsetComments) {
                [build appendString:[NSString stringWithFormat:@" // offset: %"PRIdPTR"", ivar.offset] semanticType:CDSemanticTypeComment];
            }
            [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
        }
        [build appendString:@"}" semanticType:CDSemanticTypeStandard];
    }
    
    [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
    
    NSMutableSet<CDPropertyModel *> *classPropertyIgnoreSet = [NSMutableSet set];
    NSMutableSet<CDPropertyModel *> *instancePropertyIgnoreSet = [NSMutableSet set];
    
    NSMutableSet<CDMethodModel *> *classMethodIgnoreSet = [NSMutableSet set];
    NSMutableSet<CDMethodModel *> *instanceMethodIgnoreSet = [NSMutableSet set];
    
    if (options.stripOverrides) {
        NSMutableSet<NSString *> *classPropertyIgnoreNames = [NSMutableSet set];
        NSMutableSet<NSString *> *instancePropertyIgnoreNames = [NSMutableSet set];
        
        NSMutableSet<NSString *> *classMethodIgnoreNames = [NSMutableSet set];
        NSMutableSet<NSString *> *instanceMethodIgnoreNames = [NSMutableSet set];
        
        Class checkClass = class_getSuperclass(self.backing);
        while (checkClass != NULL) {
            CDClassModel *superclassModel = [CDClassModel modelWithClass:checkClass];
            
            for (CDPropertyModel *property in superclassModel.classProperties) {
                if ([classPropertyIgnoreNames containsObject:property.name]) {
                    continue;
                }
                [classPropertyIgnoreNames addObject:property.name];
                [classPropertyIgnoreSet addObject:property];
            }
            
            for (CDPropertyModel *property in superclassModel.instanceProperties) {
                if ([instancePropertyIgnoreNames containsObject:property.name]) {
                    continue;
                }
                [instancePropertyIgnoreNames addObject:property.name];
                [instancePropertyIgnoreSet addObject:property];
            }
            
            for (CDMethodModel *method in superclassModel.classMethods) {
                if ([classMethodIgnoreNames containsObject:method.name]) {
                    continue;
                }
                [classMethodIgnoreNames addObject:method.name];
                [classMethodIgnoreSet addObject:method];
            }
            
            for (CDMethodModel *method in superclassModel.instanceMethods) {
                if ([instanceMethodIgnoreNames containsObject:method.name]) {
                    continue;
                }
                [instanceMethodIgnoreNames addObject:method.name];
                [instanceMethodIgnoreSet addObject:method];
            }
            
            checkClass = class_getSuperclass(checkClass);
        }
    }
    
    if (options.stripProtocolConformance) {
        [classPropertyIgnoreSet addObjectsFromArray:[CDProtocolModel requiredClassPropertiesToConform:self.protocols]];
        [instancePropertyIgnoreSet addObjectsFromArray:[CDProtocolModel requiredInstancePropertiesToConform:self.protocols]];
        [classMethodIgnoreSet addObjectsFromArray:[CDProtocolModel requiredClassMethodsToConform:self.protocols]];
        [instanceMethodIgnoreSet addObjectsFromArray:[CDProtocolModel requiredInstanceMethodsToConform:self.protocols]];
    }
    
    NSArray<CDPropertyModel *> *classProperties = self.classProperties;
    NSArray<CDPropertyModel *> *instanceProperties = self.instanceProperties;
    
    NSArray<CDMethodModel *> *classMethods = self.classMethods;
    NSArray<CDMethodModel *> *instanceMethods = self.instanceMethods;
    
    if (options.stripDuplicates) {
        classProperties = [classProperties cd_uniqueObjects];
        instanceProperties = [instanceProperties cd_uniqueObjects];
        
        classMethods = [classMethods cd_uniqueObjects];
        instanceMethods = [instanceMethods cd_uniqueObjects];
    }
    
    classProperties = [classProperties cd_filterObjectsIgnoring:classPropertyIgnoreSet];
    instanceProperties = [instanceProperties cd_filterObjectsIgnoring:instancePropertyIgnoreSet];
    
    classMethods = [classMethods cd_filterObjectsIgnoring:classMethodIgnoreSet];
    instanceMethods = [instanceMethods cd_filterObjectsIgnoring:instanceMethodIgnoreSet];
    
    [self _appendLines:build properties:classProperties comments:options.addSymbolImageComments];
    [self _appendLines:build properties:instanceProperties comments:options.addSymbolImageComments];
    
    [self _appendLines:build methods:classMethods synthesized:synthedClassMethds comments:options.addSymbolImageComments stripCtor:NO stripDtor:NO];
    [self _appendLines:build methods:instanceMethods synthesized:synthedInstcMethds comments:options.addSymbolImageComments stripCtor:options.stripCtorMethod stripDtor:options.stripDtorMethod];
    
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

- (void)_appendLines:(CDSemanticString *)build methods:(NSArray<CDMethodModel *> *)methods synthesized:(NSArray<NSString *> *)synthesized comments:(BOOL)comments stripCtor:(BOOL)stripCtor stripDtor:(BOOL)stripDtor {
    if (methods.count - synthesized.count) {
        [build appendString:@"\n" semanticType:CDSemanticTypeStandard];
        
        Dl_info info;
        NSMutableArray<NSString *> *synthed = [NSMutableArray arrayWithArray:synthesized];
        if (stripCtor) {
            [synthed addObject:@".cxx_construct"];
        }
        if (stripDtor) {
            [synthed addObject:@".cxx_destruct"];
        }
        NSUInteger synthedCount = synthed.count;
        for (CDMethodModel *methd in methods) {
            // find and remove instead of just find so we don't have to search the entire
            // array everytime, when we know the objects that we've already filtered out won't come up again
            NSUInteger const searchResult = [synthed indexOfObject:methd.name inRange:NSMakeRange(0, synthedCount)];
            if (searchResult != NSNotFound) {
                synthedCount--;
                // optimized version of remove since the
                // order of synthed doesn't matter to us.
                // exchange is O(1) instead of remove is O(n)
                [synthed exchangeObjectAtIndex:searchResult withObjectAtIndex:synthedCount];
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

- (NSSet<NSString *> *)_forwardDeclarableClassReferences {
    NSMutableSet<NSString *> *build = [NSMutableSet set];
    
    [self _unionReferences:build sources:self.classProperties resolve:^NSSet<NSString *> *(CDPropertyModel *model) {
        return [model.type classReferences];
    }];
    [self _unionReferences:build sources:self.instanceProperties resolve:^NSSet<NSString *> *(CDPropertyModel *model) {
        return [model.type classReferences];
    }];
    
    [self _unionReferences:build sources:self.classMethods resolve:^NSSet<NSString *> *(CDMethodModel *model) {
        return [model classReferences];
    }];
    [self _unionReferences:build sources:self.instanceMethods resolve:^NSSet<NSString *> *(CDMethodModel *model) {
        return [model classReferences];
    }];
    
    [self _unionReferences:build sources:self.ivars resolve:^NSSet<NSString *> *(CDIvarModel *model) {
        return [model.type classReferences];
    }];
    
    [build removeObject:self.name];
    return build;
}

- (NSSet<NSString *> *)_forwardDeclarableProtocolReferences {
    NSMutableSet<NSString *> *build = [NSMutableSet set];
    
    [self _unionReferences:build sources:self.classProperties resolve:^NSSet<NSString *> *(CDPropertyModel *model) {
        return [model.type protocolReferences];
    }];
    [self _unionReferences:build sources:self.instanceProperties resolve:^NSSet<NSString *> *(CDPropertyModel *model) {
        return [model.type protocolReferences];
    }];
    
    [self _unionReferences:build sources:self.classMethods resolve:^NSSet<NSString *> *(CDMethodModel *model) {
        return [model protocolReferences];
    }];
    [self _unionReferences:build sources:self.instanceMethods resolve:^NSSet<NSString *> *(CDMethodModel *model) {
        return [model protocolReferences];
    }];
    
    [self _unionReferences:build sources:self.ivars resolve:^NSSet<NSString *> *(CDIvarModel *model) {
        return [model.type protocolReferences];
    }];
    
    return build;
}

- (NSSet<NSString *> *)classReferences {
    NSMutableSet<NSString *> *build = [NSMutableSet set];
    
    NSSet<NSString *> *forwardDeclarable = [self _forwardDeclarableClassReferences];
    if (forwardDeclarable != nil) {
        [build unionSet:forwardDeclarable];
    }
    
    Class const superclass = class_getSuperclass(self.backing);
    if (superclass != NULL) {
        [build addObject:NSStringFromClass(superclass)];
    }
    
    return build;
}

- (NSSet<NSString *> *)protocolReferences {
    NSMutableSet<NSString *> *build = [NSMutableSet set];
    
    NSSet<NSString *> *forwardDeclarable = [self _forwardDeclarableProtocolReferences];
    if (forwardDeclarable != nil) {
        [build unionSet:forwardDeclarable];
    }
    
    for (CDProtocolModel *protocol in self.protocols) {
        [build addObject:protocol.name];
    }
    
    return build;
}

- (void)_unionReferences:(NSMutableSet<NSString *> *)build sources:(NSArray *)sources resolve:(NSSet<NSString *> *(NS_NOESCAPE ^)(id))resolver {
    for (id source in sources) {
        NSSet<NSString *> *refs = resolver(source);
        if (refs != nil) {
            [build unionSet:refs];
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
