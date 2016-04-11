//
//  JSONLib_iOSTests.m
//  JSONLib-iOSTests
//
//  Created by Fabrizio on 10/04/16.
//  Copyright © 2016 Fabrizio Caldarelli. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SimpleModel.h"
#import "User.h"

@interface JSONLib_iOSTests : XCTestCase

@end

@implementation JSONLib_iOSTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDeserializeArrayFromString
{
    NSError *error;
    
    NSString *str = @"[{\"name\":\"Albert\", \"surname\":\"Einstein\", \"age\":37}]";
    
    JSONManager *jsonManager = [JSONLib defaultManager];
    NSArray *arr = [jsonManager deserializeStringArray:str itemClass:[SimpleModel class] error:&error];
    
    NSString *strOut = [jsonManager serializeToString:arr error:&error];
    
    XCTAssertNotNil(arr);
}

- (void)testDeserializeObjectFromString
{
    NSError *error;
    
    NSString *str = @"{\"name\":\"Albert\", \"surname\":\"Einstein\", \"age\":37}";

    JSONManager *jsonManager = [JSONLib defaultManager];
    SimpleModel *model = [jsonManager deserializeStringObject:str itemClass:[SimpleModel class] error:&error];
    
    XCTAssertNotNil(model);
}

- (void)testHelperDateFormat
{
    // Create a regular expression
    NSString *testo = @"/Date(1459850382733-1324)/";

    JSONHelperDateType dtype = [JSONHelper detectDateTypeMatch:testo];
    
    NSDate *dt = [JSONHelper convertStringToDateUsingAutodetection:testo];
    
    XCTAssertNotNil(dt);
}

- (NSDictionary*)serializeSimpleModel:(SimpleModel *)simpleModel error:(NSError**)error
{
    JSONManager *jsonManager = [JSONLib defaultManager];
    [jsonManager setSerializeOptionsBlock:^BOOL(JSONProperty *p, NSObject<JSONProtocol> *objIn, NSMutableDictionary *dictOut) {
        LogInfo(@"setSerializeOptionsBlock", @"[%@][%@]", [objIn class], p.name);
        return NO;
    }];
    NSDictionary *dictOut = [jsonManager serializeToDictionary:simpleModel error:error];

    return dictOut;
}

-(SimpleModel*)deserializeSimpleModel:(NSDictionary*)dictIn error:(NSError**)error
{
    JSONManager *jsonManager = [JSONLib defaultManager];
    [jsonManager setDeserializeOptionsBlock:^BOOL(JSONProperty *p, NSDictionary *dictIn , NSObject<JSONProtocol> *objOut) {
        LogInfo(@"setDeserializeOptionsBlock", @"[%@][%@]", [objOut class], p.name);
        return NO;
    }];
    SimpleModel *objOut = [jsonManager deserializeFromDictionary:dictIn itemClass:[SimpleModel class] error:error];
    
    return objOut;
    
}

- (void)testSerializeSimpleModel
{
    NSError *error;
    
    SimpleModel *simpleModel_1 = [SimpleModel new];
    simpleModel_1.name = @"Albert";
    simpleModel_1.surname = @"Einstein";
    simpleModel_1.age = 76;
    
    NSDictionary *dictSimpleModel_1 = [self serializeSimpleModel:simpleModel_1 error:&error];
    
    SimpleModel *simpleModel_2 = [self deserializeSimpleModel:dictSimpleModel_1 error:&error];
    
    XCTAssertTrue( (dictSimpleModel_1!=nil)&&(error==nil) );
    
}


- (NSDictionary*)serializeUser:(User *)user error:(NSError**)error
{
    JSONManager *jsonManager = [JSONLib defaultManager];
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
    
    return dictOut;
}


-(User*)deserializeUser:(NSDictionary*)dictIn error:(NSError**)error
{
    JSONManager *jsonManager = [JSONLib defaultManager];
    [jsonManager setDeserializeOptionsBlock:^BOOL(JSONProperty *p, NSDictionary *dictIn , NSObject<JSONProtocol> *objOut) {
        if([p.name isEqualToString:@"birthday"])
        {
            User *model = (User*)objOut;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            
            model.birthday = [formatter dateFromString:[dictIn objectForKey:@"birthday"]];
            
            return YES;
        }
        
        return NO;
    }];
    User *objOut = [jsonManager deserializeFromDictionary:dictIn itemClass:[User class] error:error];
    
    return objOut;
    
}

- (void)testSerializeUser
{
    NSError *error;
    
    User *user_1 = [User new];
    user_1.name = @"Albert";
    
    SimpleModel *simpleModel_1 = [SimpleModel new];
    simpleModel_1.name = @"Albert";
    simpleModel_1.surname = @"Einstein";
    simpleModel_1.age = 76;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [NSDateComponents new];
    [components setDay:14];
    [components setMonth:3];
    [components setYear:1879];
    user_1.birthday = [calendar dateFromComponents:components];
    user_1.age = 76;
    user_1.gender = UserGenderMale;
    user_1.childNames = @[ @"Hans Albert", @"Eduard" ];
    user_1.simpleModels = @[ simpleModel_1 ];
    
    NSDictionary *dictUser_1 = [self serializeUser:user_1 error:&error];
    
    User *user_2 = [self deserializeUser:dictUser_1 error:&error];
    
    XCTAssertTrue( (dictUser_1!=nil)&&(error==nil) );
    
}

/*
- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/

@end
