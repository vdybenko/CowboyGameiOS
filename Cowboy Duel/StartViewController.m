//
//
//  StartViewController.m
//  Test
//
//  Created by Sobol on 20.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StartViewController.h"
#import "AdColonyViewController.h"
#import "UIView+Hierarchy.h"
#import "UIButton+Image+Title.h"
#import "AdvertisingNewVersionViewController.h"
#import "AdvertisingOtherAppViewController.h"
#import "AdvertisingAppearController.h"
#import "ListOfItemsViewController.h"
#import "CustomNSURLConnection.h"
#import "GameCenterViewController.h"
#import "Utils.h"
#import "PurchasesManager.h"
#import "LevelCongratViewController.h"
#import "MoneyCongratViewController.h"

#include <sys/types.h>
#include <sys/sysctl.h>

@interface StartViewController (PrivateMethods)

-(void)retrieveMessageFromDevice;
-(void)sendRequestWithDonateSum:(int)sum;
- (NSString *)deviceType;
-(void)arrowAnimation;

@end

#define PUSH_MES_TAG 2
#define BOT_DUEL_TAG 3
#define CON_GC_TAG 4
#define ESTIMATE_APP_TAG 5
#define TAG_HUB_VIEW 1010

#define iTunesId @"http://cowboyduel.mobi/r/"

// http://itunes.apple.com/ua/app/platforma/id525730690?mt=8

@implementation StartViewController

@synthesize gameCenterViewController, player, internetActive, hostActive, soundCheack, loginViewController;
@synthesize feedbackButton, duelButton, profileButton, teachingButton, helpButton, mapButton;
@synthesize _vBackground,oldAccounId,feedBackViewVisible,showFeedAtFirst,topPlayersDataSource;
//@synthesize feedbackView;

static const char *DONATE_URL = BASE_URL"api/donate";
static const char *AUTORIZATION_URL =  BASE_URL"api/authorization";
static const char *MODIFIER_USER_URL =  BASE_URL"api/user";
static const char *GET_RANDOM_USER_URL =  BASE_URL"api/get_random_user";
static const char *A_URL =  BASE_URL"api/a";
static const char *OUT_URL =  BASE_URL"api/out";

NSString *const URL_FB_PAGE=@"http://cowboyduel.mobi/"; 
NSString *const NewMessageReceivedNotification = @"NewMessageReceivedNotification";

static NSString *getGameCenterSavePath()  
{  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    return [NSString stringWithFormat:@"%@/FBMessageSave.txt",[paths objectAtIndex:0]];  
}  

static NSString *textArchiveKey = @"TextMes"; 

static StartViewController *sharedHelper = nil;
+ (StartViewController *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[StartViewController alloc] init];
    }
    return sharedHelper;
}

