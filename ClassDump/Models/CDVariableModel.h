//
//  CDVariableModel.h
//  ClassDump
//
//  Created by Leptos on 12/8/22.
//  Copyright © 2022 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDParseType.h"

@interface CDVariableModel : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) CDParseType *type;

@end
