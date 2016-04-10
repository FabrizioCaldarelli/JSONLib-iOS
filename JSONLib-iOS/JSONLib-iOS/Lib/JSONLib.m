//
//  JSONLib.m
//  JSONLib-iOS
//
//  Created by Fabrizio on 10/04/16.
//  Copyright © 2016 Fabrizio Caldarelli. All rights reserved.
//

#import "JSONLib.h"

#pragma mark -
#pragma mark JSONManager
@implementation JSONManager

// to dictionary
- (NSDictionary*)serializeToDictionary:(NSObject<JSONProtocol>*)objIn error:(NSError**)error
{
    NSMutableDictionary *dictOut = [NSMutableDictionary dictionary];
    
    NSArray *properties = [objIn JSONProperties];
    
    for (JSONProperty *p in properties) {
        
        BOOL handled = NO;
        
        if(self.serializeOptionsBlock != nil)
        {
            JSONLog(@"serializeToDictionary", @"inside serializeOptionsBlock");
            handled = self.serializeOptionsBlock(p, objIn, dictOut);
        }
        
        if(( handled == NO )&&([objIn respondsToSelector:@selector(JSONSerializeOptions:dictionary:error:)]))
        {
            JSONLog(@"serializeToDictionary", @"inside JSONSerializeOptions method override");
            handled = [objIn JSONSerializeOptions:p dictionary:dictOut error:error];
        }
        
        if(handled == NO)
        {
            JSONLog(@"serializeToDictionary", @"inside default serialization");
            [p setDictionaryEntry:dictOut fromObject:objIn withManager:self error:error];
            handled = YES;
        }
    }
    
    return dictOut;
}
- (NSArray*)serializeToArray:(NSArray*)arrIn error:(NSError**)error
{
    NSMutableArray *arrOut = nil;
    
    *error = nil;
    
    // Check if all items of array conform to JSONProtocol
    for (id itemArray in arrIn) {
        if(*error == nil)
        {
            if( [itemArray conformsToProtocol:@protocol(JSONProtocol)] )
            {
                NSDictionary *dict = [self serializeToDictionary:itemArray error:error];
                if(*error == nil) [arrOut addObject:dict];
            }
            else
            {
                arrOut = nil;
                
                NSDictionary *dictErr = @{
                                          NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Input data type wrong"],
                                          NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Item array type is (%@)", [itemArray class]],
                                          NSLocalizedRecoverySuggestionErrorKey: @"Check that input data type is NSObject<JSONProtocol>"
                                          };
                
                *error = [NSError errorWithDomain:@"JSONLib"
                                             code:JSONLibErrorCodeInvalidInputData
                                         userInfo:dictErr];
            }
        }
    }
    
    return arrOut;
}


// from dictionary
- (id<JSONProtocol>)deserializeFromDictionary:(NSDictionary*)dictIn itemClass:(Class)itemClass error:(NSError**)error
{
    *error = nil;
    
    NSObject *object = [[itemClass alloc] init];
    NSObject<JSONProtocol> *objectConfProtocol = nil;
    
    if([object conformsToProtocol:@protocol(JSONProtocol)])
    {
        @try
        {
            objectConfProtocol = (NSObject<JSONProtocol>*)object;
            
            NSArray *properties = [objectConfProtocol JSONProperties];
            
            for (JSONProperty *p in properties) {
                
                BOOL handled = NO;
                
                if(self.deserializeOptionsBlock != nil)
                {
                    JSONLog(@"deserializeFromDictionary", @"inside deserializeOptionsBlock");
                    handled = self.deserializeOptionsBlock(p, dictIn, objectConfProtocol);
                }
                
                if(( handled == NO )&&([objectConfProtocol respondsToSelector:@selector(JSONDeserializeOptions:dictionary:error:)]))
                {
                    JSONLog(@"serializeToDictionary", @"inside JSONDeSerializeOptions method override");
                    handled = [objectConfProtocol JSONDeserializeOptions:p dictionary:dictIn error:error];
                }
                
                if(handled == NO)
                {
                    JSONLog(@"serializeToDictionary", @"inside default deserialization");
                    [p setObjectProperty:objectConfProtocol fromDictionary:dictIn withManager:self error:error];
                    handled = YES;
                }
                
            }
        }
        @catch(NSException *excp)
        {
            object = nil;
            
            NSDictionary *dictErr = @{
                                      NSLocalizedDescriptionKey: [excp reason],
                                      NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Error in deserializing property"],
                                      };
            
            *error = [NSError errorWithDomain:@"JSONLib"
                                         code:2
                                     userInfo:dictErr];
            
            
            LogErr(@"Exception: %@", dictErr);
            
        }
    }
    else
    {
        object = nil;
    }
    
    
    
    return objectConfProtocol;
}