-(id)init
{
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    
    firstRunController = YES;
    inBackground = NO;
        
    if (self == [super initWithNibName:nil bundle:nil]) {
        
        playerAccount = [AccountDataSource sharedInstance];
        [playerAccount setDelegate:self];
        oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer];
        oponentAccount.money = 1000;        
          
        showFeedAtFirst=NO;
        
        topPlayersDataSource = [[TopPlayersDataSource alloc] initWithTable:nil];
        
        firstDayWithOutAdvertising=YES;
        if(![uDef boolForKey:@"AlreadyRun"] )  
        {
            firstRun = YES;
            firstRunLocal = YES;
            
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"estimateApp"];
            [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"kFrequencyOfAdvertising"];
        }
        else 
        {
            firstRun = NO;
            firstRunLocal = NO;
            if (![GCHelper sharedInstance].GClocalPlayer.isAuthenticated) {
                [[GCHelper sharedInstance] authenticateLocalUser];
            }
            [topPlayersDataSource reloadDataSource];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"moneyForIPad"];
        }
        if(firstRun)DLog(@"First ");
        //        [[NSUserDefaults standardUserDefaults] setBool:firstRun forKey:@"AlreadyRan"];
        
        if(firstRun){
            
            [uDef setBool:TRUE forKey:@"FirstRunForGun"];
            [uDef setBool:TRUE forKey:@"FirstRunForDuel"];
            [uDef setInteger:200 forKey:@"money"];
            [uDef setObject:ValidateObject(playerAccount.accountName, [NSString class]) forKey:@"name"];
            NSString *accID=[[NSString alloc]init];
            if(playerAccount.accountID==NULL){
                accID=@"NoGC";
            }else{
                accID=playerAccount.accountID;
            }
            
            [uDef setObject:ValidateObject(accID, [NSString class]) forKey:@"id"];
            [uDef setObject:ValidateObject(playerAccount.typeImage, [NSString class]) forKey:@"typeImage"];
            [uDef setObject:ValidateObject([self deviceType], [NSString class]) forKey:@"deviceType"];
            playerAccount.glNumber = [NSNumber numberWithInt:0];
            [uDef setInteger:playerAccount.accountLevel forKey:@"accountLevel"];
            [uDef setInteger:playerAccount.accountPoints forKey:@"lvlPoints"];
            [uDef setInteger:playerAccount.accountWins forKey:@"WinCount"];
            [uDef setInteger:playerAccount.accountDraws forKey:@"DrawCount"];
            [uDef setInteger:playerAccount.accountBigestWin forKey:@"MaxWin"];
            [uDef setInteger:playerAccount.removeAds forKey:@"RemoveAds"];
            
            [uDef setObject:ValidateObject(playerAccount.avatar, [NSString class]) forKey:@"avatar"];
            [uDef setObject:ValidateObject(playerAccount.age, [NSString class]) forKey:@"age"];
            [uDef setObject:ValidateObject(playerAccount.homeTown, [NSString class]) forKey:@"homeTown"];
            [uDef setInteger:playerAccount.friends forKey:@"friends"];
            [uDef setObject:ValidateObject(playerAccount.facebookName, [NSString class]) forKey:@"facebook_name"];
            
            [uDef synchronize];
        }else{
            
            [uDef setBool:FALSE forKey:@"FirstRunForGun"];
            [uDef setBool:FALSE forKey:@"FirstRunForDuel"];
            playerAccount.accountID = [uDef stringForKey:@"id"];
            if ([playerAccount.accountID isEqualToString:@""]) [playerAccount makeLocalAccountID];
            
            playerAccount.accountName = [uDef stringForKey:@"name"];
            playerAccount.typeImage=[uDef stringForKey:@"typeImage"];
            playerAccount.typeGun=[uDef integerForKey:@"typeGun"];
            playerAccount.money = [uDef integerForKey:@"money"]; 
            playerAccount.accountLevel = [uDef integerForKey:@"accountLevel"]; 
            playerAccount.accountPoints = [uDef integerForKey:@"lvlPoints"]; 
            playerAccount.accountWins= [uDef integerForKey:@"WinCount"];
            playerAccount.accountDraws = [uDef integerForKey:@"DrawCount"]; 
            playerAccount.accountBigestWin = [uDef integerForKey:@"MaxWin"]; 
            playerAccount.removeAds = [uDef integerForKey:@"RemoveAds"];
            
            playerAccount.avatar = [uDef stringForKey:@"avatar"];
            playerAccount.age = [uDef stringForKey:@"age"];
            playerAccount.homeTown = [uDef stringForKey:@"homeTown"];
            playerAccount.friends = [uDef integerForKey:@"friends"];
            playerAccount.facebookName = [uDef stringForKey:@"facebook_name"];
            
            if(![uDef stringForKey:@"deviceType"])
                [uDef setObject:ValidateObject([self deviceType], [NSString class]) forKey:@"deviceType"];
            
            if(playerAccount.money<0){
                playerAccount.money=0;
                DLog(@"-10000");
            }
            [uDef setObject:ValidateObject(playerAccount.accountID, [NSString class]) forKey:@"id"];
            
            if (!([playerAccount.accountID rangeOfString:@"F"].location == NSNotFound)){ 
                facebook = [[Facebook alloc] initWithAppId:kFacebookAppId andDelegate:[LoginViewController sharedInstance]];
                
                if ([uDef objectForKey:@"FBAccessTokenKey"] 
                    && [uDef objectForKey:@"FBExpirationDateKey"]) {
                    facebook.accessToken = [uDef objectForKey:@"FBAccessTokenKey"];
                    facebook.expirationDate = [uDef objectForKey:@"FBExpirationDateKey"];
                }
                [[LoginViewController sharedInstance] setFacebook:facebook];
                [[OGHelper sharedInstance ] initWithAccount:playerAccount facebook:facebook];
                [[OGHelper sharedInstance ] setStartViewController:self];
            }
            
            DLog(@"Transactions count = %d", [playerAccount.transactions count]);
            
            //NSMutableArray *locations = [NSMutableArray array];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"transactions"];

            NSArray *oldLocations = [uDef arrayForKey:@"transactions"];
            if( [oldLocations count]!=0)
            {
                //DLog(@"locations is not nil");
                for( NSData *data in oldLocations )
                {
                    CDTransaction * loc = (CDTransaction*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    //                    DLog(@"money %d", [loc.trMoneyCh intValue]);
                    //                    DLog(@"type %d", [loc.trType intValue]);
                    //                    DLog(@"localID %d", [loc.trLocalID intValue]);
                    //                    DLog(@"globalID %d", [loc.trGlobalID intValue]);
                    [playerAccount.transactions addObject:loc];
                }
            }
            CDTransaction *localTransaction = [playerAccount.transactions lastObject];
            playerAccount.glNumber = localTransaction.trLocalID;
          DLog(@"Transactions count = %d", [playerAccount.transactions count]);
           // DLog(@"Transactions count = %d", [playerAccount.transactions count]);
            
            
            NSArray *oldLocations2 = [uDef arrayForKey:@"duels"];
            if( playerAccount.duels )
            {
                //DLog(@"locations is not nil");
                for( NSData *data in oldLocations2 )
                {
                    CDDuel * loc = (CDDuel*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    DLog(@"gps %d", [loc.dGps intValue]);
                    DLog(@"id %@", loc.dOpponentId);
                    DLog(@"fire %d", [loc.dRateFire intValue]);
                    DLog(@"date %@", loc.dDate);
                    [playerAccount.duels addObject:loc];
                }
            }
            DLog(@"Duels count = %d", [playerAccount.duels count]);
            
            NSArray *oldLocations3 = [uDef arrayForKey:@"achivments"];
            if( playerAccount.duels )
            {
                //DLog(@"locations is not nil");
                for( NSData *data in oldLocations3 )
                {
                    CDAchivment * loc = (CDAchivment*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    DLog(@"achivments %@", loc.aAchivmentId);
                    [playerAccount.achivments addObject:loc];
                }
            }
            //            DLog(@"Achivments count = %d", [playerAccount.achivments count]);
        }
               
//        [self.view addSubview:_vBackground];
               
//        UIImageView *cloudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"st_cloud.png"]];
//        [_vBackground addSubview:cloudView];     
        

        checkGameCenter = NO;
        dicForRequests=[[NSMutableDictionary alloc] init];
        //        [self.view addSubview:_vBackground];
        

//        chatViewController = [[ChatViewController alloc] initWithAccount:playerAccount];
//        [_vBackground addSubview:chatViewController.view];

        //        UIImageView *cloudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"st_cloud.png"]];
        //        [_vBackground addSubview:cloudView];     

        

        checkGameCenter = NO;
        
        globalAngle = 0;
        
        //gameCenterViewController = [[GameCenterViewController alloc] initWithAccount:playerAccount andParentVC:self];
        gameCenterViewController = [GameCenterViewController sharedInstance:playerAccount andParentVC:self];
        
//        bluetoothViewController = [[BluetoothViewController alloc] initWithAccount:playerAccount andView:self andStart:YES];
        listOfItemsViewController=[[ListOfItemsViewController alloc]initWithGCVC:gameCenterViewController Account:playerAccount OnLine:self.hostActive];
        
        // [self performSelectorInBackground:@selector(startCloudAnimation) withObject:self];
        avtorisationCheck = YES;
//        [bluetoothViewController setupSession];
        
        //      GoogleAnalytics
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/" forKey:@"event"]];
        
        internetActive=YES;
        hostActive=YES;
        
        
        UIDevice *currentDevice = [UIDevice currentDevice];                                                 //server logout
        
        if( [currentDevice respondsToSelector:@selector(isMultitaskingSupported)] && 
           [currentDevice isMultitaskingSupported])
        {
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(didEnterBackground)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(didBecomeActive)
                                                         name:UIApplicationDidBecomeActiveNotification
                                                       object:nil];
        }     
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(didFinishLaunching)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
                
        activityIndicatorView = [[ActivityIndicatorView alloc] initWithoutRotate];
        CGRect imgFrame = activityIndicatorView.frame;
        imgFrame.origin = CGPointMake(0, -80);
        activityIndicatorView.frame=imgFrame;
        
        [activityIndicatorView hideView];
        
        if (([[NSUserDefaults standardUserDefaults] integerForKey:@"soundCheack"] == 0) && (!firstRun))
            soundCheack = NO;
        else {
            soundCheack = YES;
            NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
            [uDef setInteger:1 forKey:@"soundCheack"];
            [uDef synchronize];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        
        internetReachable = [Reachability reachabilityForInternetConnection];
        [internetReachable startNotifier];
        
        // check if a pathway to a random host exists
        hostReachable = [Reachability reachabilityWithHostName: @"www.apple.com"];
        [hostReachable startNotifier];
        
        activityIndicatorView2 = [[ActivityIndicatorView alloc] init];
        imgFrame = activityIndicatorView.frame;
        imgFrame.origin = CGPointMake(0, -80);
        activityIndicatorView2.frame=imgFrame;
        [activityIndicatorView2 hideView]; 
        [_vBackground addSubview:activityIndicatorView2];
        
        oldAccounId = @"";
        
        if ([playerAccount.accountID rangeOfString:@"A"].location != NSNotFound)
            [self authorizationModifier:NO];
    }
    
    return self; 
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad{
       
    
    UIColor *buttonsTitleColor = [[UIColor alloc] initWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    [duelButton setTitle:NSLocalizedString(@"Saloon", @"") forState:UIControlStateNormal];
    [duelButton setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    duelButton.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    duelButton.titleLabel.textAlignment = UITextAlignmentCenter;
  
    [teachingButton setTitle:NSLocalizedString(@"Practice", @"") forState:UIControlStateNormal];
    [teachingButton setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    teachingButton.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    teachingButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [duelButton setTitle:NSLocalizedString(@"Saloon", @"") forState:UIControlStateNormal];
    [duelButton setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    duelButton.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    duelButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [teachingButton setTitle:NSLocalizedString(@"Practice", @"") forState:UIControlStateNormal];
    [teachingButton setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    teachingButton.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    teachingButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [profileButton setTitle:NSLocalizedString(@"Profile", @"") forState:UIControlStateNormal];
    [profileButton setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    profileButton.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    profileButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [feedbackButton setTitle:NSLocalizedString(@"Feedback", @"") forState:UIControlStateNormal];
    [feedbackButton setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    feedbackButton.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    feedbackButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [helpButton setTitle:NSLocalizedString(@"HelpTitle", @"") forState:UIControlStateNormal];
    [helpButton setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    helpButton.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    helpButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [mapButton setTitle:NSLocalizedString(@"MoreGames", @"") forState:UIControlStateNormal];
    [mapButton setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    mapButton.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    mapButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    
    UIColor *textColor = [UIColor whiteColor];
    
    UIFont *textFont = [UIFont systemFontOfSize:16.0f];
    
    lbPostMessage.text = NSLocalizedString(@"SocialNetworksTitle", nil);
    lbPostMessage.textColor = textColor;
    lbPostMessage.font = textFont;
    
    lbMailMessage.text = NSLocalizedString(@"EmailInviteTitle", nil);
    lbMailMessage.textColor = textColor;
    lbMailMessage.font = textFont;
    
    lbRateMessage.text = NSLocalizedString(@"RateTitle", nil);
    lbRateMessage.textColor = textColor;
    lbRateMessage.font = textFont;
    
    lbFeedbackCancelBtn.text = NSLocalizedString(@"CancelButtonTitle", nil);
    lbFeedbackCancelBtn.textColor = buttonsTitleColor;
    lbFeedbackCancelBtn.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
    feedBackViewVisible=NO;
    
    if (firstRun) {
//        [teachingButton bringToFront];
        
        arrowImage=[[UIImageView_AttachedView alloc] initWithImage:[UIImage imageNamed:@"st_arrow.png"] attachedToFrame:teachingButton frequence:0.5 amplitude:10 direction:DirectionToAnimateLeft];
        
        hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 480)];
        hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        [hudView setTag:TAG_HUB_VIEW];
        [hudView setHidden:NO];
        [self.view insertSubview:hudView belowSubview:teachingButton];
        [hudView addSubview:arrowImage];
        
        [arrowImage startAnimation];
        
    }else{
        [hudView setHidden:YES];
    }
    
    [self checkFor10Dolars];
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Back1cycled.mp3", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) DLog(@"Player error %@", error);
    
    [player setNumberOfLoops:999];
    [player prepareToPlay];
    
    if (!soundCheack) {
        player.volume = 0.0;
    }
    else
    {
        player.volume = 1.0;
    }
    
    [player play];
}
- (void)viewDidUnload {
    

    feedbackView = nil;
    lbPostMessage = nil;
    lbMailMessage = nil;
    lbRateMessage = nil;
    lbFeedbackCancelBtn = nil;
    [super viewDidUnload];
}
    
-(void)viewWillAppear:(BOOL)animated
{   
    [super viewWillAppear:animated];
    
    [self playerStart];
    
    if (firstRun) {
        firstRun = NO;
        return;
    }
    
    animationCheck = YES;
    
    viewIsVisible = YES;
    
    inBackground = NO;
    
    //    Change order of Buttons on first start
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    if ([userDef integerForKey:@"FirstRunForPractice"] == 2) {
        
        //        Final exchange after first duel
        [hudView setHidden:YES];
        [hudView removeFromSuperview];
        
    }
    if (([userDef integerForKey:@"FirstRunForPractice"] == 1) && ([self connectedToWiFi])) {
        //        Show btn Duel GC
        //       exchange after practice
        
        UIImageView_AttachedView *arrowImage3=[[UIImageView_AttachedView alloc] initWithImage:[UIImage imageNamed:@"st_arrow.png"] attachedToFrame:duelButton frequence:0.5 amplitude:10 direction:DirectionToAnimateLeft];
        [hudView addSubview:arrowImage3];
        [arrowImage3 startAnimation];
        
        [teachingButton swapDepthsWithView:duelButton];
//        
        [arrowImage setHidden:YES];
        
        [userDef setInteger:2 forKey:@"FirstRunForPractice"];
        [userDef synchronize];
    }
    if ((![self connectedToWiFi]) && ([userDef integerForKey:@"FirstRunForPractice"] == 1)) {
        //        Final exchange internet connection off
        
        [hudView setHidden:YES];
        [hudView removeFromSuperview];
        //        [self.view exchangeSubviewAtIndex:12 withSubviewAtIndex:14];
    }
    ////////internet conection notification
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName: @"www.apple.com"];
    [hostReachable startNotifier];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BOOL mutchEnded;
    if ((gameCenterViewController.userEndMatch && gameCenterViewController.opponentEndMatch) || (!gameCenterViewController.userEndMatch && !gameCenterViewController.opponentEndMatch)) 
        mutchEnded = YES;
    else 
        mutchEnded = NO;
        
    if (!gameCenterViewController.multiplayerServerViewController.isRunServer && !gameCenterViewController.multiplayerServerViewController.neadRestart && mutchEnded)    [gameCenterViewController startServerWithName:playerAccount.accountID];
    gameCenterViewController.duelStartViewController = nil;
    
    [self showProfileFirstRun];
    [self isAdvertisingOfNewVersionNeedShow];
    [self estimateApp];
}

-(void)showMessage:(NSString *)tempMessage
{
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    viewIsVisible = NO;
    animationCheck = NO;
}

-(void)didBecomeActive
{
    DLog(@"did become active");
    if ((inBackground) && (viewIsVisible)) {
        DLog(@"in back");
        animationCheck = YES;
    }
    if (!firstRunLocal) {
         [self login];
    }
    
    [facebook extendAccessTokenIfNeeded];
    
    firstDayWithOutAdvertising=[AdvertisingAppearController advertisingCheckForAppearWithFirstDayWithOutAdvertising:firstDayWithOutAdvertising];
}

-(void)didEnterBackground
{
    animationCheck = NO;
    inBackground = YES;
    [self logout];
}

-(void)didFinishLaunching
{    
    NSString *FilePath = [[OGHelper sharedInstance] getSavePathForList];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSError *error= nil;
    if ([fileMgr removeItemAtPath:FilePath error:&error] != YES){
        DLog(@"TestAppDelegate: Unable to delete file: %@", [error localizedDescription]);
        
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:FilePath withIntermediateDirectories:NO attributes:nil error:&error];
    

}

-(void)donate
{
    stDonate = [[NSMutableString alloc] initWithString:@"/donate"] ;
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:stDonate forKey:@"event"]];
    
    
    CGRect frame=CGRectMake(190, 5, 120, 26);
    
    
    frame=CGRectMake(10, 10, 460, 26);
    UILabel *label3 = [[UILabel alloc] initWithFrame:frame];
    [label3 setFont: [UIFont fontWithName: @"Arial-BoldMT" size:13]];
    label3.textAlignment = UITextAlignmentCenter; 
    [label3 setBackgroundColor:[UIColor clearColor]];
    [label3 setTextColor:[UIColor whiteColor]];
    [label3 setText:NSLocalizedString(@"MOREMONEY_TEXT", @"")];
    DLog(@"Donation %@  %@",NSLocalizedString(@"MOREMONEY_TEXT", @""),NSLocalizedString(@"ACH", @""));
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"     " delegate:self cancelButtonTitle:NSLocalizedString(@"CAN", @"") destructiveButtonTitle:nil otherButtonTitles:
                                  NSLocalizedString(@"MOREMONEY1", @""),
                                  NSLocalizedString(@"MOREMONEY5", @""),
                                  NSLocalizedString(@"MOREMONEY100", @""), nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    //[actionSheet addSubview:label2];
    [actionSheet addSubview:label3];
    [actionSheet showInView:self.view];
}

#pragma mark -

-(bool)connectedToWiFi
{
	return hostActive;
	
}

-(void)duelButtonClick
{
    //[gameCenterViewController.multiplayerServerViewController setIsRunServer:NO];
    [listOfItemsViewController setStatusOnLine:self.hostActive];
    [self.navigationController pushViewController:listOfItemsViewController animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"saloon_click" forKey:@"event"]];
    
}

-(IBAction)teachingButtonClick
{  
   
    [playerAccount.finalInfoTable removeAllObjects];
    int randomTime = arc4random() % 6; 
    
    oponentAccount.accountName=NSLocalizedString(@"COMPUTER", @"");
    oponentAccount.money = 1000;
    oponentAccount.accountLevel = 4;//playerAccount.accountLevel;
    oponentAccount.accountPoints = playerAccount.accountPoints;
    
    TeachingViewController *teachingViewController = [[TeachingViewController alloc] initWithTime:randomTime andAccount:playerAccount andOpAccount:oponentAccount];
    [self.navigationController pushViewController:teachingViewController animated:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/duel_teaching" forKey:@"event"]];
}

-(IBAction)mapButtonClick
{
    collectionAppViewController=[[CollectionAppViewController alloc] init];
    [self presentModalViewController:collectionAppViewController animated:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"more_games" forKey:@"event"]];

}

-(IBAction)profileButtonClick 
{   
    
    profileViewController = [[ProfileViewController alloc] initWithAccount:playerAccount startViewController:self];
    [profileViewController setNeedAnimation:YES];
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;//, kCATransitionReveal, kCATransitionFade,kCATransitionMoveIn;
    transition.subtype =kCATransitionFromLeft;//kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:profileViewController animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"profile_click" forKey:@"event"]];
}

-(void)profileButtonClickWithOutAnimation;
{   
    UIViewController *topController=[self.navigationController topViewController];
    if (![topController isKindOfClass:[ProfileViewController class]]) {
        profileViewController = [[ProfileViewController alloc] initWithAccount:playerAccount startViewController:self];
        [profileViewController.ivBlack setHidden:NO];
        [self.navigationController pushViewController:profileViewController animated:NO];
    }
}

-(IBAction)startDuel
{
    [self checkNetworkStatus:nil];

    if (![self isNeedBlockOnlineListForAdvertasingAppear]) {
        //play duel 
        [self duelButtonClick];
    }
}


- (void) showFeedbackView {
       
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES]; 
	[UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
    [UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
    CGRect frame = feedbackView.frame;
    frame.origin.y = 90.0f;
    feedbackView.frame = frame;
    
    [UIView commitAnimations];
    
    feedBackViewVisible=YES;
}

- (void) hideFeedbackView {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES]; 
	[UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
    [UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
    CGRect frame = feedbackView.frame;
    frame.origin.y = 480.0f;
    feedbackView.frame = frame;
    
    [UIView commitAnimations];
    
    feedBackViewVisible=NO;
}

-(IBAction)showHelp:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/help_click" forKey:@"event"]];
    
    HelpViewController *helpViewController = [[HelpViewController alloc] init:firstRun startVC:self];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromBottom;//kCATransitionFromTop; kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop,
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:helpViewController animated:NO];
}

-(void) advertButtonClick {
    AdColonyViewController *adColonyViewController = [[AdColonyViewController alloc]initWithStartVC:self];
    [self presentModalViewController:adColonyViewController animated:YES];
}

#pragma mark -
#pragma mark feedback

- (IBAction)feedbackButtonClick:(id)sender {
    [self showFeedbackView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/feedBack_click" forKey:@"event"]];
}

- (IBAction)feedbackCancelButtonClick:(id)sender {
    [self hideFeedbackView];
}

- (IBAction)feedbackFacebookBtnClick:(id)sender {
    
        if ([[OGHelper sharedInstance]isAuthorized]) { 
                [[OGHelper sharedInstance] apiDialogFeedUser];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                                    object:self
                                                                  userInfo:[NSDictionary dictionaryWithObject:@"/feedBack_Facebook_click" forKey:@"event"]];
            }else {
                [[LoginViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusFeed];
                [[LoginViewController sharedInstance] fbLoginBtnClick:self];
        }
}

- (IBAction)feedbackTweeterBtnClick:(id)sender {
    if ([TWTweetComposeViewController canSendTweet])
    {
        TWTweetComposeViewController *tweetSheet = 
        [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:@"I'm playing in Cowboy duels"];
        [tweetSheet addURL:[NSURL URLWithString:URL_FB_PAGE]];
        
	    [self presentModalViewController:tweetSheet animated:YES];
    }
    else
    {
        float ver_float = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (ver_float < 5.0) {
            NSString *URL=[[NSString alloc]initWithFormat:@"http://mobile.twitter.com/home?status=%@ %@",
                           @"I'm playing in Cowboy duels",
                           URL_FB_PAGE];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }else {
            UIAlertView *alertView = [[UIAlertView alloc] 
                                      initWithTitle:@"Sorry"                                                             
                                      message:@"You can't send a tweet right now, make sure  your device has an internet connection and you have at least one Twitter account setup"                                                          
                                      delegate:self                                              
                                      cancelButtonTitle:@"OK"                                                   
                                      otherButtonTitles:nil];
            [alertView show];

        }        
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                    object:self
                                                  userInfo:[NSDictionary dictionaryWithObject:@"/feedBack_Tweeter_click" forKey:@"event"]];
}

- (IBAction)feedbackMailBtnClick:(id)sender {
//    
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:NSLocalizedString(@"Awesome cowboy duel", @"")];
	
	// Fill out the email body text
	NSString *emailBody = NSLocalizedString(@"Mes text", @"");
    
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
    //    [picker release];

    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/feedBack_Mail_click" forKey:@"event"]];
}

- (IBAction)feedbackItuneskBtnClick:(id)sender {
    
    NSURL *url = [NSURL URLWithString:iTunesId];
    
    [[UIApplication sharedApplication] openURL:url];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/feedBack_ITunes_click" forKey:@"event"]];
}

-(void)hideActivitiIndicatorViewFeedback;
{
    [backGroundfeedbackView sendToBack];
    [indicatorfeedbackView stopAnimating];
    [indicatorfeedbackView sendToBack];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFBFeed object:nil];	

}

#pragma mark -
#pragma mark Compose Mail

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			DLog(@"Result: canceled");
			break;
		case MFMailComposeResultSaved:
			DLog(@"Result: saved");
			break;
		case MFMailComposeResultSent:
			DLog(@"Result: sent");
			break;
		case MFMailComposeResultFailed:
			DLog(@"Result: failed");
			break;
		default:
			DLog(@"Result: not sent");
			break;
	}
    [self dismissModalViewControllerAnimated:YES];
    
    
}

#pragma mark -

-(void)sendRequestWithDonateSum:(int)sum
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:DONATE_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    [theRequest setHTTPMethod:@"POST"]; 
    NSMutableDictionary *dicBody=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%d", sum],@"sum",
                                  version,@"app_ver",
                                  currentDevice.systemName,@"system_name",
                                  currentDevice.systemVersion,@"system_version",
                                  currentDevice.uniqueIdentifier ,@"unique_identifier",
                                  nil];
    
    [dicBody setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceType"] forKey:@"device_name"];
    [dicBody setValue:playerAccount.accountID forKey:@"authentification"];
    [dicBody setValue:playerAccount.accountID forKey:@"GC_id"];
    [dicBody setValue:playerAccount.sessionID forKey:@"session_id"];    
    
    
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
	[theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [dicForRequests setObject:receivedData forKey:[theConnection.requestURL lastPathComponent]];
    } else {
    }
}


-(void)login
{    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:A_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    [theRequest setHTTPMethod:@"POST"]; 
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                           playerAccount.accountID,@"id",
                           nil];
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
	[theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [dicForRequests setObject:receivedData forKey:[theConnection.requestURL lastPathComponent]];
    } 
    
}

