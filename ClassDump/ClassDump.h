//
//  ClassDump.h
//  ClassDump
//
//  Created by Leptos on 3/24/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

// to support building as both an Xcode framework and a Swift Package,
// all headers that are marked as "public" for the Xcode framework
// should have a symlink in `Sources/ClassDumpRuntime/include/ClassDump`;
// all those files should then be imported below.

#import <ClassDump/CDArrayType.h>
#import <ClassDump/CDBitFieldType.h>
#import <ClassDump/CDBlockType.h>
#import <ClassDump/CDClassModel.h>
#import <ClassDump/CDGenerationOptions.h>
#import <ClassDump/CDIvarModel.h>
#import <ClassDump/CDMethodModel.h>
#import <ClassDump/CDObjectType.h>
#import <ClassDump/CDParseType.h>
#import <ClassDump/CDPointerType.h>
#import <ClassDump/CDPrimitiveType.h>
#import <ClassDump/CDPropertyAttribute.h>
#import <ClassDump/CDPropertyModel.h>
#import <ClassDump/CDProtocolModel.h>
#import <ClassDump/CDRecordType.h>
#import <ClassDump/CDSemanticString.h>
#import <ClassDump/CDTypeParser.h>
#import <ClassDump/CDUtilities.h>
#import <ClassDump/CDVariableModel.h>
