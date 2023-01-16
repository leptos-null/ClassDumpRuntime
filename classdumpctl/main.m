//
//  main.m
//  classdumpctl
//
//  Created by Leptos on 1/10/23.
//  Copyright © 2023 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <getopt.h>

#import <ClassDump/ClassDump.h>

static void printUsage(const char *progname) {
    printf("Usage: %s [options]\n"
           "Dump all the classes in the dyld shared cache\n"
           "Options:\n"
           "  -j <N>, --jobs=N              Allow N jobs at once (defaults to number of processing core available)\n"
           "  -o <path>, --output=path      Use path as the output directory\n"
           "", progname);
}

int main(int argc, char *argv[]) {
    NSUInteger maxJobs = NSProcessInfo.processInfo.processorCount;
    NSString *outputDir = nil;
    
    struct option const options[] = {
        { "jobs",   required_argument, NULL, 'j' },
        { "output", required_argument, NULL, 'o' },
        { NULL,     0,                 NULL,  0  }
    };
    
    int ch;
    while ((ch = getopt_long(argc, argv, ":j:o:", options, NULL)) != -1) {
        switch (ch) {
            case 'j':
                maxJobs = strtoul(optarg, NULL, 10);
                break;
            case 'o':
                outputDir = @(optarg);
                break;
            default: {
                printUsage(argv[0]);
                return 1;
            } break;
        }
    }
    
    if (outputDir == nil) {
        printUsage(argv[0]);
        return 1;
    }

    NSFileManager *const fileManager = NSFileManager.defaultManager;

    if ([fileManager fileExistsAtPath:outputDir]) {
        fprintf(stderr, "%s already exists\n", outputDir.fileSystemRepresentation);
        return 1;
    }
    
    NSArray<NSString *> *const imagePaths = [CDUtilities dyldSharedCacheImagePaths];
    
    NSMutableDictionary<NSNumber *, NSString *> *const pidToPath = [NSMutableDictionary dictionaryWithCapacity:maxJobs];
    
    // just doing this once so all children have everything initialized that they should need
    [[CDClassModel modelWithClass:NSClassFromString(@"NSObject")] linesWithComments:YES synthesizeStrip:YES];
    [[CDProtocolModel modelWithProtocol:NSProtocolFromString(@"NSObject")] linesWithComments:YES synthesizeStrip:YES];
    
    IMP const blankIMP = imp_implementationWithBlock(^{ }); // returns void, takes no parameters
    
    NSUInteger activeJobs = 0;
    NSUInteger badExitCount = 0;
    NSUInteger finishedImageCount = 0;
    
    NSUInteger const imagePathCount = imagePaths.count;
    for (NSUInteger imageIndex = 0; (imageIndex < imagePathCount) || (activeJobs > 0); imageIndex++) {
        BOOL const hasImagePath = (imageIndex < imagePathCount);
        
        if (!hasImagePath || (activeJobs >= maxJobs)) {
            int childStatus = 0;
            pid_t const childPid = wait(&childStatus);
            activeJobs--;
            
            if (childPid < 0) {
                perror("wait");
                return 1;
            }
            NSNumber *key = @(childPid);
            NSString *path = pidToPath[key];
            [pidToPath removeObjectForKey:key];
            finishedImageCount++;
            
            if (WIFEXITED(childStatus)) {
                int const exitStatus = WEXITSTATUS(childStatus);
                if (exitStatus != 0) {
                    printf("Child for '%s' exited with status %d\n", path.fileSystemRepresentation, exitStatus);
                    badExitCount++;
                }
            } else if (WIFSIGNALED(childStatus)) {
                printf("Child for '%s' signaled with signal %d\n", path.fileSystemRepresentation, WTERMSIG(childStatus));
                badExitCount++;
            } else {
                printf("Child for '%s' did not finish cleanly\n", path.fileSystemRepresentation);
                badExitCount++;
            }
            printf("  %lu/%lu\r", finishedImageCount, imagePathCount);
            fflush(stdout); // important to flush after using '\r', but also critical to flush (if needed) before calling `fork`
        }
        if (hasImagePath) {
            NSString *imagePath = imagePaths[imageIndex];
            
            pid_t const forkStatus = fork();
            if (forkStatus < 0) {
                perror("fork");
                return 1;
            }
            if (forkStatus == 0) {
                // child
                NSString *topDir = [outputDir stringByAppendingPathComponent:imagePath];
                
                NSError *error = nil;
                if (![fileManager createDirectoryAtPath:topDir withIntermediateDirectories:YES attributes:nil error:&error]) {
                    NSLog(@"createDirectoryAtPathError: %@", error);
                    return 1;
                }
                NSString *logPath = [topDir stringByAppendingPathComponent:@"log.txt"];

                int const logHandle = open(logPath.fileSystemRepresentation, O_WRONLY | O_CREAT | O_EXCL, 0644);
                assert(logHandle >= 0);
                dup2(logHandle, STDOUT_FILENO);
                dup2(logHandle, STDERR_FILENO);
                
                dlerror(); // clear
                void *imageHandle = dlopen(imagePath.fileSystemRepresentation, RTLD_NOW);
                const char *dlerr = dlerror();
                if (dlerr != NULL) {
                    printf("dlerror: %s\n", dlerr);
                }
                if (imageHandle == NULL) {
                    return 1;
                }
                
                // use a group so we can make sure all the work items finish before we exit the program
                dispatch_group_t const linesWriteGroup = dispatch_group_create();
                // perform file system writes on another thread so we don't unnecessarily block our CPU work
                dispatch_queue_t const linesWriteQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
                
                unsigned int classCount = 0;
                const char **classNames = objc_copyClassNamesForImage(imagePath.fileSystemRepresentation, &classCount);
                for (unsigned int classIndex = 0; classIndex < classCount; classIndex++) {
                    Class const cls = objc_getClass(classNames[classIndex]);
                    
                    Method const initializeMthd = class_getClassMethod(cls, @selector(initialize));
                    method_setImplementation(initializeMthd, blankIMP);
                    
                    if (class_getInstanceMethod(cls, @selector(doesNotRecognizeSelector:)) == NULL) {
                        continue;
                    }
                    // creating the model and generating the "lines" both use
                    // functions that grab the objc runtime lock, so putting either of
                    // these on another thread is not efficient, as they would just be blocked
                    CDClassModel *model = [CDClassModel modelWithClass:cls];
                    NSString *lines = [model linesWithComments:NO synthesizeStrip:YES];
                    NSString *headerName = [NSStringFromClass(cls) stringByAppendingPathExtension:@"h"];
                    
                    dispatch_group_async(linesWriteGroup, linesWriteQueue, ^{
                        NSString *headerPath = [topDir stringByAppendingPathComponent:headerName];
                        [lines writeToFile:headerPath atomically:NO encoding:NSUTF8StringEncoding error:NULL];
                    });
                }
                
                dispatch_group_wait(linesWriteGroup, DISPATCH_TIME_FOREVER);
                
                free(classNames);
                dlclose(imageHandle);
                
                close(logHandle);
                unlink(logPath.fileSystemRepresentation);
                
                return 0;
            }
            
            pidToPath[@(forkStatus)] = imagePath;
            activeJobs++;
        }
    }
    
    printf("%lu images in dyld_shared_cache\n", (unsigned long)imagePaths.count);
    printf("Failed to load %lu images\n", (unsigned long)badExitCount);
    return 0;
}
