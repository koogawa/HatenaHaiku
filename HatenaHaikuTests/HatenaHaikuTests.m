//
//  HatenaHaikuTests.m
//  HatenaHaikuTests
//
//  Created by koogawa on 2016/01/30.
//  Copyright © 2016年 Kosuke Ogawa. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AuthManager.h"

@interface HatenaHaikuTests : XCTestCase

@end

@implementation HatenaHaikuTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    if ([[AuthManager sharedManager] isAuthenticated])
    {
        XCTAssertNotNil([[AuthManager sharedManager] accessToken], @"accessToken is nil");
        XCTAssertNotNil([[AuthManager sharedManager] accessTokenSecret], @"accessTokenSecret is nil");
        XCTAssertNotNil([[AuthManager sharedManager] urlName], @"urlName is nil");
        XCTAssertNotNil([[AuthManager sharedManager] displayName], @"displayName is nil");
    }
}

- (void)testPerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
