//
//  SimpleModel.m
//  JSONLib-iOS
//
//  Created by Fabrizio on 10/04/16.
//  Copyright © 2016 Fabrizio Caldarelli. All rights reserved.
//

#import "SimpleModel.h"

@implementation SimpleModel

#pragma mark JSONProtocol implementation
- (NSArray*)JSONProperties
{
    return @[
             [JSONProperty option:@"name" type:JSONPropertyTypeString],
             [JSONProperty option:@"surname" type:JSONPropertyTypeString],
             [JSONProperty option:@"age" type:JSONPropertyTypeInteger]
             ];
}

- (BOOL)JSONSerializeOptions:(JSONProperty *)property dictionary:(NSMutableDictionary *)dictionary error:(NSError *__autoreleasing *)error
{
    LogInfo(@"JSONSerializeOptions", @"[%@][%@]", [self class], property.name);
    return NO;
}

- (BOOL)JSONDeserializeOptions:(JSONProperty *)property dictionary:(NSMutableDictionary *)dictIn error:(NSError *__autoreleasing *)error
{
    LogInfo(@"JSONDeserializeOptions", @"[%@][%@]", [self class], property.name);
    return NO;
}

@end
