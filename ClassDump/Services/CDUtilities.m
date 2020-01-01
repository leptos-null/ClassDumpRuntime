//
//  CDUtilities.m
//  ClassDump
//
//  Created by Leptos on 5/10/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "CDUtilities.h"

#import <dlfcn.h>
#import <sys/stat.h>
#import <sys/mman.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
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


/* from dyld/launch-cache/dyld_cache_format.h */
struct dyld_cache_header {
    char magic[16];               // e.g. "dyld_v0    i386"
    uint32_t mappingOffset;       // file offset to first dyld_cache_mapping_info
    uint32_t mappingCount;        // number of dyld_cache_mapping_info entries
    uint32_t imagesOffset;        // file offset to first dyld_cache_image_info
    uint32_t imagesCount;         // number of dyld_cache_image_info entries
    uint64_t dyldBaseAddress;     // base address of dyld when cache was built
    uint64_t codeSignatureOffset; // file offset of code signature blob
    uint64_t codeSignatureSize;   // size of code signature blob (zero means to end of file)
    uint64_t slideInfoOffset;     // file offset of kernel slid info
    uint64_t slideInfoSize;       // size of kernel slid info
    uint64_t localSymbolsOffset;  // file offset of where local symbols are stored
    uint64_t localSymbolsSize;    // size of local symbols information
    uuid_t uuid;                  // unique value for each shared cache file
};

struct dyld_cache_mapping_info {
    uint64_t address;
    uint64_t size;
    uint64_t fileOffset;
    uint32_t maxProt;
    uint32_t initProt;
};

struct dyld_cache_image_info {
    uint64_t address;
    uint64_t modTime;
    uint64_t inode;
    uint32_t pathFileOffset;
    uint32_t pad;
};

#define MACOSX_DYLD_SHARED_CACHE_DIR "/var/db/dyld/"
#define IPHONE_DYLD_SHARED_CACHE_DIR "/System/Library/Caches/com.apple.dyld/"
#define DYLD_SHARED_CACHE_BASE_NAME "dyld_shared_cache_"
/* end dyld/launch-cache/dyld_cache_format.h */

/* from dyld/src/dyld.cpp */
#if __i386__
#    define ARCH_NAME                   "i386"
#    define ARCH_CACHE_MAGIC "dyld_v1    i386"
#elif __x86_64__
#    define ARCH_NAME                 "x86_64"
#    define ARCH_CACHE_MAGIC "dyld_v1  x86_64"
#elif __ARM_ARCH_5TEJ__
#    define ARCH_NAME                  "armv5"
#    define ARCH_CACHE_MAGIC "dyld_v1   armv5"
#elif __ARM_ARCH_6K__
#    define ARCH_NAME                  "armv6"
#    define ARCH_CACHE_MAGIC "dyld_v1   armv6"
#elif __ARM_ARCH_7F__
#    define ARCH_NAME                 "armv7f"
#    define ARCH_CACHE_MAGIC "dyld_v1  armv7f"
#elif __ARM_ARCH_7K__
#    define ARCH_NAME                 "armv7k"
#    define ARCH_CACHE_MAGIC "dyld_v1  armv7k"
#elif __ARM_ARCH_7A__
#    define ARCH_NAME                  "armv7"
#    define ARCH_CACHE_MAGIC "dyld_v1   armv7"
#elif __ARM_ARCH_7S__
#    define ARCH_NAME                 "armv7s"
#    define ARCH_CACHE_MAGIC "dyld_v1  armv7s"
#elif __arm64__
#    define ARCH_NAME                  "arm64"
#    define ARCH_CACHE_MAGIC "dyld_v1   arm64"
#endif
/* end dyld/src/dyld.cpp */

#if TARGET_OS_SIMULATOR
#    warning This code is not intended to be run in a simulator, most likely the cache will not be found
#endif

// this check is not in the dyld source
_Static_assert(sizeof(ARCH_CACHE_MAGIC) == sizeof(((struct dyld_cache_header *)0)->magic),
               "Cache magic must match struct field size");

@implementation CDUtilities

+ (NSArray<NSString *> *)dynamicMachImages {
    NSMutableSet<NSString *> *ret = [NSMutableSet setWithArray:[self _dyldImages]];
    
    NSArray<NSString *> *searchDirs = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSAllDomainsMask, YES);
    for (NSString *searchDir in searchDirs) {
        [ret addObjectsFromArray:[self _imagePathsForBundleParentPath:[searchDir stringByAppendingPathComponent:@"Frameworks"]]];
        [ret addObjectsFromArray:[self _imagePathsForBundleParentPath:[searchDir stringByAppendingPathComponent:@"PrivateFrameworks"]]];
    }
    
    return ret.allObjects;
}