-(void)logout
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:OUT_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    [theRequest setHTTPMethod:@"POST"]; 
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                           playerAccount.accountID,@"id",
                           nil];
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
	[theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {        
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [dicForRequests setObject:receivedData forKey:[theConnection.requestURL lastPathComponent]];
    } 
    
}

#pragma mark CustomNSURLConnection handlers

- (void)connectionDidFinishLoading:(CustomNSURLConnection *)connection1 {
    NSString * currentParseString = [NSString stringWithFormat:@"%@",connection1.requestURL];
    
    NSMutableData *receivedData=[dicForRequests objectForKey:[currentParseString lastPathComponent]];
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    [dicForRequests removeObjectForKey:[currentParseString lastPathComponent]];
    NSDictionary *responseObject = ValidateObject([jsonString JSONValue], [NSDictionary class]);
    
    DLog(@"StartVC \n jsonValues %@\n string %@",jsonString,currentParseString);
//    
//    OnLine
    if ([[currentParseString lastPathComponent] isEqualToString:@"a"]&&[responseObject objectForKey:@"session_id"]) {
        playerAccount.sessionID =[[NSString alloc] initWithString:[responseObject objectForKey:@"session_id"]];
        
        int revisionNumber=[[responseObject objectForKey:@"refresh_content"] intValue];
        if ([RefreshContentDataController isRefreshEvailable:revisionNumber]) {
            RefreshContentDataController *refreshContentDataController=[[RefreshContentDataController alloc] init];
            [refreshContentDataController refreshContent];
        }
        return;
    }       
    //avtorization
    if ((playerAccount.accountID != nil) && [[currentParseString lastPathComponent] isEqualToString:@"authorization"]) {
        
        DLog(@"avtorization /n %@",responseObject);
        
        NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        if ([responseObject objectForKey:@"session_id"]) {
            playerAccount.sessionID=[responseObject objectForKey:@"session_id"];
        }
        
        if ([[responseObject objectForKey:@"level"] intValue]!=playerAccount.accountLevel) {
            playerAccount.accountLevel=[[responseObject objectForKey:@"level"] intValue];
            [uDef setInteger:playerAccount.accountLevel forKey:@"accountLevel"];
            [[GCHelper sharedInstance] reportAchievementIdentifier:[[GCHelper sharedInstance].GC_ACH objectAtIndex:playerAccount.accountLevel-1] percentComplete:100.0f];
        }
        
        NSString *nameFromServer=[responseObject objectForKey:@"name"];
        if (nameFromServer) {
            playerAccount.accountName=nameFromServer;
            [uDef setObject:ValidateObject(playerAccount.accountName, [NSString class]) forKey:@"name"];
        }
        
        if ([[responseObject objectForKey:@"points"] intValue]!=playerAccount.accountPoints) {
            playerAccount.accountPoints=[[responseObject objectForKey:@"points"] intValue];
            [uDef setInteger:playerAccount.accountPoints forKey:@"lvlPoints"];
        }
        int duelsWin=[[responseObject objectForKey:@"duels_win"] intValue];
        if (duelsWin!=playerAccount.accountWins) {
            playerAccount.accountWins=duelsWin;
            [uDef setInteger:playerAccount.accountWins forKey:@"WinCount"];
        }
        
        int duelsLost=[[responseObject objectForKey:@"duels_lost"] intValue];
        if (duelsLost!=playerAccount.accountDraws) {
            playerAccount.accountDraws=duelsLost;
            [uDef setInteger:playerAccount.accountDraws forKey:@"DrawCount"];
        }
        
        int bigestWin=[[responseObject objectForKey:@"bigest_win"] intValue];
        if (bigestWin!=playerAccount.accountBigestWin) {
            playerAccount.accountBigestWin=bigestWin;
            [uDef setInteger:playerAccount.accountBigestWin forKey:@"MaxWin"];
        }
        
        if (playerAccount.removeAds!=AdColonyAdsStatusRemoved) {
            int removeAds=[[responseObject objectForKey:@"remove_ads"] intValue];
            playerAccount.removeAds=removeAds;
            [uDef setInteger:playerAccount.removeAds forKey:@"RemoveAds"];
        }

        NSString *urlAvatar=[responseObject objectForKey:@"avatar"];
        if (urlAvatar) {
            playerAccount.avatar=urlAvatar;
            [uDef setObject:ValidateObject(playerAccount.accountName, [NSString class]) forKey:@"avatar"];
        }
//        
        NSString *playerAge=[responseObject objectForKey:@"age"];
        if (playerAge) {
            playerAccount.age=playerAge;
            [uDef setObject:playerAccount.age forKey:@"age"];
        }
        
        NSString *playerHomeTown=[responseObject objectForKey:@"home_town"];
        if (playerHomeTown) {
            playerAccount.homeTown=playerHomeTown;
            [uDef setObject:ValidateObject(playerAccount.homeTown, [NSString class]) forKey:@"homeTown"];
        }
        
        int countFriends=[[responseObject objectForKey:@"friends"] intValue];
        if (countFriends!=playerAccount.friends) {
            playerAccount.friends=countFriends;
            [uDef setInteger:playerAccount.friends forKey:@"friends"];
        }
        
        NSString *facebookName=[responseObject objectForKey:@"facebook_name"];
        if (facebookName) {
            playerAccount.facebookName=facebookName;
            [uDef setObject:ValidateObject(playerAccount.facebookName, [NSString class]) forKey:@"facebook_name"];
        }
        
        BOOL moneyForIPad=[[NSUserDefaults standardUserDefaults] boolForKey:@"moneyForIPad"];
        if (!moneyForIPad && ([[responseObject objectForKey:@"money"] intValue] == 200) && ([playerAccount.accountID rangeOfString:@"F:"].location != NSNotFound)) {
            
            CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trType = [NSNumber numberWithInt:1];
            transaction.trMoneyCh = [NSNumber numberWithInt:100];
            playerAccount.money+=100;
            transaction.trDescription = [[NSString alloc] initWithFormat:@"forIPad"];
            [playerAccount.transactions addObject:transaction];
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSMutableArray *locationData = [[NSMutableArray alloc] init];
            for( CDTransaction *loc in playerAccount.transactions)
            {
                [locationData addObject: [NSKeyedArchiver archivedDataWithRootObject:loc]];
            }
            [def setObject:locationData forKey:@"transactions"];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"moneyForIPad"];
        }

        if (!modifierName) {
            [playerAccount sendTransactions:playerAccount.transactions];
        }
        
        switch ([[LoginViewController sharedInstance] loginFacebookStatus]) {
            case LoginFacebookStatusLevel:
                [LevelCongratViewController newLevelNumber:playerAccount.accountLevel];
                break;
            case LoginFacebookStatusMoney:
                [MoneyCongratViewController achivmentMoney:playerAccount.money];
                break;
            case LoginFacebookStatusInvaitFriends:
                [[OGHelper sharedInstance] getFriendsHowDontUseAppDelegate:nil];
                break;
            default:
                break;
        }
        [[LoginViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusNone];
        
        [uDef synchronize];
    }
    //
    NSDictionary *response= [responseObject objectForKey:@"response"];
    
    //    Refresh
    
    if([response objectForKey:@"refresh"]!=NULL){
        
        return;
    }

    if([response objectForKey:@"nickname"]!=NULL){
        oponentAccount.accountName=[response objectForKey:@"nickname"];
        oponentAccount.money = [[response objectForKey:@"money"] intValue];
        NSString *typeImage=[response objectForKey:@"type"];        
        NSDecimal decimalValue;
        NSScanner *sc = [NSScanner scannerWithString:typeImage];
        [sc scanDecimal:&decimalValue];
        BOOL isDecimal = [sc isAtEnd];
        if(!isDecimal){
            oponentAccount.typeImage=typeImage; 
        }
        NSString *st=[[NSString alloc] initWithFormat:@"%@%@%@",NSLocalizedString(@"BotMTitle", nil),oponentAccount.accountName,NSLocalizedString(@"BotMTitle2", nil)];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:st message:NSLocalizedString(@"BotMText", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"BotMCANS", nil) otherButtonTitles:NSLocalizedString(@"BotMBtn", nil),nil];
        av.tag = BOT_DUEL_TAG;
        [av show];
    }
}

