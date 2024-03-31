//
//  CDParseType.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !__has_include(<ClassDump/ClassDump.h>)
#import "../CDSemanticString.h"
#else
#import <ClassDump/CDSemanticString.h>
#endif

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

OBJC_EXTERN NSString *_Nullable NSStringFromCDTypeModifier(CDTypeModifier);

/// Base class to represent a type that a variable may be
@interface CDParseType : NSObject

@property (nullable, strong, nonatomic) NSArray<NSNumber *> *modifiers; // array of CDTypeModifier

/// A string as this type would appear in code for a given variable name.
///
/// @param varName The name of the variable this type is for
- (nonnull NSString *)stringForVariableName:(nullable NSString *)varName;

- (nonnull NSString *)modifiersString;

- (nonnull CDSemanticString *)semanticStringForVariableName:(nullable NSString *)varName;

- (nonnull CDSemanticString *)modifiersSemanticString;

/// Classes this type references
///
/// For example, `NSCache<NSFastEnumeration> *` references the "NSCache" class
- (nullable NSSet<NSString *> *)classReferences;
/// Protocols this type references
///
/// For example, `NSCache<NSFastEnumeration> *` references the "NSFastEnumeration" protocol
- (nullable NSSet<NSString *> *)protocolReferences;

@end