+ (NSArray<NSString *> *)_imagePathsForBundleParentPath:(NSString *)parentPath {
    NSMutableArray<NSString *> *ret = [NSMutableArray array];
    NSArray<NSString *> *contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:parentPath error:NULL];
    for (NSString *content in contents) {
        NSString *fullPath = [parentPath stringByAppendingPathComponent:content];
        NSBundle *bundle = [NSBundle bundleWithPath:fullPath];
        NSString *targetPath = bundle.executablePath.stringByResolvingSymlinksInPath;
        if (targetPath) {
            [ret addObject:targetPath];
        }
        [ret addObjectsFromArray:[self _imagePathsForBundleParentPath:bundle.sharedFrameworksPath]];
        [ret addObjectsFromArray:[self _imagePathsForBundleParentPath:bundle.privateFrameworksPath]];
    }
    return ret;
}

+ (NSMutableArray<NSString *> *)_dyldImages {
    const char *cache_file_dir = getenv("DYLD_SHARED_CACHE_DIR");
    if (cache_file_dir == NULL) {
#if TARGET_OS_IPHONE
        cache_file_dir = IPHONE_DYLD_SHARED_CACHE_DIR;
#else
        cache_file_dir = MACOSX_DYLD_SHARED_CACHE_DIR;
#endif
    }
    const size_t cache_file_dir_len = strlen(cache_file_dir);
    const size_t cache_file_path_size = cache_file_dir_len + strlen(DYLD_SHARED_CACHE_BASE_NAME ARCH_NAME) + 2;
    char cache_file_path[cache_file_path_size];
    strncpy(cache_file_path, cache_file_dir, cache_file_path_size);
    strncpy(cache_file_path + cache_file_dir_len, DYLD_SHARED_CACHE_BASE_NAME ARCH_NAME, cache_file_path_size);
    // cache_file_path[cache_file_path_size - 2] is set to 0 by strncpy
    cache_file_path[cache_file_path_size - 1] = '\0';
    
    /* modified from dyld/src/dyld.cpp */
#if __x86_64__
    struct host_basic_info hostInfo;
    mach_msg_type_number_t basicHostInfoReq = HOST_BASIC_INFO_COUNT;
    const mach_port_t hostPort = mach_host_self();
    const kern_return_t hostInfoResult = host_info(hostPort, HOST_BASIC_INFO, (host_info_t)&hostInfo, &basicHostInfoReq);
    mach_port_deallocate(mach_task_self_, hostPort);
    if (hostInfoResult == KERN_SUCCESS && hostInfo.cpu_subtype == CPU_SUBTYPE_X86_64_H) {
        cache_file_path[cache_file_path_size - 2] = 'h';
    }
#endif
    /* end dyldsrc/dyld.cpp */
    
    /* modified from dyld/launch-cache/dsc_extractor.cpp */
    struct stat statbuf;
    if (stat(cache_file_path, &statbuf)) {
        return NULL;
    }
    
    const int cache_fd = open(cache_file_path, O_RDONLY);
    if (cache_fd < 0) {
        return NULL;
    }
    
    const off_t cache_size = statbuf.st_size;
    void *const mapped_cache = mmap(NULL, cache_size, PROT_READ, MAP_PRIVATE, cache_fd, 0);
    close(cache_fd);
    if (mapped_cache == MAP_FAILED) {
        return NULL;
    }
    /* end dyld/launch-cache/dsc_extractor.cpp */
    
    /* modified from dyld/launch-cache/dsc_iterator.cpp */
    if (cache_size < sizeof(struct dyld_cache_header)) {
        munmap(mapped_cache, cache_size);
        return NULL;
    }
    const struct dyld_cache_header     *const header = mapped_cache;
    const struct dyld_cache_image_info *const dylibs = &mapped_cache[header->imagesOffset];
    
    NSMutableArray<NSString *> *ret = [NSMutableArray arrayWithCapacity:header->imagesCount];
    for (uint32_t imageIndex = 0; imageIndex < header->imagesCount; imageIndex++) {
        const char *dylibPath = mapped_cache + dylibs[imageIndex].pathFileOffset;
        [ret addObject:@(dylibPath)];
    }
    /* end dyld/launch-cache/dsc_iterator.cpp */
    
    munmap(mapped_cache, cache_size);
    return ret;
}

@end
