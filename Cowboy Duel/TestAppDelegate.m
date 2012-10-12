//
//  TestAppDelegate.m
//  Test
//
//  Created by Sobol on 10.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TestAppDelegate.h"
#import "GCHelper.h"
#import <GameKit/GameKit.h>

#if !(TARGET_IPHONE_SIMULATOR)
#import "GANTracker.h"
#import "Crittercism.h"
#import "StartViewController.h"

static const NSInteger kGANDispatchPeriod = 60;
static NSString *kGAAccountID = @"UA-33080242-1";
NSString  *const ID_CRIT_APP   = @"4fb4f482c471a10fc5000092";
NSString  *const ID_CRIT_KEY   = @"stjyktz620mziyf5rhi89ncaorab";
NSString  *const ID_CRIT_SECRET   = @"w30r26yvspyi1xtgrdcqgexpzsazqlkl";

#endif

static NSString *const NewMessageReceivedNotification = @"NewMessageReceivedNotification";
@interface TestAppDelegate()
{
    UIWindow *window;
    UINavigationController *navigationController;
    StartViewController *startViewController;
    LoginViewController *loginViewController;
    Facebook * facebook;
    AccountDataSource *playerAccount;
}

@end

@implementation TestAppDelegate

@synthesize navigationController, loginViewController;
@synthesize facebook;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
       
        
    [AdColony initAdColonyWithDelegate:self];
    
#if !(TARGET_IPHONE_SIMULATOR)	
    [Crittercism initWithAppID:ID_CRIT_APP  andKey:ID_CRIT_KEY andSecret:ID_CRIT_SECRET];
    
    [FlurryAnalytics startSession:@"E2C6ED272AGCEHPRMESX"];
    
    [[GANTracker sharedTracker] startTrackerWithAccountID:kGAAccountID
                                           dispatchPeriod:kGANDispatchPeriod
                                                 delegate:nil];	
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(AnalyticsTrackEvent:)
												 name:kAnalyticsTrackEventNotification object:nil];
    
   

#endif	
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    application.statusBarOrientation = UIInterfaceOrientationPortrait;
  
    
    LoadViewController *loadViewController;
    
    loadViewController= [[LoadViewController alloc] initWithPush:NULL];
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:loadViewController];

    [navigationController setNavigationBarHidden:YES];
    
    CGRect frame = [[UIScreen mainScreen]bounds];
    
    window = [[UIWindow alloc]initWithFrame:frame];
    [window setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"st_bg_new.png"]]];
    
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    
    //!!!!!!!!!!!!!!//
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ((![defaults objectForKey:@"countOfDuels"])||([defaults objectForKey:@"countOfDuels"]==NULL))           
    {
        [defaults setInteger:0 forKey:@"countOfDuels"];
        [defaults synchronize];
    }
    
    if ((![defaults objectForKey:@"movieWatched"])||([defaults objectForKey:@"movieWatched"]==NULL)) 
    {
        [defaults setInteger:0 forKey:@"movieWatched"];
        [defaults synchronize];
    }
    
    DLog(@"FBAccessTokenKey %@", [defaults objectForKey:@"FBAccessTokenKey"]);
    
       
    //Sleep off
    application.idleTimerDisabled = YES;
    application.applicationIconBadgeNumber = 0;
    return YES;
    
}

//use the app id provided by adcolony.com
-(NSString*)adColonyApplicationID {
	return @"app5f45da50def349ce844dff";
}

-(NSDictionary*)adColonyAdZoneNumberAssociation {
    return [NSDictionary dictionaryWithObjectsAndKeys:
			@"vz74e7d81b72fb4f198a5bba", [NSNumber numberWithInt:1],
            @"vz2c493f6fa7cc474687a5ed", [NSNumber numberWithInt:2],
			nil];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    DLog(@"application handleOpenURL");
    if (loginViewController) return [loginViewController.facebook handleOpenURL:url];
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    if(!([currentDevice respondsToSelector:@selector(isMultitaskingSupported)] && [currentDevice isMultitaskingSupported]))
    {
        [[StartViewController sharedInstance] didEnterBackground];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    UIDevice *currentDevice = [UIDevice currentDevice];

    if(!([currentDevice respondsToSelector:@selector(isMultitaskingSupported)] && [currentDevice isMultitaskingSupported]))
    {
        [[StartViewController sharedInstance] didBecomeActive];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DLog(@"applicationWillTerminate");
    
}

#if !(TARGET_IPHONE_SIMULATOR)

- (void)AnalyticsTrackEvent:(NSNotification *)notification {
    
    NSError	*err;
	NSString *fbUserId;
    fbUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"id"];
    
    if ([fbUserId length] == 0)
        fbUserId = @"Anonymous"; 
    
    if(![fbUserId isEqualToString:@"NoGC"]){
        [FlurryAnalytics setUserID:fbUserId];
    }
    
    
	NSString *page = [[notification userInfo] objectForKey:@"event"];
	DLog(@"GA page %@",page);
	if (page){
		if (![[GANTracker sharedTracker] trackPageview:page withError:&err])
			DLog(@" Can't track pageview");
	}    
	[[GANTracker sharedTracker] dispatch];
    
}
#endif

- (void)dealloc
{
    DLog(@"Exit");
}

@end
