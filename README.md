## ClassDumpRuntime

Create human readable interfaces from runtime Objective-C environments.

This library is intended to be compiled with Xcode or [Theos](https://github.com/theos/theos).
The library can be loaded into an Objective-C runtime to view class or protocol headers.

Example:

```objc
CDClassModel *ortho = [CDClassModel modelWithClass:[NSOrthography class]];

[ortho linesWithComments:NO synthesizeStrip:YES];
/*
@interface NSOrthography : NSObject <NSCopying, NSSecureCoding>

@property (class, readonly) BOOL supportsSecureCoding;

@property (readonly, copy) NSString *dominantScript;
@property (readonly, copy) NSDictionary *languageMap;

+ (id)orthographyWithDominantScript:(id)a0 languageMap:(id)a1;
+ (id)_scriptNameForScriptIndex:(unsigned long long)a0;
+ (void)initialize;
+ (id)allocWithZone:(struct _NSZone { } *)a0;

- (id)initWithDominantScript:(id)a0 languageMap:(id)a1;
- (unsigned int)orthographyFlags;
- (id)dominantLanguage;
- (id)allScripts;
- (id)languagesForScript:(id)a0;
- (id)replacementObjectForPortCoder:(id)a0;
- (id)dominantLanguageForScript:(id)a0;
- (id)allLanguages;
- (id)initWithCoder:(id)a0;
- (void)encodeWithCoder:(id)a0;
- (BOOL)isEqual:(id)a0;
- (unsigned long long)hash;
- (id)description;
- (id)copyWithZone:(struct _NSZone { } *)a0;
- (Class)classForCoder;

@end
*/

[ortho linesWithComments:NO synthesizeStrip:NO];
/*
@interface NSOrthography : NSObject <NSCopying, NSSecureCoding>

@property (class, readonly) BOOL supportsSecureCoding;

@property (readonly, copy) NSString *dominantScript;
@property (readonly, copy) NSDictionary *languageMap;

+ (id)orthographyWithDominantScript:(id)a0 languageMap:(id)a1;
+ (id)_scriptNameForScriptIndex:(unsigned long long)a0;
+ (void)initialize;
+ (id)allocWithZone:(struct _NSZone { } *)a0;
+ (BOOL)supportsSecureCoding;

- (id)initWithDominantScript:(id)a0 languageMap:(id)a1;
- (unsigned int)orthographyFlags;
- (id)dominantScript;
- (id)languageMap;
- (id)dominantLanguage;
- (id)allScripts;
- (id)languagesForScript:(id)a0;
- (id)replacementObjectForPortCoder:(id)a0;
- (id)dominantLanguageForScript:(id)a0;
- (id)allLanguages;
- (id)initWithCoder:(id)a0;
- (void)encodeWithCoder:(id)a0;
- (BOOL)isEqual:(id)a0;
- (unsigned long long)hash;
- (id)description;
- (id)copyWithZone:(struct _NSZone { } *)a0;
- (Class)classForCoder;

@end
*/

[ortho.protocols[1] linesWithComments:NO synthesizeStrip:YES];
/*
@protocol NSSecureCoding <NSCoding>

+ (BOOL)supportsSecureCoding;

@end
*/
```