- (void)connection:(CustomNSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString * currentParseString = [NSString stringWithFormat:@"%@",connection.requestURL];
    NSMutableData *receivedData=[dicForRequests objectForKey:[currentParseString lastPathComponent]];
    [receivedData appendData:data];
}

- (void)connection:(CustomNSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // inform the user
    DLog(@"Start Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

#pragma mark -

-(BOOL)isNeedBlockOnlineListForAdvertasingAppear;
{
    BOOL advertisingWillShow=[[NSUserDefaults standardUserDefaults] boolForKey:@"advertisingWillShow"];
        
    int drawCount=playerAccount.accountDraws;
    int playedMatches=playerAccount.accountWins+drawCount;
    
    if ((playedMatches>=2)&&([self connectedToWiFi])) {
        if ((advertisingWillShow)&&(playerAccount.removeAds!=AdColonyAdsStatusRemoved)) {
            [self advertButtonClick];
            return YES;
        }
    }
    return NO;
}

-(BOOL)isAdvertisingOfNewVersionNeedShow;
{
    AdvertisingNewVersionViewController *advertisingNewVersionViewController=[[AdvertisingNewVersionViewController alloc] init];
    if ([advertisingNewVersionViewController isAdvertisingNeed]) {
        [self presentModalViewController:advertisingNewVersionViewController animated:NO];
        return YES;
    }else {
        return NO;
    }
}

-(void)estimateApp;
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *estimateApp=[userDef stringForKey:@"estimateApp"];
    
    int drawCount=playerAccount.accountDraws;
    int playedMatches=playerAccount.accountWins+drawCount;
    
    if (estimateApp && (playedMatches>3)) {
//        [self showFeedbackView];        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"estimateApp"];
        [userDef synchronize];
    }
}

-(void)showProfileFirstRun
{    
    NSString *LoginForIPad=[[NSUserDefaults standardUserDefaults] stringForKey:@"IPad"];
    if (LoginForIPad&&(![[OGHelper sharedInstance] isAuthorized])) {
        LoginViewController *loginViewControllerLocal =[LoginViewController sharedInstance];
        
        loginViewControllerLocal.startViewController = self;
        [self.navigationController pushViewController:loginViewControllerLocal animated:YES];
        firstRunLocal = NO;
    }else {
        if (firstRunLocal) {
            firstRunLocal = NO;
            [self profileButtonClick];
        }
    }
}
#pragma mark 10 dolars for day
-(void)checkFor10Dolars;
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];                ////////////////////////// daily money
    
    NSInteger lastFeedDate = [userDef integerForKey:@"lastDate"];
    NSInteger curentDate = [playerAccount.dateFormatDay integerValue];
    [userDef setInteger:curentDate forKey:@"lastDate"];
    
    if((lastFeedDate != curentDate) && (!firstRunLocal)) {
        [userDef setInteger:[playerAccount.dateFormatDay integerValue] forKey:@"lastDate"];
        
        [self performSelector:@selector(showMessage10Dolars) withObject:self afterDelay:1.0];
        [self performSelector:@selector(hideMessage10Dolars) withObject:self afterDelay:3.8];
        playerAccount.money +=10;
        
        CDTransaction *transaction = [[CDTransaction alloc] init];
        transaction.trMoneyCh = [NSNumber numberWithInt:10];
        
        transaction.trDescription = [[NSString alloc] initWithFormat:@"Daily money"];
        
        int local = [playerAccount.glNumber intValue];
        local++;
        DLog(@"number %d", local);
        playerAccount.glNumber = [NSNumber numberWithInt:local];
        //            transaction.trNumber = [NSNumber numberWithInt:local];
        [playerAccount.transactions addObject:transaction];
        
        NSMutableArray *locationData = [[NSMutableArray alloc] init];
        for( CDTransaction *loc in playerAccount.transactions)
        {
            [locationData addObject: [NSKeyedArchiver archivedDataWithRootObject:loc]];
        }
        [userDef setObject:locationData forKey:@"transactions"];
        
        
        DLog(@"Transactions count = %d", [playerAccount.transactions count]);
        
    };
    [userDef synchronize];

}

