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
#import "LoginAnimatedViewController.h"

#import "Crittercism.h"
#import "StartViewController.h"

#define kFacebookSettingsButtonIndex 1

static const NSInteger kGANDispatchPeriod = 60;
#ifdef DEBUG
static NSString *kGAAccountID = @"UA-24007807-3";
#else
static NSString *kGAAccountID = @"UA-24007807-6";
#endif
NSString  *const ID_CRIT_APP   = @"4fb4f482c471a10fc5000092";
NSString  *const ID_CRIT_KEY   = @"stjyktz620mziyf5rhi89ncaorab";
NSString  *const ID_CRIT_SECRET   = @"w30r26yvspyi1xtgrdcqgexpzsazqlkl";


@interface TestAppDelegate()
{
    UIWindow *window;
    UINavigationController *navigationController;
    StartViewController *startViewController;
    LoginAnimatedViewController *loginViewController;
    
    AccountDataSource *playerAccount;
}
@property (nonatomic, strong) id<FBGraphUser> facebookUser;

@end

@implementation TestAppDelegate

@synthesize navigationController, loginViewController;
@synthesize facebookUser, adBanner;
@synthesize clouds;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIImage initialize];
        
   // [AdColony initAdColonyWithDelegate:self];
    [[GANTracker sharedTracker] startTrackerWithAccountID:kGAAccountID
                                           dispatchPeriod:kGANDispatchPeriod delegate:self];
	
    [Crittercism initWithAppID:ID_CRIT_APP  andKey:ID_CRIT_KEY andSecret:ID_CRIT_SECRET];
/*
  [[GAI sharedInstance] trackerWithTrackingId:kGAAccountID];
  

//    [[GAI sharedInstance] startTrackerWithAccountID:kGAAccountID
//                                           dispatchPeriod:kGANDispatchPeriod
//                                                 delegate:nil];	
  */  
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(AnalyticsTrackEvent:)
												 name:kAnalyticsTrackEventNotification object:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    application.statusBarOrientation = UIInterfaceOrientationPortrait;
  
    loginViewController = [[LoginAnimatedViewController alloc] init];
    navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    LoadViewController *loadViewController;
    
    loadViewController= [[LoadViewController alloc] initWithPush:NULL];
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:loadViewController];

    [navigationController setNavigationBarHidden:YES];
    
    CGRect frame = [[UIScreen mainScreen]bounds];
    window = [[UIWindow alloc]initWithFrame:frame];
    
    UIImageView *background = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"dv_img_eath_new.png"]];
    frame = background.frame;
    frame.origin = CGPointMake(-150, -70);
    background.frame = frame;
    [window addSubview:background];
    
    clouds = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"st_cloud_new.png"]];
    frame = clouds.frame;
    frame.origin = CGPointMake(-20, -68);
    clouds.frame = frame;
    [window addSubview:clouds];
    
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
    
    
    if (frame.size.height > 480) {
        // Initialize the banner at the bottom of the screen.
        CGPoint origin = CGPointMake(0.0, frame.size.height - 50);
        
        // Use predefined GADAdSize constants to define the GADBannerView.
        self.adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait
                                                       origin:origin];
        
        // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID
        // before compiling.
        self.adBanner.adUnitID = kSampleAdUnitID;
        self.adBanner.delegate = self;
        [self.adBanner setRootViewController:navigationController];
        [window addSubview:self.adBanner];
        [self.adBanner loadRequest:[self createRequest]];
        [self.adBanner setHidden:YES];
    }
    
    if([[OGHelper sharedInstance] isAuthorized]){
        [self openSessionWithAllowLoginUI:YES];
    }
    
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
//			@"vz2c493f6fa7cc474687a5ed", [NSNumber numberWithInt:1],
            @"vz74e7d81b72fb4f198a5bba", [NSNumber numberWithInt:1],//test
			nil];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    DLog(@"application handleOpenURL");
    if (loginViewController) return [[FBSession activeSession] handleOpenURL:url];

    return NO;
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    
    NSArray *permissions =
    [NSArray arrayWithObjects:@"email", nil];
    float ver_float = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver_float >= 6.0) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        if (![accountStore accountsWithAccountType:accountType]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", @"AlertView")
                                                                message:NSLocalizedString(@"You can't connnect to Facebook right now, make sure  your device has an internet connection and you have at least one Facebook account setup", @"AlertView")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"AlertView")
                                                      otherButtonTitles: nil];
            [alertView show];
            return NO;

        }
    }
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
//    if( [FBSession openActiveSessionWithAllowLoginUI:NO])
//        [self sessionStateChanged:[FBSession activeSession] state:[FBSession activeSession].state error:nil];
////    else [self sessionStateChanged:[FBSession activeSession] state:[FBSession activeSession].state error:nil];
//    return YES;
//    if ([[FBSession activeSession] isOpen]) {
//        //do something
//        [[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification
//                                                            object:[FBSession activeSession]];
//    }
//    else {
//        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//            [self sessionStateChanged:session state:status error:error];
//            if(FB_ISSESSIONOPENWITHSTATE(status)) {
//                //do something
//                
//                [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                    if (!error){
//                        
//                        NSLog(@"success on first try");
//                    } else if ([[error userInfo][FBErrorParsedJSONResponseKey][@"body"][@"error"][@"code"] compare:@190] == NSOrderedSame) {
//                        //requestForMe failed due to error validating access token (code 190), so retry login
//                        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//                            if (!error){
//                                //do something again, or consider recursive call with a max retry count.
//                                [self sessionStateChanged:session state:status error:error];
//                                NSLog(@"success on retry");
//                                
//                            }
//                        }];
//                    }
//                }];
//            }
//        }];
//    }
    
