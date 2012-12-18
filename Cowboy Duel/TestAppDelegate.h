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
#import "AccountDataSource.h"
#import "GANTracker.h"


@interface TestAppDelegate :  UIResponder <UIApplicationDelegate, GANTrackerDelegate>
@property (nonatomic, readonly) UINavigationController *navigationController;
@property  (strong) LoginAnimatedViewController *loginViewController;
@property (nonatomic) GADBannerView *adBanner;
@property (strong, nonatomic) IBOutlet UIImageView *clouds;

// FBSample logic
// The app delegate is responsible for maintaining the current FBSession. The application requires
// the user to be logged in to Facebook in order to do anything interesting -- if there is no valid
// FBSession, a login screen is displayed.
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code;


@end
