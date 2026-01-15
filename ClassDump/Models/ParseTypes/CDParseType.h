//
//  CDParseType.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ClassDump/CDSemanticString.h>
#import <ClassDump/CDTypeFormatOptions.h>

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

- (nonnull NSString *)modifiersString;

- (nonnull CDSemanticString *)modifiersSemanticString;

- (nonnull CDSemanticString *)semanticStringForVariableName:(nullable NSString *)varName indentationLevel:(NSUInteger)indentationLevel formatOptions:(nullable CDTypeFormatOptions *)formatOptions;

/// Classes this type references
///
/// For example, `NSCache<NSFastEnumeration> *` references the "NSCache" class
- (nullable NSSet<NSString *> *)classReferences;
/// Protocols this type references
///
/// For example, `NSCache<NSFastEnumeration> *` references the "NSFastEnumeration" protocol
- (nullable NSSet<NSString *> *)protocolReferences;

@end