- (NSArray*)deserializeFromArray:(NSArray*)arrIn itemClass:(Class)itemClass error:(NSError**)error
{
    NSMutableArray *arrOut = nil;
    
    *error = nil;
    
    // Check if all items of array conform to JSONProtocol
    for (id itemArray in arrIn) {
        if(*error == nil)
        {
            if( [itemArray isKindOfClass:[NSDictionary class]] )
            {
                NSObject<JSONProtocol> *objOut = [self deserializeFromDictionary:itemArray itemClass:itemClass error:error];
                if(*error == nil) [arrOut addObject:objOut];
            }
            else
            {
                arrOut = nil;
                
                NSDictionary *dictErr = @{
                                          NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Input data type wrong"],
                                          NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Item array type is not NSDictionary"],
                                          NSLocalizedRecoverySuggestionErrorKey: @"Check that input data type is NSDictionary"
                                          };
                
                *error = [NSError errorWithDomain:@"JSONLib"
                                             code:JSONLibErrorCodeInvalidInputData
                                         userInfo:dictErr];
            }
        }
    }
    
    return arrOut;
}


@end


#pragma mark -
#pragma mark JSONProperty
@implementation JSONProperty


+ (JSONProperty*)option:(NSString*)name type:(JSONPropertyType)type itemClass:(Class)itemClass
{
    JSONProperty *obj = [[JSONProperty alloc] init];
    obj.name = name;
    obj.type = type;
    obj.itemClass = itemClass;
    return obj;
}
+ (JSONProperty*)option:(NSString*)name type:(JSONPropertyType)type
{
    return [JSONProperty option:name type:type itemClass:nil];
}

- (void)setDictionaryEntry:(NSMutableDictionary*)dictionary fromObject:(NSObject<JSONProtocol>*)object withManager:(JSONManager*)jsonManager error:(NSError**)error
{
    id objValue = [object valueForKey:self.name];
    id dictValue = [NSNull null];
    
    if(objValue != nil)
    {
        switch(self.type)
        {
            case JSONPropertyTypeArray:
            {
                NSMutableArray *dictValueItems = [NSMutableArray array];
                
                NSArray *objValueItems = (NSArray*)objValue;
                for(NSObject<JSONProtocol> *objInner in objValueItems)
                {
                    NSError *error;
                    NSDictionary *tempValueItem = [jsonManager serializeToDictionary:objInner error:&error];
                    [dictValueItems addObject:tempValueItem];
                }
                
                dictValue = dictValueItems;
            }
                break;
            case JSONPropertyTypeArrayOfInteger:
            case JSONPropertyTypeArrayOfFloat:
            case JSONPropertyTypeArrayOfString:
            {
                objValue = (NSArray*)dictValue;
            }
                break;
            case JSONPropertyTypeObject:
            {
                NSError *error;
                dictValue = [jsonManager serializeToDictionary:objValue error:&error];
            }
                break;
            case JSONPropertyTypeDateTime:
            {
                dictValue = [JSONHelper fromDateTimeToStringUTC:objValue];
            }
                break;
            case JSONPropertyTypeBoolean:
            case JSONPropertyTypeEnum:
            case JSONPropertyTypeString:
            case JSONPropertyTypeFloat:
            case JSONPropertyTypeInteger:
            {
                dictValue = objValue;
            }
                break;
        }
        
    }
    
    [dictionary setObject:dictValue forKey:self.name];
    
}