//    if ([FBSession openActiveSessionWithReadPermissions:permissions
//                                           allowLoginUI:NO
//                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//                                          [self sessionStateChanged:session state:state error:error];
//                                      }]) {
//                                          return YES;
//    }
//    else{
////        FBSession *session = [FBSession activeSession];
////        [session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
////            [self sessionStateChanged:session state:status error:error];
////        }];
//        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", @"AlertView")
//                                                            message:NSLocalizedString(@"You can't connnect to Facebook right now, make sure  your device has an internet connection and you have at least one Facebook account setup", @"AlertView")
//                                                           delegate:self
//                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"AlertView")
//                                                  otherButtonTitles: nil];
//        [alertView show];
//        return NO;
//    }
    
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    // FBSample logic
    // Any time the session is closed, we want to display the login controller (the user
    // cannot use the application unless they are logged in to Facebook). When the session
    // is opened successfully, hide the login controller and show the main UI.
    switch (state) {
        case FBSessionStateCreatedOpening: {
           
        }
            break;

        case FBSessionStateOpen: {
 
        }
            break;
        case FBSessionStateClosed: {
            // FBSample logic
            // Once the user has logged out, we want them to be looking at the root view.
//            UIViewController *topViewController = [self.navigationController topViewController];
//            UIViewController *modalViewController = [topViewController modalViewController];
//            if (modalViewController != nil) {
//                [topViewController dismissModalViewControllerAnimated:NO];
//            }
//            [self.navigationController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
//            [self performSelector:@selector(showLoginView)
//                       withObject:nil
//                       afterDelay:0.5f];
        }
            break;
        case FBSessionStateClosedLoginFailed: {
            // if the token goes invalid we want to switch right back to
            // the login view, however we do it with a slight delay in order to
            // account for a race between this and the login view dissappearing
            // a moment before
//            [self performSelector:@selector(showLoginView)
//                       withObject:nil
//                       afterDelay:0.5f];
            [FBSession.activeSession closeAndClearTokenInformation];
            if ([[[navigationController viewControllers] lastObject] isKindOfClass:[LoginAnimatedViewController class]]) {
                loginViewController = (LoginAnimatedViewController *)[[navigationController viewControllers] lastObject];
            }
            [loginViewController failed];
        }
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification
                                                        object:session];
    
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error: %@",
                                                                     [TestAppDelegate FBErrorCodeDescription:error.code]]
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code {
    switch(code){
        case FBErrorInvalid :{
            return @"FBErrorInvalid";
        }
        case FBErrorOperationCancelled:{
            return @"FBErrorOperationCancelled";
        }
        case FBErrorLoginFailedOrCancelled:{
            return @"FBErrorLoginFailedOrCancelled";
        }
        case FBErrorRequestConnectionApi:{
            return @"FBErrorRequestConnectionApi";
        }case FBErrorProtocolMismatch:{
            return @"FBErrorProtocolMismatch";
        }
        case FBErrorHTTPError:{
            return @"FBErrorHTTPError";
        }
        case FBErrorNonTextMimeTypeReturned:{
            return @"FBErrorNonTextMimeTypeReturned";
        }
        case FBErrorNativeDialog:{
            return @"FBErrorNativeDialog";
        }
        default:
            return @"[Unknown]";
    }
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
    //[FBSession.activeSession handleDidBecomeActive];
    
    UIDevice *currentDevice = [UIDevice currentDevice];

    if(!([currentDevice respondsToSelector:@selector(isMultitaskingSupported)] && [currentDevice isMultitaskingSupported]))
    {
        [[StartViewController sharedInstance] didBecomeActive];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DLog(@"applicationWillTerminate");
    [FBSession.activeSession close];
    
}

- (void)AnalyticsTrackEvent:(NSNotification *)notification {
    
    NSError	*err;
	NSString *fbUserId;
    fbUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"id"];
    
    if ([fbUserId length] == 0)
        fbUserId = @"Anonymous"; 
    
    if(![fbUserId isEqualToString:@"NoGC"]){
    }
    
	NSString *page = [[notification userInfo] objectForKey:@"event"];
	DLog(@"GA page %@",page);
	if (page){
//		if (![[GAI sharedInstance].defaultTracker trackView:page])			DLog(@" Can't track pageview");
    [[GANTracker sharedTracker] trackPageview:page withError:nil];
	}else DLog(@" Can't track pageview");
//	[[GAI sharedInstance] dispatch];
  
}
#pragma mark -
#pragma mark GANTrackerDelegate methods