-(void)showMessage10Dolars;
{
    v10DolarsForDay=[[UIView alloc] initWithFrame:CGRectMake(12, -40, 290, 40)];

    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 270, 20)];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:18.f]];
    UIColor *brownColor=[UIColor colorWithRed:0.38 green:0.267 blue:0.133 alpha:1];
    [label setTextColor:brownColor];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:NSLocalizedString(@"daily10NoHTML", @"")];
    [v10DolarsForDay addSubview:label];
    
    [self.view addSubview:v10DolarsForDay];
    [v10DolarsForDay setDinamicHeightBackground];
    
    [UIView animateWithDuration:0.6f
                     animations:^{
                         CGRect frame=v10DolarsForDay.frame;
                         frame.origin.y += frame.size.height+5;
                         v10DolarsForDay.frame = frame;
                     }];
}

-(void)hideMessage10Dolars;
{
    [UIView animateWithDuration:0.6f
                     animations:^{
                         CGRect frame=v10DolarsForDay.frame;
                         frame.origin.y -= frame.size.height+5;
                         v10DolarsForDay.frame = frame;
                     }
                     completion:^(BOOL finished) {
						 [v10DolarsForDay removeFromSuperview];
					 }];
    
}

#pragma mark -
-(void)soundOff
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"soundCheack"] == 1) {
        soundCheack = !soundCheack;
        [self playerStop];

        NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        [uDef setInteger:0 forKey:@"soundCheack"];
        [uDef synchronize];
    }
    else
    {
        soundCheack = !soundCheack;
        [self playerStart];

        NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        [uDef setInteger:1 forKey:@"soundCheack"];
        [uDef synchronize];
    }    
}

