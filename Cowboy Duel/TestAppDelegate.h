//
//  TestAppDelegate.h
//  Test
//
//  Created by Sobol on 10.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DuelViewController.h"
#import "LoadViewController.h"
#import "LoginViewController.h"
#import "AdColonyPublic.h"
#import "FBConnect.h"
#import "AccountDataSource.h"

@interface TestAppDelegate : NSObject <UIApplicationDelegate, AdColonyDelegate, FBRequestDelegate, FBDialogDelegate, FBSessionDelegate>
@property (nonatomic, readonly) UINavigationController *navigationController;
@property  (strong) LoginViewController *loginViewController;
@property (strong,nonatomic) Facebook *facebook;
@property (nonatomic) GADBannerView *adBanner;

@end
