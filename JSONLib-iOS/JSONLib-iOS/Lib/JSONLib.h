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

/**
 Serialize a NSObject<JSONProtocol> object to NSDictionary (NSString, NSString)
 @param NSObject<JSONProtocol>*
 @return NSDictionary key=NSString, value=NSString
*/
- (NSDictionary*)serializeToDictionary:(NSObject<JSONProtocol>*)data error:(NSError**)error;
/**
 Serialize an array of NSObject<JSONProtocol> object to NSArray of NSDictionary (NSString, NSString)
 @param NSArray array of NSObject<JSONProtocol>*
 @return NSArray array of NSDictionary key=NSString, value=NSString
 */
- (NSArray*)serializeToArray:(NSArray*)data error:(NSError**)error;
/**
 Deserialize a NSDictionary (NSString, NSString) into a NSObject<JSONProtocol> object to
 @param NSDictionary key=NSString, value=NSString
 @return NSObject<JSONProtocol>*
 */
- (id<JSONProtocol>)deserializeFromDictionary:(NSDictionary*)dictIn itemClass:(Class)itemClass error:(NSError**)error;
/**
 Deserialize an NSArray of NSDictionary (NSString, NSString) into an array of NSObject<JSONProtocol> object
 @param NSArray array of NSDictionary key=NSString, value=NSString
 @return NSArray array of NSObject<JSONProtocol>*
 */
- (NSArray*)deserializeFromArray:(NSArray*)arrIn itemClass:(Class)itemClass error:(NSError**)error;
/**
 Deserialize a JSON string into a NSObject<JSONProtocol> object
 @param NSString JSON string
 @return NSObject<JSONProtocol>*
 */
- (id<JSONProtocol>)deserializeStringObject:(NSString*)strJson itemClass:(Class)itemClass error:(NSError**)error;
/**
 Deserialize a JSON string into a NSArray of NSObject<JSONProtocol> objects
 @param NSString JSON string
 @return NSArray array of NSObject<JSONProtocol>*
 */
- (NSArray*)deserializeStringArray:(NSString*)strJson itemClass:(Class)itemClass error:(NSError**)error;
/**
 Serialize a NSObject<JSONProtocol> or NSArray (array of NSObject<JSONProtocol> objects) into a NSString (JSON string)
 @param id NSObject<JSONProtocol> or NSArray (array of NSObject<JSONProtocol> objects)
 @return NSString JSON string
 */
- (NSString*)serializeToString:(id)data error:(NSError**)error;

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

typedef enum {
    JSONHelperDateTypeNotFound,
    JSONHelperDateTypeSoapTimestampWithTimezone
} JSONHelperDateType;

+ (NSString*)fromDateTimeToStringUTC:(NSDate*)dateIn;
+ (NSDate*)fromStringUTCToDateTime:(NSString*)strIn;
+ (NSDate*)fromStringSoapTimestampWithTimezoneToDateTime:(NSString*)strSoap;

+ (NSDate*)convertStringToDateUsingAutodetection:(NSString*)strInput;

/**
  List of all date type formats
 
  Key is JSONHelperDateType
 
  Value is NSString pattern of regular expression
*/
+ (NSDictionary*)dateTypesSupported;
+ (JSONHelperDateType) detectDateTypeMatch:(NSString*)strInput;

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




