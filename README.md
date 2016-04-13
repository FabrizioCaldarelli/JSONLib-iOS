# JSONLib-iOS
JSON Library for iOS

How it works
============

- From JSONLib, we create a JSONManager instance;
- From JSONManager, we can launch these methods:
  - serializeToDictionary, to serialize from a NSObject<JSONProtocol>
  - serializeToArray, to serialize from an array with NSObject<JSONProtocol> items;
  - deserializeFromDictionary, to deserialize to NSObject<JSONProtocol>;
  - deserializeFromArray, to deserialize to an array with NSObject<JSONProtocol> items;
- Finish!
  
JSONProtocol definition
=======================
The JSONProtocol has 1 required method and 2 optionals methods:

- Required method: JSONProperties. This methods lists all properties inside the model. There are many types of Property.

        @interface SimpleModel : NSObject<JSONProtocol>
        
        @property (nonatomic, strong) NSString *name;
        @property (nonatomic, strong) NSString *surname;
        @property (nonatomic, assign) int age;
        
        @end

        @implementation SimpleModel
        
        - (NSArray*)JSONProperties
        {
            return @[
                     [JSONProperty property:@"name" type:JSONPropertyTypeString],
                     [JSONProperty property:@"surname" type:JSONPropertyTypeString],
                     [JSONProperty property:@"age" type:JSONPropertyTypeInteger]
                     ];
        }
        @end
- Optional methods: JSONSerializeOptions and JSONDeserializeOptions. These methods allow to override default behaviour of JSON parser and builder. Both return a BOOL to indicate if they have handled or not the property.

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
        
Parsing and building JSON
=========================      
There are three step when we parse or build a JSON repeated for each property we have defined in the required JSONProperties method of the JSONProtocol, in the model:

1. Firstly, the property is passed to a serializeOptionsBlock or deserializeOptionsBLock, defined into the JSONManager, where we can define how set dictionary or object property value. If they are not defined, this step is simply skipped. These blocks return a BOOL to indicate if they have handled or not the property. 
2. If previous step returns NO, the property is passed to JSONSerializeOptions or JSONDeserializeOptions, where we can define how set dictionary or object property value. if they are defined in the model. If they are not defined, this step is simply skipped.
3. If previous step returns NO, the property is passed to default parser or builder of the library;

        
Example 1. Basic serializing
============================

Now we create an instance of SimpleModel class and serialize it in a NSDictionary.

    // Create an instance of JSONManager
    JSONManager *jsonManager = [JSONLib defaultManager];
    
    // Create an instance of SimpleModel class
    SimpleModel *simpleModel_1 = [SimpleModel new];
    simpleModel_1.name = @"Albert";
    simpleModel_1.surname = @"Einstein";
    simpleModel_1.age = 76;
    
    // Serialize SimpleModel class in NSDictionary
    NSDictionary *dictSimpleModel_1 = [self serializeSimpleModel:simpleModel_1 error:&error];
    
    return objOut;
    
Example 2. Serializing with options in JSONManager
==================================================

Now we create an instance of SimpleModel class and serialize it in a NSDictionary, specifying a different behaviour for birthday property.

    // Create an instance of JSONManager
    JSONManager *jsonManager = [JSONLib defaultManager];
    
    // We define serializeOptionsBlock to specify different behaviour for birthday property
    [jsonManager setSerializeOptionsBlock:^BOOL(JSONProperty *p, NSObject<JSONProtocol> *objIn, NSMutableDictionary *dictOut) {
        
        if([p.name isEqualToString:@"birthday"])
        {
            User *model = (User*)objIn;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            
            NSString *stringFromDate = [formatter stringFromDate:model.birthday];
            
            [dictOut setObject:stringFromDate forKey:p.name];
            
            return YES;
        }
        
        return NO;
    }];
    NSDictionary *dictOut = [jsonManager serializeToDictionary:user error:error];


Example 3. How handle enum property
===================================

To parse and build enum property value, we can define JSONSerializeOptions and JSONDeserializeOptions inside the model, such as:

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
    
Other examples
==============

Other examples are in Unit Tests inside the project