- (void)hitDispatched:(NSString *)hitString {
  NSLog(@"Hit Dispatched: %@", hitString);
}

- (void)trackerDispatchDidComplete:(GANTracker *)tracker
                  eventsDispatched:(NSUInteger)hitsDispatched
              eventsFailedDispatch:(NSUInteger)hitsFailedDispatch {
  NSLog(@"Dispatch completed (%u OK, %u failed)",
        hitsDispatched, hitsFailedDispatch);
}


#pragma mark GADRequest generation

// Here we're creating a simple GADRequest and whitelisting the application
// for test ads. You should request test ads during development to avoid
// generating invalid impressions and clicks.
- (GADRequest *)createRequest {
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad.
    request.testing = NO;
    
    return request;
}

#pragma mark - AlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if ([[[navigationController viewControllers] lastObject] isKindOfClass:[LoginAnimatedViewController class]]) {
            loginViewController = (LoginAnimatedViewController *)[[navigationController viewControllers] lastObject];
        }
        [loginViewController failed];
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
        if ([controller respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
            // Manually invoke the alert view button handler
            [(id <UIAlertViewDelegate>)controller alertView:nil
                                    clickedButtonAtIndex:kFacebookSettingsButtonIndex];
        }

    }
    
}

#pragma mark GADBannerViewDelegate impl

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"Received ad successfully");
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

- (void)dealloc
{
    DLog(@"Exit");
}

@end