-(void)playerStart
{
    if  (soundCheack) {
       [self performSelectorInBackground:@selector(volumeInc) withObject:self];
       // player.volume = 1.0f;
        DLog(@"playerStart called!");
    }
}

-(void)playerStop
{
    //player.volume = 0.0f;
    NSNumber *num=[NSNumber numberWithInt:0];
    [self performSelectorInBackground:@selector(volumeDec:) withObject:num];
}

-(void)playerHalf
{
    NSNumber *num=[NSNumber numberWithInt:2];
    if  (soundCheack) [self performSelectorInBackground:@selector(volumeDec:) withObject:num];
    //    [num release];
}

-(void)volumeDec:(NSNumber *)level
{
    int lev=[level intValue];
    for (int i = player.volume * 10; i>=lev; i--) {
        [player setVolume:(float)i/10];
        
        usleep(30000);
    } 
    
}

-(void)volumeInc
{
    
//    for (int i = (int)[player volume] * 10; i <= 10; i++) {
    for (int i = player.volume * 10; i <= 10; i++) {
        
        [player setVolume:(float)i / 10];
        
        usleep(30000);
    } 
    
}

- (NSString *)deviceTypeCode {
    size_t size;
    
    // Set 'oldp' parameter to NULL to get the size of the data
    // returned so we can allocate appropriate amount of space
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    // Allocate the space to store name
    char *name = malloc(size);
    
    // Get the platform name
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    // Place name into a string
    NSString *deviceTypeCode = [NSString stringWithCString:name encoding: NSUTF8StringEncoding];
    
    
    // Done with this
    free(name);
    
    return deviceTypeCode;
}

