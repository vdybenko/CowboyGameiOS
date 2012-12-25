//
//  MyTest.m
//  MyTestable
//
//  Created by Gabriel Handford on 7/16/11.
//  Copyright 2011 rel.me. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h> 
#import "AccountDataSource.h"
#import "LoadViewController.h"
#import "StartViewController.h"

@interface MyTest : GHTestCase { }
@end

@implementation MyTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES.
    // Also an async test that calls back on the main thread, you'll probably want to return YES.
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}

- (void)testAccountDataSource {
    AccountDataSource *accountDataSource = [AccountDataSource sharedInstance];
    [accountDataSource loadAllParametrs];
    GHTestLog(@"I can log to the GHUnit test console: %@", accountDataSource);

    // Assert string1 is not NULL, with no custom error description
    GHAssertNotNULL((__bridge void *) accountDataSource, nil);
  
//  // Assert equal objects, add custom error description
//  NSString *string2 = @"a string";
//  GHAssertEqualObjects(string1, string2, @"A custom error message. string1 should be equal to: %@.", string2);
}

- (void)testLogic {
    LoadViewController *loadViewController = [[LoadViewController alloc] initWithPush:NULL];
    GHAssertNotNil(loadViewController, @"Cannot find the loadViewController");
    StartViewController *startViewController = [StartViewController sharedInstance];
    GHAssertNotNil(startViewController, @"Cannot find the startViewController");
}



@end