//
//  MyViewTest.m
//  MyTestable
//
//  Created by John Boiles on 10/26/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h> 
#import "LoadViewController.h"
#import "LoginAnimatedViewController.h"
#import "StartViewController.h"
#import "ListOfItemsViewController.h"
#import "MoneyCongratViewController.h"

@interface MyViewTest : GHViewTestCase {
    AccountDataSource *accountDataSource;
}
@end

@implementation MyViewTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES.
    // Also an async test that calls back on the main thread, you'll probably want to return YES.
    return YES;
}

- (void)setUpClass {
    // Run at start of all tests in the class
    accountDataSource = [AccountDataSource sharedInstance];
    [accountDataSource loadAllParametrs];
}

- (void)testLoadViewController {
    LoadViewController *viewController = [[LoadViewController alloc] initWithPush:NULL];
    GHVerifyView(viewController.view);
}

- (void)testLoginAnimatedViewController {
    LoginAnimatedViewController *viewController = [LoginAnimatedViewController sharedInstance];
    GHVerifyView(viewController.view);
}

- (void)testStartViewController {
    StartViewController *viewController = [StartViewController sharedInstance];
    GHVerifyView(viewController.view);
}

- (void)testListOfItemsViewController{
    ListOfItemsViewController *viewController = [[ListOfItemsViewController alloc] init];
    GHVerifyView(viewController.view);
}

- (void)testMoneyCongratViewController{
    MoneyCongratViewController *viewController = [[MoneyCongratViewController alloc] initForAchivmentPlayerAccount:accountDataSource withLabel:@"test" andController:nil tryButtonEnable:YES];
    GHVerifyView(viewController.view);
}




@end
