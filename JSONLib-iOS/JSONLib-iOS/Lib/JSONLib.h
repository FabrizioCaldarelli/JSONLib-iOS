//
//  JSONLib.h
//  JSONLib-iOS
//
//  Created by Fabrizio on 10/04/16.
//  Copyright © 2016 Fabrizio Caldarelli. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef Logger_h
    #ifdef DEBUG
        #define LogInfo(category, fmt, ...) NSLog((@"[%@] " fmt), category, ##__VA_ARGS__);
        #define LogErr(fmt, ...) NSLog((@"[ERR] %s[Ln %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
    #else
        #define LogInfo(category, fmt, ...)
        #define LogErr(fmt, ...)
    #endif
#endif

#ifdef JSONLIB_DEBUG
    #define JSONLog NSLog((@"[JsonLog][%@] " fmt), category, ##__VA_ARGS__);
#else
    #define JSONLog(category, fmt, ...)

#endif

typedef enum
{
    JSONLibErrorCodeInvalidInputData
} JSONLibErrorCode;


// -------------------------------------------
/**
 JSONProtocol
 */
@class JSONProperty;
@protocol JSONProtocol <NSObject>

@required

// Array of JSONProperty
- (NSArray*)JSONProperties;

@optional

/// YES if property has been handled
- (BOOL)JSONSerializeOptions:(JSONProperty*)property dictionary:(NSMutableDictionary*)dictOut error:(NSError**)error;

/// YES if property has been handled
- (BOOL)JSONDeserializeOptions:(JSONProperty*)property dictionary:(NSDictionary*)dictIn error:(NSError**)error;


@end


// -------------------------------------------
/**
 JSONManager
 */
@interface JSONManager : NSObject

/// YES if property has been handled
@property (nonatomic, copy) BOOL (^serializeOptionsBlock)(JSONProperty* property, NSObject<JSONProtocol> *objIn, NSMutableDictionary *dictOut);
/// YES if property has been handled
@property (nonatomic, copy) BOOL (^deserializeOptionsBlock)(JSONProperty* property, NSDictionary *dictIn, NSObject<JSONProtocol> *objOut);

- (NSDictionary*)serializeToDictionary:(NSObject<JSONProtocol>*)data error:(NSError**)error;
- (NSArray*)serializeToArray:(NSArray*)data error:(NSError**)error;
- (id<JSONProtocol>)deserializeFromDictionary:(NSDictionary*)dictIn itemClass:(Class)itemClass error:(NSError**)error;
- (NSArray*)deserializeFromArray:(NSArray*)arrIn itemClass:(Class)itemClass error:(NSError**)error;


@end


// -------------------------------------------
/**
 JSONProperty
 */
@interface JSONProperty : NSObject

typedef enum
{
    JSONPropertyTypeBoolean,
    JSONPropertyTypeInteger,
    JSONPropertyTypeFloat,
    JSONPropertyTypeString,
    JSONPropertyTypeDateTime,
    JSONPropertyTypeEnum,
    JSONPropertyTypeObject,
    JSONPropertyTypeArray,
    JSONPropertyTypeArrayOfInteger,
    JSONPropertyTypeArrayOfFloat,
    JSONPropertyTypeArrayOfString,
}JSONPropertyType;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) JSONPropertyType type;
@property (nonatomic, assign) Class itemClass;

+ (JSONProperty*)option:(NSString*)name type:(JSONPropertyType)type;
+ (JSONProperty*)option:(NSString*)name type:(JSONPropertyType)type itemClass:(Class)itemClass;

- (void)setDictionaryEntry:(NSMutableDictionary*)dictionary fromObject:(NSObject<JSONProtocol>*)object withManager:(JSONManager*)jsonManager error:(NSError**)error;
- (void)setObjectProperty:(NSObject<JSONProtocol>*)object fromDictionary:(NSDictionary*)dictionary withManager:(JSONManager*)jsonManager error:(NSError**)error;

@end

/**
 * JSONHelper
 */
@interface JSONHelper : NSObject

+ (NSString*)fromDateTimeToStringUTC:(NSDate*)dateIn;
+ (NSDate*)fromStringUTCToDateTime:(NSString*)strIn;
+ (NSDate*)fromSoapTimestampWithTimezoneToDateTime:(NSString*)strSoap;

@end


// -------------------------------------------
/**
 JSONLib
 
 Contains only default constructor for JSONManager
 
 */
@interface JSONLib : NSObject


/**
 It returns default constructor of JSONManager
 @return JSONManager
*/
+ (JSONManager*)defaultManager;

@end




