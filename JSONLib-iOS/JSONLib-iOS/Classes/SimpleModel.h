//
//  SimpleModel.h
//  JSONLib-iOS
//
//  Created by Fabrizio on 10/04/16.
//  Copyright © 2016 Fabrizio Caldarelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONLib.h"

@interface SimpleModel : NSObject<JSONProtocol>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, assign) int age;

@end
