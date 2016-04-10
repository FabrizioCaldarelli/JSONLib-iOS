//
//  User.m
//  JSONLib-iOS
//
//  Created by Fabrizio on 10/04/16.
//  Copyright © 2016 Fabrizio Caldarelli. All rights reserved.
//

#import "User.h"
#import "SimpleModel.h"

@implementation User

#pragma mark JSONProtocol implementation
- (NSArray*)JSONProperties
{
    return @[
        [JSONProperty option:@"name" type:JSONPropertyTypeString],
        [JSONProperty option:@"birthday" type:JSONPropertyTypeDateTime],
        [JSONProperty option:@"age" type:JSONPropertyTypeInteger],
        [JSONProperty option:@"gender" type:JSONPropertyTypeEnum],
        [JSONProperty option:@"childNames" type:JSONPropertyTypeArrayOfString],
        [JSONProperty option:@"simpleModels" type:JSONPropertyTypeArray  itemClass:[SimpleModel class]]
    ];
}

- (BOOL)JSONSerializeOptions:(JSONProperty *)property dictionary:(NSMutableDictionary *)dictOut error:(NSError *__autoreleasing *)error
{
    if([property.name isEqualToString:@"gender"])
    {
        switch (self.gender) {
            case UserGenderMale:
                [dictOut setObject:@"male" forKey:property.name];
                break;
            case UserGenderFemale:
                [dictOut setObject:@"female" forKey:property.name];
                break;
        }
        return YES;
    }
    
    if([property.name isEqualToString:@"childNames"])
    {
        NSMutableArray *newNames = [NSMutableArray array];
        for (NSString *n in self.childNames) {
            [newNames addObject:[NSString stringWithFormat:@"NAME - %@", n]];
        }
        
        [dictOut setObject:newNames forKey:property.name];
        
        return YES;
    }
    
    return NO;
}


- (BOOL)JSONDeserializeOptions:(JSONProperty *)property dictionary:(NSDictionary *)dictIn error:(NSError *__autoreleasing *)error
{
    if([property.name isEqualToString:@"gender"])
    {
        if([[dictIn objectForKey:property.name] isEqualToString:@"male"]) self.gender = UserGenderMale;
        if([[dictIn objectForKey:property.name] isEqualToString:@"female"]) self.gender = UserGenderFemale;
        return YES;
    }
    
    return NO;
}

@end