- (void)setObjectProperty:(NSObject<JSONProtocol>*)object fromDictionary:(NSDictionary*)dictionary withManager:(JSONManager*)jsonManager error:(NSError**)error
{
    id dictValue = [dictionary objectForKey:self.name];
    id objValue = nil;
    
    if((dictValue!=nil)&&([dictValue isKindOfClass:[NSNull class]] == NO))
    {
        switch(self.type)
        {
            case JSONPropertyTypeArray:
            {
                NSMutableArray *objValueItems = [NSMutableArray array];
                
                NSArray *dictValueItems = (NSArray*)dictValue;
                for(NSDictionary *dictInner in dictValueItems)
                {
                    NSError *error;
                    NSObject<JSONProtocol> *tempValueItem = [jsonManager deserializeFromDictionary:dictInner itemClass:self.itemClass error:&error];
                    [objValueItems addObject:tempValueItem];
                }
                
                objValue = [NSArray arrayWithArray:objValueItems];
            }
                break;
            case JSONPropertyTypeArrayOfInteger:
            case JSONPropertyTypeArrayOfFloat:
            case JSONPropertyTypeArrayOfString:
            {
                objValue = (NSArray*)dictValue;
            }
                break;
            case JSONPropertyTypeObject:
            {
                NSError *error;
                objValue = [jsonManager deserializeFromDictionary:dictValue itemClass:self.itemClass error:&error];
            }
                break;
            case JSONPropertyTypeDateTime:
            {
                objValue = [JSONHelper fromStringUTCToDateTime:dictValue];
            }
                break;
            case JSONPropertyTypeBoolean:
            case JSONPropertyTypeString:
            case JSONPropertyTypeEnum:
            case JSONPropertyTypeFloat:
            case JSONPropertyTypeInteger:
            {
                objValue = (NSNumber*)dictValue;
            }
                break;
        }
        
    }
    else
    {
        switch(self.type)
        {
            case JSONPropertyTypeInteger:
            case JSONPropertyTypeFloat:
            {
                objValue = [NSNumber numberWithInteger:0];
            }
                break;
            case JSONPropertyTypeBoolean:
            {
                objValue = [NSNumber numberWithBool:NO];
            }
                break;
            case JSONPropertyTypeDateTime:
            case JSONPropertyTypeString:
            case JSONPropertyTypeArray:
            case JSONPropertyTypeObject:
            {
                objValue = nil;
            }
                break;
            default:
            {
                objValue = nil;
            }
                break;
        }
    }
    
    [object setValue:objValue forKey:self.name];
}


@end


#pragma mark -
#pragma mark JSONHelper
@implementation JSONHelper

+ (NSString*)fromDateTimeToStringUTC:(NSDate*)dateIn
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *stringFromDate = [formatter stringFromDate:dateIn];
    
    return stringFromDate;
}

+ (NSDate*)fromStringUTCToDateTime:(NSString*)strIn
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [formatter dateFromString:strIn];
    
    return date;
}

+ (NSDate*)fromSoapTimestampWithTimezoneToDateTime:(NSString*)strSoap
{
    NSDate *dateOut = nil;
    
    NSString *regExPattern = @"\\/Date\\(([0-9]*)([+-])([0-9]{2})([0-9]{2})\\)\\/";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regEx matchesInString:strSoap options:0 range:NSMakeRange(0, [strSoap length])];
    
    NSInteger timestamp = 0;
    NSString *segno = nil;
    NSInteger segnoMoltiplicatore = 1;
    NSInteger tzOre = 0;
    NSInteger tzMinuti = 0;
    
    for (NSTextCheckingResult *match in matches) {
        //NSRange matchRange = [match range];
        for(int k=1;k<match.numberOfRanges;k++)
        {
            NSRange matchRange = [match rangeAtIndex:k];
            NSString *matchString = [strSoap substringWithRange:matchRange];
            
            if(k == 1) timestamp = [matchString integerValue]/1000;
            if(k == 2)
            {
                segno = matchString;
                if([segno isEqualToString:@"+"])
                {
                    segnoMoltiplicatore = 1;
                }
                else if([segno isEqualToString:@"-"])
                {
                    segnoMoltiplicatore = -1;
                }
            }
            if(k == 3) tzOre = [matchString integerValue];
            if(k == 4) tzMinuti = [matchString integerValue];
        }
        
        /*
         NSDate * d = [NSDate dateWithTimeIntervalSince1970:timestamp];
         NSInteger timestampWithTimezone = timestamp+(tzOre*3600+tzMinuti*60)*segnoMoltiplicatore;
         dateOut = [NSDate dateWithTimeIntervalSince1970:timestampWithTimezone];
         */
        dateOut = [NSDate dateWithTimeIntervalSince1970:timestamp];
    }
    
    return dateOut;
}

@end




#pragma mark -
#pragma mark JSONLib
@implementation JSONLib

/// default manager
+ (JSONManager*)defaultManager
{
    JSONManager *obj = [[JSONManager alloc] init];
    return obj;
}


@end


