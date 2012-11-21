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
#import "LoginAnimatedViewController.h"
#import "AdColonyPublic.h"
#import "FBConnect.h"
#import "AccountDataSource.h"
#import "GANTracker.h"

@interface TestAppDelegate : NSObject <UIApplicationDelegate, AdColonyDelegate, FBRequestDelegate, FBDialogDelegate, FBSessionDelegate, GANTrackerDelegate>
@property (nonatomic, readonly) UINavigationController *navigationController;
@property  (strong) LoginAnimatedViewController *loginViewController;
@property (strong,nonatomic) Facebook *facebook;
@property (nonatomic) GADBannerView *adBanner;

@end
