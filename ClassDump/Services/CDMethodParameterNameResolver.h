//
//  CDMethodParameterNameResolver.h
//  ClassDump
//
//  Created by Leptos on 1/11/26.
//  Copyright © 2026 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

/// A function that produces a parameter name for a given parameter in a method.
///
/// The returned value must be a valid identifier in the C language.
///
/// For example, consider the method
/// ```objc
/// - (NSUInteger)replaceOccurrencesOfString:(id)target withString:(id)replacement options:(NSUInteger)options range:(NSRange)searchRange;
/// ```
///
/// The `selectorComponents` for this method would be
/// ```objc
/// @[
///     @"replaceOccurrencesOfString",
///     @"withString",
///     @"options",
///     @"range"
/// ]
/// ```
/// The `componentIndex` is the index to produce a name for.
///
/// For example, an implementation that handles the example above may be
/// ```objc
/// switch (componentIndex) {
///     case 0:
///         return @"target";
///     case 1:
///         return @"replacement";
///     case 2:
///         return @"options";
///     case 3:
///         return @"searchRange";
/// }
/// ```
typedef NSString *_Nullable (*CDMethodParameterNameResolver)(NSArray<NSString *> *_Nonnull selectorComponents, NSUInteger componentIndex);

/// Each parameter is named with a consecutive number
///
/// For example
/// ```objc
/// - (BOOL)loadFromURL:(id)a1 error:(id *)a2;
/// ```
///
/// The numbers are formatted in decimal (base 10)
NSString *_Nonnull CDMethodParameterNameNumberedResolver(NSArray<NSString *> *_Nullable selectorComponents, NSUInteger componentIndex);
/// Applies a simple transformation using `selectorComponents`
///
/// The exact transformation is implementation defined.
///
/// The transformation may result in multiple parameters with the same name. For example
///
/// ```objc
/// - (BOOL)compareString:(id)string withString:(id)string;
/// ```
///
/// Repeating parameter names in an interface is allowed by `clang`, however this is not valid in an implementation.
NSString *_Nullable CDMethodParameterNameSimpleTransformResolver(NSArray<NSString *> *_Nonnull selectorComponents, NSUInteger componentIndex);

/// A set of identifiers that are reserved by the language.
///
/// This is provided as a convenience for functions implementing ``CDMethodParameterNameResolver``
///
/// Based on https://en.cppreference.com/w/c/keyword.html (C23)
NSSet<NSString *> *const _Nonnull CDReservedLanguageKeywords(void);
