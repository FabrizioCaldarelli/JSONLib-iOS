//
//  User.h
//  JSONLib-iOS
//
//  Created by Fabrizio on 10/04/16.
//  Copyright © 2016 Fabrizio Caldarelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONLib.h"

@interface User : NSObject<JSONProtocol>

typedef enum {
    UserGenderMale,
    UserGenderFemale
} UserGender;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) UserGender gender;
@property (nonatomic, strong) NSArray *childNames; // array of NSString
@property (nonatomic, strong) NSArray *simpleModels;

@end
