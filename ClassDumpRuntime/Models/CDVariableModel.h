//
//  CDVariableModel.h
//  ClassDumpRuntime
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ClassDumpRuntime/CDParseType.h>

NS_HEADER_AUDIT_BEGIN(nullability)

@interface CDVariableModel : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) CDParseType *type;

@end

NS_HEADER_AUDIT_END(nullability)
