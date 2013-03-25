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
#import "ListOfItemsViewController.h"

#import "Crittercism.h"
#import "StartViewController.h"
#import "AccountDataSource.h"

#import "GAI.h"

#define kFacebookSettingsButtonIndex 1

static const NSInteger kGANDispatchPeriod = 60;
#ifdef DEBUG
static NSString *kGAAccountID = @"UA-24007807-3";
#else
static NSString *kGAAccountID = @"UA-38210757-1";
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
    
    id<GAITracker> tracker;
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
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [GAI sharedInstance].debug = NO;
    tracker = [[GAI sharedInstance] trackerWithTrackingId:kGAAccountID];
	
    //[Crittercism initWithAppID:ID_CRIT_APP  andKey:ID_CRIT_KEY andSecret:ID_CRIT_SECRET];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AnalyticsTrackEvent:)
												 name:kAnalyticsTrackEventNotification object:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    application.statusBarOrientation = UIInterfaceOrientationPortrait;
  
//    loginViewController = [LoginAnimatedViewController sharedInstance];
//    navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    LoadViewController *loadViewController;
    
    loadViewController= [[LoadViewController alloc] initWithPush:launchOptions];
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:loadViewController];
    loadViewController = nil;
    [navigationController setNavigationBarHidden:YES];
    
    CGRect frame = [[UIScreen mainScreen]bounds];
    window = [[UIWindow alloc]initWithFrame:frame];
    
    UIImageView *background = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"back.png"]];
    frame = background.frame;
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
    /*
    frame = [UIScreen mainScreen].bounds;
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
    */
    if([[OGHelper sharedInstance] isAuthorized]){
        [self openSessionWithAllowLoginUI:YES];
    }
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeNewsstandContentAvailability | UIRemoteNotificationTypeAlert)];
    
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

-(void)fbResync
{
    ACAccountStore *accountStore;
    ACAccountType *accountTypeFB;
    if ((accountStore = [[ACAccountStore alloc] init]) && (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) ){
        
        NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
        id account;
        if (fbAccounts && [fbAccounts count] > 0 && (account = [fbAccounts objectAtIndex:0])){
            
            [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                //we don't actually need to inspect renewResult or error.
                if (error){
                    
                }
            }];
        }
    }
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
                                                                message:NSLocalizedString(@"You can't connnect to Facebook right now, make sure  your device has an internet connection and you have at least one Facebook account setup. Go to Settings -> Facebook and set up it.", @"AlertView")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"AlertView")
                                                      otherButtonTitles: nil];
            alertView.tag = 1;
            [alertView show];
            return NO;
        }
    }

    [self openSessionWithPermission:permissions];
}

-(void)openSessionWithPermission:(NSArray *)permissions
{
    float ver_float = [[[UIDevice currentDevice] systemVersion] floatValue];
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      if(error)
                                      {
                                          NSLog(@"Session error %@", error);
                                          if (ver_float >= 6.0) [self fbResync];
                                          [NSThread sleepForTimeInterval:1.5];   //half a second
                                          [self openSessionWithPermission:permissions];
                                      }
                                      else
                                          [self sessionStateChanged:session state:state error:error];
                                  }];
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

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    
    NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
    [usrDef setObject:newToken forKey:@"DeviceToken"];
    [usrDef synchronize];    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSDictionary *sInfo = [userInfo objectForKey:@"aps"];
    NSString *message = [sInfo objectForKey:@"alert"];
    
    sInfo = [userInfo objectForKey:@"i"];
    	
	[[NSNotificationCenter defaultCenter] postNotificationName:kPushNotification
														object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:sInfo, @"messageId",message, @"message", nil]];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"Get memory warning");
}

#pragma mark GATrackEvent
- (void)AnalyticsTrackEvent:(NSNotification *)notification {
	NSString *page = [[notification userInfo] objectForKey:@"event"];
    NSInteger demention = [[[notification userInfo] objectForKey:@"demention"] intValue];
    NSString *value = [[notification userInfo] objectForKey:@"value"];
	if (page){
        if (demention && value) {
            [tracker setCustom:demention dimension:value];
        }
        BOOL result = [tracker sendView:page];
        if (result) {
            DLog(@"GA page send %@",page);
        }else{
            DLog(@"GA page error %@",page);
        }
	}
	[[GAI sharedInstance] dispatch];
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

#pragma mark AlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
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
