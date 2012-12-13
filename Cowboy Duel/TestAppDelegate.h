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

@interface TestAppDelegate : NSObject <UIApplicationDelegate,   GANTrackerDelegate>
@property (nonatomic, readonly) UINavigationController *navigationController;
@property  (strong) LoginAnimatedViewController *loginViewController;
@property (nonatomic) GADBannerView *adBanner;
@property (strong, nonatomic) IBOutlet UIImageView *clouds;

@end
