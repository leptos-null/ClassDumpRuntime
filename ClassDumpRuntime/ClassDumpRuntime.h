//
//  ClassDumpRuntime.h
//  ClassDumpRuntime
//
//  Created by Leptos on 3/24/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

// to support building as both an Xcode framework and a Swift Package,
// all headers that are marked as "public" for the Xcode framework
// should have a symlink in `Sources/ClassDumpRuntime/include/ClassDumpRuntime`;
// all those files should then be imported below.
//
// you can generate these imports using a shell script such as
//   `ls ClassDumpRuntime/*.h | while read HEADER; do printf "#import <${HEADER}>\n"; done`
// (run from `Sources/ClassDumpRuntime/include`)

#import <ClassDumpRuntime/CDArrayType.h>
#import <ClassDumpRuntime/CDBitFieldType.h>
#import <ClassDumpRuntime/CDBlockType.h>
#import <ClassDumpRuntime/CDClassModel.h>
#import <ClassDumpRuntime/CDGenerationOptions.h>
#import <ClassDumpRuntime/CDIvarModel.h>
#import <ClassDumpRuntime/CDMethodModel.h>
#import <ClassDumpRuntime/CDObjectType.h>
#import <ClassDumpRuntime/CDParseType.h>
#import <ClassDumpRuntime/CDPointerType.h>
#import <ClassDumpRuntime/CDPrimitiveType.h>
#import <ClassDumpRuntime/CDPropertyAttribute.h>
#import <ClassDumpRuntime/CDPropertyModel.h>
#import <ClassDumpRuntime/CDProtocolModel+Conformance.h>
#import <ClassDumpRuntime/CDProtocolModel.h>
#import <ClassDumpRuntime/CDRecordType.h>
#import <ClassDumpRuntime/CDSemanticString.h>
#import <ClassDumpRuntime/CDTypeParser.h>
#import <ClassDumpRuntime/CDUtilities.h>
#import <ClassDumpRuntime/CDVariableModel.h>
