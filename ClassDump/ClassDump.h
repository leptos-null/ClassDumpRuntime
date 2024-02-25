//
//  ClassDump.h
//  ClassDump
//
//  Created by Leptos on 3/24/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#if !__has_include(<ClassDump/ClassDump.h>)

#import "Models/Reflections/CDClassModel.h"
#import "Models/Reflections/CDProtocolModel.h"
 
#import "Services/CDUtilities.h"

#else

#import <ClassDump/CDArrayType.h>
#import <ClassDump/CDBitFieldType.h>
#import <ClassDump/CDBlockType.h>
#import <ClassDump/CDClassModel.h>
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
#import <ClassDump/CDGenerationOptions.h>

#endif /* !__has_include(<ClassDump/ClassDump.h>) */