- (NSString *)deviceType {
    
    NSString *deviceTypeCode=[self deviceTypeCode];
    if ([deviceTypeCode isEqualToString: @"i386"]) {
        return @"iPhone Simulator";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone1,1"]) {
        return @"iPhone";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone1,2"]) {
        return @"iPhone3G";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone2,1"]) {
        return @"iPhone3GS";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone3,1"]) {
        return @"iPhone4";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone3,3"]||
             [deviceTypeCode isEqualToString: @"iPhone3,2"]) {
        return @"iPhone4CDMA";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone4,1"]) {
        return @"iPhone4S";
    }
    else if ([deviceTypeCode isEqualToString: @"iPod1,1"]) {
        return @"iPod1";
    }
    else if ([deviceTypeCode isEqualToString: @"iPod2,1"]) {
        return @"iPod2";
    }
    else if ([deviceTypeCode isEqualToString: @"iPod2,2"]) {
        return @"iPod2.5";
    }
    else if ([deviceTypeCode isEqualToString: @"iPod3,1"]) {
        return @"iPod3";
    }
    else if ([deviceTypeCode isEqualToString: @"iPod4,1"]) {
        return @"iPod4";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad1,1"]) {
        return @"iPad1";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad1,2"]) {
        return @"iPad1GSM";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad2,1"]) {
        return @"iPad2";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad2,2"]) {
        return @"iPad2GSM";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad2,3"]) {
        return @"iPad2CDMA";
    }
    else {
        return deviceTypeCode;
    }
}


-(void)authorizationModifier:(BOOL)pModifierName;
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    if ([playerAccount.accountID length] < 9) [playerAccount verifyAccountID];
    NSString *deviceToken; 
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceToken"]) deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceToken"];
    else deviceToken = @"";
    
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    NSLocale* curentLocale = [NSLocale currentLocale];
    NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:AUTORIZATION_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    [theRequest setHTTPMethod:@"POST"]; 
    
    NSMutableDictionary *dicBody=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  version,@"app_ver",
                                  currentDevice.systemVersion,@"os",
                                  @"12345",@"auth_key",
                                  deviceToken,@"device_token",
                                  [curentLocale localeIdentifier] ,@"region",
                                  [languages objectAtIndex:0] ,@"current_language",
                                  nil];
    
    [dicBody setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceType"] forKey:@"device_name"];
    [dicBody setValue:playerAccount.accountID forKey:@"authentification"];
    modifierName = pModifierName;
    if (modifierName) {
        [dicBody setValue:playerAccount.accountID forKey:@"authen_old"];  
    }else {
        [dicBody setValue:oldAccounId forKey:@"authen_old"];  
    }
    [dicBody setValue:playerAccount.accountName forKey:@"nickname"];  
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerAccount.accountLevel ] forKey:@"level"]; 
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerAccount.accountPoints ] forKey:@"points"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerAccount.accountWins] forKey:@"duels_win"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerAccount.accountDraws] forKey:@"duels_lost"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerAccount.accountBigestWin] forKey:@"bigest_win"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerAccount.removeAds] forKey:@"remove_ads"];
    
    [dicBody setValue:[playerAccount.avatar stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"avatar"];
    [dicBody setValue:[playerAccount.age stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"age"];
    [dicBody setValue:[playerAccount.homeTown stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"home_town"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerAccount.friends] forKey:@"friends"];
    [dicBody setValue:playerAccount.facebookName forKey:@"facebook_name"];

    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    DLog(@"stBody %@",dicBody);
	[theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [dicForRequests setObject:receivedData forKey:[theConnection.requestURL lastPathComponent]];
    } else {
    }
    
    oldAccounId=@"";
    gameCenterViewController = [GameCenterViewController sharedInstance:playerAccount andParentVC:self];
    
    gameCenterViewController.multiplayerServerViewController.neadRestart = YES;
    gameCenterViewController.multiplayerServerViewController.serverNameGlobal = playerAccount.accountID;
    [gameCenterViewController.multiplayerServerViewController shutDownServer];
}

-(void)modifierUser;
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:MODIFIER_USER_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    [theRequest setHTTPMethod:@"POST"]; 
    
    NSMutableDictionary *dicBody=[NSMutableDictionary dictionary];
    [dicBody setValue:playerAccount.accountID forKey:@"authentification"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerAccount.accountLevel ] forKey:@"level"]; 
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerAccount.accountPoints ] forKey:@"points"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerAccount.accountWins] forKey:@"duels_win"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerAccount.accountDraws] forKey:@"duels_lost"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerAccount.accountBigestWin] forKey:@"bigest_win"];
    
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    DLog(@"modifierUser stBody %@",dicBody);
	[theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [dicForRequests setObject:receivedData forKey:[theConnection.requestURL lastPathComponent]];
    } else {
    }    
}


