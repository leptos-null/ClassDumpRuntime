//
//  CDParseType.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ClassDump/CDSemanticString.h>

typedef NS_ENUM(NSUInteger, CDTypeModifier) {
    CDTypeModifierConst,
    CDTypeModifierComplex,
    CDTypeModifierAtomic,
    
    CDTypeModifierIn,
    CDTypeModifierInOut,
    CDTypeModifierOut,
    CDTypeModifierBycopy,
    CDTypeModifierByref,
    CDTypeModifierOneway,
    
    /// The number of valid cases there are in @c CDTypeModifier
    CDTypeModifierCount
};

NS_HEADER_AUDIT_BEGIN(nullability)

OBJC_EXTERN NSString *_Nullable NSStringFromCDTypeModifier(CDTypeModifier);

/// Base class to represent a type that a variable may be
@interface CDParseType : NSObject

@property (nullable, strong, nonatomic) NSArray<NSNumber *> *modifiers; // array of CDTypeModifier

/// A string as this type would appear in code for a given variable name.
///
/// @param varName The name of the variable this type is for
- (NSString *)stringForVariableName:(nullable NSString *)varName;

- (NSString *)modifiersString;

- (CDSemanticString *)semanticStringForVariableName:(nullable NSString *)varName;

- (CDSemanticString *)modifiersSemanticString;

/// Classes this type references
///
/// For example, `NSCache<NSFastEnumeration> *` references the "NSCache" class
- (nullable NSSet<NSString *> *)classReferences;
/// Protocols this type references
///
/// For example, `NSCache<NSFastEnumeration> *` references the "NSFastEnumeration" protocol
- (nullable NSSet<NSString *> *)protocolReferences;

@end

NS_HEADER_AUDIT_END(nullability)
