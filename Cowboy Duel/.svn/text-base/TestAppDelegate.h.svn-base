//
//  TestAppDelegate.h
//  Test
//
//  Created by Sobol on 10.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DuelViewController.h"
//#import "BluetoothViewController.h"
//#import "StartViewController.h"
#import "TableViewController.h"
#import "LoadViewController.h"
#import "LoginViewController.h"
#import "AdColonyPublic.h"
#import "FBConnect.h"
#import "AccountDataSource.h"



@interface TestAppDelegate : NSObject <UIApplicationDelegate, AdColonyDelegate, FBRequestDelegate, FBDialogDelegate, FBSessionDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    NSString *flurryEvent;
    StartViewController *startViewController;
    LoginViewController *loginViewController;
    Facebook * facebook;
    AccountDataSource *playerAccount;
    
}
@property (nonatomic, readonly) UINavigationController *navigationController;
@property  (strong) LoginViewController *loginViewController;
@property (strong,nonatomic) Facebook *facebook;




@end