#pragma mark -
#pragma mark protocol GCAuthenticateDelegate 

- (void)setLocalPlayer:(GKLocalPlayer *)player1
{   
    if (playerAccount.accountLevel==1) {
        [[GCHelper sharedInstance] reportAchievementIdentifier:[[GCHelper sharedInstance].GC_ACH objectAtIndex:1] percentComplete:100.0f];
    }
}

-(void)avtorizationFailed
{
    if (avtorizationInProcess) {
        [hudView setHidden:YES];
        [hudView removeFromSuperview];
        //        NSLocalizedString(@"CAN'T CONNECT", @"")
        [avrorizationAlert dismissWithClickedButtonIndex:-1 animated:YES];
        [activityIndicatorView hideView]; 
        avtorizationInProcess = NO;
        [self performSelector:@selector(duelButtonClick) withObject:self afterDelay:5.2];
    }
    
}


-(float)abs:(float)d
{
    if (d<0) return -1.0 * d;
    else return d;
}

#pragma mark - protocol  AccountDataSourceDelegate

- (void)retrieveMessageFromDevice  
{      
    NSString *savePath = getGameCenterSavePath();
    
    // If there are no files saved, return  
    if(![[NSFileManager defaultManager] fileExistsAtPath:savePath]){  
        return;  
    }  
    
    // First get the data  
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:savePath];  
    NSData *data = [dict objectForKey:textArchiveKey];  
    
    // A file exists, but it isn't for the scores key so return  
    if(!data){  
        return;  
    }  
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];  
    NSArray *textArr = [unarchiver decodeObjectForKey:textArchiveKey];  
    [unarchiver finishDecoding];  
    //    [unarchiver release];  
    
    // remove the scores key and save the dictionary back again  
    [dict removeObjectForKey:textArchiveKey];  
    [dict writeToFile:savePath atomically:YES];  
}  

#pragma mark AlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (alertView.tag) {
            
        case ESTIMATE_APP_TAG:
        {
            if (buttonIndex==alertView.cancelButtonIndex) {
                
                [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                                    object:self
                                                                  userInfo:[NSDictionary dictionaryWithObject:@"/estimate_ITunes_CANCEL" forKey:@"event"]];
                
            }else {
                NSURL *url = [NSURL URLWithString:iTunesId];
                
                [[UIApplication sharedApplication] openURL:url];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                                    object:self
                                                                  userInfo:[NSDictionary dictionaryWithObject:@"/estimate_ITunes_OK" forKey:@"event"]];  
            }
        }
            break;
        case PUSH_MES_TAG:
        {
            if(buttonIndex==alertView.cancelButtonIndex  )
            {
                [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];
            }else
            {
                [self startDuel]; 
            }
        }
            break;
        case BOT_DUEL_TAG:
        {
            if(buttonIndex==alertView.cancelButtonIndex  )
            {
                [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];
            }
        }
            break;   
        case CON_GC_TAG:
        {
            [activityIndicatorView setHidden:YES];
            avtorizationInProcess = NO; 
        }
            break;     
            
        default:
            break;
    }
    
}

#pragma mark Notification

- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    internetReachable = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    
    {
        case NotReachable:
        {
            DLog(@"The internet is down.");
            if (self.internetActive) {
                self.internetActive = NO;
            }
            
            
            break;
            
        }
        case ReachableViaWiFi:
        {
            if(!self.internetActive){
                self.internetActive = YES;
            }
            
            break;
            
        }
        case ReachableViaWWAN:
        {
            if(!self.internetActive){
                self.internetActive = YES;
            }
            break;
            
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    
    {
        case NotReachable:
        {
            if (self.hostActive) {
                self.hostActive = NO;
                DLog(@"The internet is down IF.");
            }
            
            
            break;
            
        }
        case ReachableViaWiFi:
        {
            if(!self.hostActive){
                self.hostActive = YES;
                [self login];
            }
            break;
            
        }
        case ReachableViaWWAN:
        {
            if(!self.hostActive){
                self.hostActive = YES;
                [self login];
            }
            
            break;
            
        }
    }
}

#pragma mark Bot Duel

- (void)showAlertBotDuel{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:GET_RANDOM_USER_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [dicForRequests setObject:receivedData forKey:[theConnection.requestURL lastPathComponent]];
    } else {
    }
    
}

#pragma mark FConnect Methods

- (void)request:(FBRequest *)request didLoad:(id)result {
	
    DLog(@"Start VC Facebook response: %@", result);
    
	if ([result isKindOfClass:[NSDictionary class]]) {
        
        oldAccounId = [[NSString alloc] initWithFormat:@"%@",playerAccount.accountID];
        
		NSString *userId = [NSString stringWithFormat:@"F:%@", ValidateObject([result objectForKey:@"id"], [NSString class])];
        playerAccount.accountID=userId;
		NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        NSString *playerName=[NSString stringWithFormat:@"%@", ValidateObject([result objectForKey:@"name"], [NSString class])];
                
        if ([playerAccount.accountName isEqualToString:@"Anonymous"]||[playerAccount.accountName isEqualToString:@""]||!playerAccount.accountName) {
            [playerAccount setAccountName:playerName];  
        } 
        playerAccount.facebookName=playerName;
        playerAccount.avatar=[NSString stringWithFormat:@"%@", ValidateObject([result objectForKey:@"picture"], [NSString class])];
        playerAccount.age=[NSString stringWithFormat:@"%@", ValidateObject([result objectForKey:@"birthday"], [NSString class])];
        
        NSDictionary *town=ValidateObject([result objectForKey:@"location"], [NSDictionary class]);
        playerAccount.homeTown=[NSString stringWithFormat:@"%@", ValidateObject([town objectForKey:@"name"], [NSString class])];
        

        
        [uDef setObject:ValidateObject(playerAccount.age, [NSString class]) forKey:@"age"];
        [uDef setObject:ValidateObject(playerAccount.homeTown, [NSString class]) forKey:@"homeTown"];
        [uDef setObject:ValidateObject(playerAccount.facebookName, [NSString class]) forKey:@"facebook_name"];
        
        [uDef setObject:ValidateObject(playerAccount.accountID, [NSString class]) forKey:@"id"];
        
        [uDef setObject:ValidateObject(playerAccount.accountName, [NSString class]) forKey:@"name"];
            
        [uDef synchronize];
        
        [self authorizationModifier:NO];
    }

}

- (void)dealloc {
//    [super dealloc];
}

@end
