//
//  CDUtilities.m
//  ClassDump
//
//  Created by Leptos on 5/10/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "CDUtilities.h"

#import <mach-o/dyld_images.h>
#import <objc/runtime.h>


/* Portions of code in this file have been explicitly copied from Apple's dyld
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */

// https://github.com/apple-oss-distributions/dyld/blob/c8a445f88f/cache-builder/dyld_cache_format.h#L31
struct dyld_cache_header
{
    char        magic[16];              // e.g. "dyld_v0    i386"
    uint32_t    mappingOffset;          // file offset to first dyld_cache_mapping_info
    uint32_t    mappingCount;           // number of dyld_cache_mapping_info entries
    uint32_t    imagesOffsetOld;        // UNUSED: moved to imagesOffset to prevent older dsc_extarctors from crashing
    uint32_t    imagesCountOld;         // UNUSED: moved to imagesCount to prevent older dsc_extarctors from crashing
    uint64_t    dyldBaseAddress;        // base address of dyld when cache was built
    uint64_t    codeSignatureOffset;    // file offset of code signature blob
    uint64_t    codeSignatureSize;      // size of code signature blob (zero means to end of file)
    uint64_t    slideInfoOffsetUnused;  // unused.  Used to be file offset of kernel slid info
    uint64_t    slideInfoSizeUnused;    // unused.  Used to be size of kernel slid info
    uint64_t    localSymbolsOffset;     // file offset of where local symbols are stored
    uint64_t    localSymbolsSize;       // size of local symbols information
    uint8_t     uuid[16];               // unique value for each shared cache file
    uint64_t    cacheType;              // 0 for development, 1 for production, 2 for multi-cache
    uint32_t    branchPoolsOffset;      // file offset to table of uint64_t pool addresses
    uint32_t    branchPoolsCount;       // number of uint64_t entries
    uint64_t    dyldInCacheMH;          // (unslid) address of mach_header of dyld in cache
    uint64_t    dyldInCacheEntry;       // (unslid) address of entry point (_dyld_start) of dyld in cache
    uint64_t    imagesTextOffset;       // file offset to first dyld_cache_image_text_info
    uint64_t    imagesTextCount;        // number of dyld_cache_image_text_info entries
    uint64_t    patchInfoAddr;          // (unslid) address of dyld_cache_patch_info
    uint64_t    patchInfoSize;          // Size of all of the patch information pointed to via the dyld_cache_patch_info
    uint64_t    otherImageGroupAddrUnused;    // unused
    uint64_t    otherImageGroupSizeUnused;    // unused
    uint64_t    progClosuresAddr;       // (unslid) address of list of program launch closures
    uint64_t    progClosuresSize;       // size of list of program launch closures
    uint64_t    progClosuresTrieAddr;   // (unslid) address of trie of indexes into program launch closures
    uint64_t    progClosuresTrieSize;   // size of trie of indexes into program launch closures
    uint32_t    platform;               // platform number (macOS=1, etc)
    uint32_t    formatVersion          : 8,  // dyld3::closure::kFormatVersion
    dylibsExpectedOnDisk   : 1,  // dyld should expect the dylib exists on disk and to compare inode/mtime to see if cache is valid
    simulator              : 1,  // for simulator of specified platform
    locallyBuiltCache      : 1,  // 0 for B&I built cache, 1 for locally built cache
    builtFromChainedFixups : 1,  // some dylib in cache was built using chained fixups, so patch tables must be used for overrides
    padding                : 20; // TBD
    uint64_t    sharedRegionStart;      // base load address of cache if not slid
    uint64_t    sharedRegionSize;       // overall size required to map the cache and all subCaches, if any
    uint64_t    maxSlide;               // runtime slide of cache can be between zero and this value
    uint64_t    dylibsImageArrayAddr;   // (unslid) address of ImageArray for dylibs in this cache
    uint64_t    dylibsImageArraySize;   // size of ImageArray for dylibs in this cache
    uint64_t    dylibsTrieAddr;         // (unslid) address of trie of indexes of all cached dylibs
    uint64_t    dylibsTrieSize;         // size of trie of cached dylib paths
    uint64_t    otherImageArrayAddr;    // (unslid) address of ImageArray for dylibs and bundles with dlopen closures
    uint64_t    otherImageArraySize;    // size of ImageArray for dylibs and bundles with dlopen closures
    uint64_t    otherTrieAddr;          // (unslid) address of trie of indexes of all dylibs and bundles with dlopen closures
    uint64_t    otherTrieSize;          // size of trie of dylibs and bundles with dlopen closures
    uint32_t    mappingWithSlideOffset; // file offset to first dyld_cache_mapping_and_slide_info
    uint32_t    mappingWithSlideCount;  // number of dyld_cache_mapping_and_slide_info entries
    uint64_t    dylibsPBLStateArrayAddrUnused;    // unused
    uint64_t    dylibsPBLSetAddr;           // (unslid) address of PrebuiltLoaderSet of all cached dylibs
    uint64_t    programsPBLSetPoolAddr;     // (unslid) address of pool of PrebuiltLoaderSet for each program
    uint64_t    programsPBLSetPoolSize;     // size of pool of PrebuiltLoaderSet for each program
    uint64_t    programTrieAddr;            // (unslid) address of trie mapping program path to PrebuiltLoaderSet
    uint32_t    programTrieSize;
    uint32_t    osVersion;                  // OS Version of dylibs in this cache for the main platform
    uint32_t    altPlatform;                // e.g. iOSMac on macOS
    uint32_t    altOsVersion;               // e.g. 14.0 for iOSMac
    uint64_t    swiftOptsOffset;        // VM offset from cache_header* to Swift optimizations header
    uint64_t    swiftOptsSize;          // size of Swift optimizations header
    uint32_t    subCacheArrayOffset;    // file offset to first dyld_subcache_entry
    uint32_t    subCacheArrayCount;     // number of subCache entries
    uint8_t     symbolFileUUID[16];     // unique value for the shared cache file containing unmapped local symbols
    uint64_t    rosettaReadOnlyAddr;    // (unslid) address of the start of where Rosetta can add read-only/executable data
    uint64_t    rosettaReadOnlySize;    // maximum size of the Rosetta read-only/executable region
    uint64_t    rosettaReadWriteAddr;   // (unslid) address of the start of where Rosetta can add read-write data
    uint64_t    rosettaReadWriteSize;   // maximum size of the Rosetta read-write region
    uint32_t    imagesOffset;           // file offset to first dyld_cache_image_info
    uint32_t    imagesCount;            // number of dyld_cache_image_info entries
    uint32_t    cacheSubType;           // 0 for development, 1 for production, when cacheType is multi-cache(2)
    uint64_t    objcOptsOffset;         // VM offset from cache_header* to ObjC optimizations header
    uint64_t    objcOptsSize;           // size of ObjC optimizations header
    uint64_t    cacheAtlasOffset;       // VM offset from cache_header* to embedded cache atlas for process introspection
    uint64_t    cacheAtlasSize;         // size of embedded cache atlas
    uint64_t    dynamicDataOffset;      // VM offset from cache_header* to the location of dyld_cache_dynamic_data_header
    uint64_t    dynamicDataMaxSize;     // maximum size of space reserved from dynamic data
};

// https://github.com/apple-oss-distributions/dyld/blob/c8a445f88f/cache-builder/dyld_cache_format.h#L142
struct dyld_cache_image_info
{
    uint64_t    address;
    uint64_t    modTime;
    uint64_t    inode;
    uint32_t    pathFileOffset;
    uint32_t    pad;
};


@implementation CDUtilities

+ (NSArray<NSString *> *)dyldSharedCacheImagePaths {
    // thanks to https://github.com/EthanArbuckle/dlopen_handle_info/blob/054ea7019a/dlopen_handle.m#L84
    struct task_dyld_info dyld_info;
    mach_msg_type_number_t count = TASK_DYLD_INFO_COUNT;
    task_info(mach_task_self_, TASK_DYLD_INFO, (task_info_t)&dyld_info, &count);
    
    struct dyld_all_image_infos *dyld_runtime_infos = (struct dyld_all_image_infos *)dyld_info.all_image_info_addr;
    const void *const shared_cache_base = (const void *)dyld_runtime_infos->sharedCacheBaseAddress;
    
    const struct dyld_cache_header *const cache_header = shared_cache_base;
    
    // I believe this changed with iOS 14
    BOOL usesOld = (cache_header->imagesCountOld != 0);
    const uint32_t images_offset = usesOld ? cache_header->imagesOffsetOld : cache_header->imagesOffset;
    const uint32_t image_count = usesOld ? cache_header->imagesCountOld : cache_header->imagesCount;
    
    const struct dyld_cache_image_info *const image_info = shared_cache_base + images_offset;
    
    NSMutableArray<NSString *> *ret = [NSMutableArray arrayWithCapacity:image_count];
    for (uint32_t imageIndex = 0; imageIndex < image_count; imageIndex++) {
        const char *dylibPath = shared_cache_base + image_info[imageIndex].pathFileOffset;
        [ret addObject:@(dylibPath)];
    }
    return ret;
}

+ (NSArray<NSString *> *)classNames {
    unsigned int classCount = 0;
    Class *const classList = objc_copyClassList(&classCount);
    
    NSMutableArray<NSString *> *ret = [NSMutableArray arrayWithCapacity:classCount];
    
    for (unsigned int classIndex = 0; classIndex < classCount; classIndex++) {
        Class __unsafe_unretained const cls = classList[classIndex];
        [ret addObject:NSStringFromClass(cls)];
    }
    free(classList);
    
    return ret;
}

+ (BOOL)isClassSafeToInspect:(NSString *)className {
    Class __unsafe_unretained const cls = NSClassFromString(className);
    if (cls == NULL) {
        return NO;
    }
    return class_respondsToSelector(cls, @selector(respondsToSelector:));
}

@end
