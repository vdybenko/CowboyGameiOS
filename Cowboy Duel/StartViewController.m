//
//
//  StartViewController.m
//  Test
//
//  Created by Sobol on 20.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StartViewController.h"
#import "UIView+Hierarchy.h"
#import "UIButton+Image+Title.h"
#import "AdvertisingNewVersionViewController.h"
#import "AdvertisingAppearController.h"
#import "ListOfItemsViewController.h"
#import "CustomNSURLConnection.h"
#import "GameCenterViewController.h"
#import "Utils.h"
#import "LevelCongratViewController.h"
#import "MoneyCongratViewController.h"
#import "AdvertisingNewViewController.h"
#import "TopPlayersViewController.h"

#import "Social/Social.h"
#import "accounts/Accounts.h"

#import "StoreViewController.h"
#import "DuelProductWinViewController.h"

#import "FunPageViewController.h"
#import "ActiveDuelViewController.h"

#define kTwitterSettingsButtonIndex 0

@interface StartViewController ()
{
    AccountDataSource *playerAccount;
    ActivityIndicatorView *activityIndicatorView;
    CollectionAppViewController *collectionAppViewController;
    ListOfItemsViewController *listOfItemsViewController;
    ProfileViewController *profileViewController;
    
//    BOOL firstRun;
    BOOL firstRunLocal;
    BOOL firstDayWithOutAdvertising;
    
    AVAudioPlayer *player;
    
    UIView *v10DolarsForDay;
    
    BOOL soundCheack;
    
    BOOL avtorizationInProcess;
    
    BOOL internetActive;
    BOOL hostActive;
    
    BOOL feedBackViewVisible;
    BOOL shareViewVisible;
    
    BOOL isPushMessageShow;
    
    Reachability* internetReachable;
    Reachability* hostReachable;
    
    UIImageView_AttachedView *arrowImage;
    
    NSString *oldAccounId;
    
    NSMutableDictionary *dicForRequests;
    BOOL modifierName;
    //buttons
    __weak IBOutlet UIButton *duelButton;
    __weak IBOutlet UIButton *mapButton;
    __weak IBOutlet UIButton *profileButton;
    __weak IBOutlet UIButton *feedbackButton;
    __weak IBOutlet UIButton *shareButton;
    __weak IBOutlet UIButton *helpButton;
    __weak IBOutlet UIButton *soundButton;
    __weak IBOutlet UIButton *saloon2Button;
    
    __weak IBOutlet UIView *feedbackView;
    __weak IBOutlet UIView *shareView;
  
    __weak IBOutlet UIImageView *backGroundfeedbackView;
    __weak IBOutlet UIActivityIndicatorView *indicatorfeedbackView;
  
    __weak IBOutlet UILabel *lbFeedbackButton;
    __weak IBOutlet UILabel *lbShareButton;
  
    __weak IBOutlet UILabel *lbFollowFacebook;
    __weak IBOutlet UILabel *lbPostMessage;
    __weak IBOutlet UILabel *lbMailMessage;
    __weak IBOutlet UILabel *lbRateMessage;
    __weak IBOutlet UILabel *lbFeedbackCancelBtn;
    __weak IBOutlet UILabel *lbShareCancelBtn;

    //Cloud
    __weak IBOutlet UIImageView *cloudView;
    __weak IBOutlet UIImageView *cloudSecondView;
    int cloudX;
    int cloud2X;
    BOOL animationCheck;
    BOOL inBackground;
}
@property (weak, nonatomic) IBOutlet UIButton *duelButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorfeedbackView;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundfeedbackView;

@property (strong) GameCenterViewController *gameCenterViewController;

@property (strong,nonatomic) AVAudioPlayer *player;

@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL hostActive;

@property (strong, nonatomic) AdvertisingNewVersionViewController *advertisingNewVersionViewController;
-(void)sendRequestWithDonateSum:(int)sum;
- (NSString *)deviceType;
-(void)arrowAnimation;

@end

#define BOT_DUEL_TAG 3

#define iTunesId @"http://cowboyduel.mobi/r/"

// http://itunes.apple.com/ua/app/platforma/id525730690?mt=8

@implementation StartViewController

@synthesize gameCenterViewController, player, internetActive, hostActive, soundCheack;
@synthesize feedbackButton, duelButton, profileButton, helpButton, mapButton, shareButton;
@synthesize oldAccounId,feedBackViewVisible,showFeedAtFirst,topPlayersDataSource, advertisingNewVersionViewController,firstRun, favsDataSource;
@synthesize duelProductDownloaderController;
@synthesize pushNotification;

static const char *REGISTRATION_URL =  BASE_URL"api/registration";
static const char *AUTORIZATION_URL =  BASE_URL"api/authorization";
static const char *MODIFIER_USER_URL =  BASE_URL"users/set_user_data";
static const char *PUSH_NOTIF_URL = BASE_URL"api/push";

NSString *const URL_FB_PAGE=@"http://cowboyduel.mobi/";



NSMutableData *receivedDataBots;

#pragma mark

static StartViewController *sharedHelper = nil;
+ (StartViewController *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[StartViewController alloc] init];
    }
    return sharedHelper;
}

-(id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
         NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        playerAccount = [AccountDataSource sharedInstance];
          
        showFeedAtFirst=NO;
        
        topPlayersDataSource = [[TopPlayersDataSource alloc] initWithTable:nil];
        
        firstDayWithOutAdvertising=YES;
        if(![uDef boolForKey:@"AlreadyRun"] )  
        {
            firstRun = YES;
            firstRunLocal = YES;
            
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"estimateApp"];
            NSInteger kFrequencyOfAdvertising = [[NSUserDefaults standardUserDefaults] integerForKey:@"kFrequencyOfAdvertising"];
            if (kFrequencyOfAdvertising==0) {
                [[NSUserDefaults standardUserDefaults] setInteger:kFrequencyOfAdvertisingDefault forKey:@"kFrequencyOfAdvertising"];
            }
        }
        else 
        {
            firstRun = NO;
            firstRunLocal = NO;
            [topPlayersDataSource reloadDataSource];
            [favsDataSource reloadDataSource];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"moneyForIPad"];
        }
        
        if(firstRun)DLog(@"First ");
        
        if(firstRun){
            
            [uDef setBool:TRUE forKey:@"FirstRunForDuel"];
            [playerAccount saveMoney];
            [playerAccount saveAccountName];
            [playerAccount saveID];
            [playerAccount saveDeviceType];
            [playerAccount saveAccountLevel];
            [playerAccount saveAccountPoints];
            [playerAccount saveAccountWins];
            [playerAccount saveAccountDraws];
            [playerAccount saveAccountBigestWin];
            [playerAccount saveRemoveAds];
            [playerAccount saveAvatar];
            [playerAccount saveAge];
            [playerAccount saveHomeTown];
            [playerAccount saveFriends];
            [playerAccount saveFacebookName];
            [playerAccount saveWeapon];
            [playerAccount saveDefense];
            [playerAccount saveTransaction];
            [playerAccount saveGlNumber];
            [uDef synchronize];
        }else{
            
            [uDef setBool:FALSE forKey:@"FirstRunForDuel"];
            [uDef setInteger:2 forKey:@"FirstRunForPractice"];
            
            [playerAccount loadAllParametrs];
            
//            
            if (!([playerAccount.accountID rangeOfString:@"F"].location == NSNotFound)){ 
                //facebook = [[Facebook alloc] initWithAppId:kFacebookAppId andDelegate:[LoginAnimatedViewController sharedInstance]];
                
                if ([uDef objectForKey:@"FBAccessTokenKey"] 
                    && [uDef objectForKey:@"FBExpirationDateKey"]) {
                    //facebook.accessToken = [uDef objectForKey:@"FBAccessTokenKey"];
                    //facebook.expirationDate = [uDef objectForKey:@"FBExpirationDateKey"];
                }
                
                [[OGHelper sharedInstance] initWithAccount:playerAccount];
            }
            
            DLog(@"Transactions count = %d", [playerAccount.transactions count]);
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"transactions"];

            NSArray *oldLocations = [uDef arrayForKey:@"transactions"];
            if( [oldLocations count]!=0)
            {
                for( NSData *data in oldLocations )
                {
                    CDTransaction * loc = (CDTransaction*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    [playerAccount.transactions addObject:loc];
                }
            }
          DLog(@"Transactions count = %d", [playerAccount.transactions count]);
            
            NSArray *oldLocations2 = [uDef arrayForKey:@"duels"];
            if( playerAccount.duels )
            {
                for( NSData *data in oldLocations2 )
                {
                    CDDuel * loc = (CDDuel*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
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
        }
        favsDataSource = [[FavouritesDataSource alloc] initWithTable:nil];
        
        dicForRequests=[[NSMutableDictionary alloc] init];
        
        gameCenterViewController = [GameCenterViewController sharedInstance:playerAccount andParentVC:self];
        listOfItemsViewController=[[ListOfItemsViewController alloc]initWithGCVC:gameCenterViewController Account:playerAccount OnLine:self.hostActive];
        duelProductDownloaderController = [[DuelProductDownloaderController alloc] init];
        duelProductDownloaderController.delegate = self;
        
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newMessageRecived:)
                                                     name:kPushNotification
                                                   object:nil];
                
        activityIndicatorView = [[ActivityIndicatorView alloc] initWithoutRotate];
        CGRect imgFrame = activityIndicatorView.frame;
        imgFrame.origin = CGPointMake(0, 0);
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
        
        hostReachable = [Reachability reachabilityWithHostName: @"www.apple.com"];
        [hostReachable startNotifier];

        if (![GCHelper sharedInstance].GClocalPlayer.isAuthenticated && ![self firstRun]) {
            [[GCHelper sharedInstance] authenticateLocalUser];
        }
        
        oldAccounId = @"";
        
        cloudX=460;
        cloud2X=-20;
        
        inBackground = NO;
        isPushMessageShow = NO;
    }
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    int iPhone5Delta = [UIScreen mainScreen].bounds.size.height - 480;
  
    UIColor *buttonsTitleColor = [[UIColor alloc] initWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    [lbFeedbackButton setText:NSLocalizedString(@"Feedback", @"")];
    [lbFeedbackButton setTextColor:buttonsTitleColor];
    [lbFeedbackButton setFont:[UIFont fontWithName: @"MyriadPro-Semibold" size:15]];
    
    [lbShareButton setText:NSLocalizedString(@"Share", @"")];
    [lbShareButton setTextColor:buttonsTitleColor];
    [lbShareButton setFont:[UIFont fontWithName: @"MyriadPro-Semibold" size:15]];
/*
    [duelButton setTitle:NSLocalizedString(@"Saloon", @"") forState:UIControlStateNormal];
    [duelButton setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    duelButton.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    duelButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [saloon2Button setTitle:NSLocalizedString(@"Saloon2", @"") forState:UIControlStateNormal];
    [saloon2Button setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    saloon2Button.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    saloon2Button.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [profileButton setTitle:NSLocalizedString(@"Profile", @"") forState:UIControlStateNormal];
    [profileButton setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    profileButton.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    profileButton.titleLabel.textAlignment = UITextAlignmentCenter;

    [helpButton setTitle:NSLocalizedString(@"HelpTitle", @"") forState:UIControlStateNormal];
    [helpButton setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    helpButton.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    helpButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [mapButton setTitle:NSLocalizedString(@"STORE", @"") forState:UIControlStateNormal];
    [mapButton setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    mapButton.titleLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    mapButton.titleLabel.textAlignment = UITextAlignmentCenter;
*/    
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
  
    lbFollowFacebook.text = NSLocalizedString(@"Follow", nil);
    
    lbFeedbackCancelBtn.text = NSLocalizedString(@"CancelButtonTitle", nil);
    lbFeedbackCancelBtn.textColor = buttonsTitleColor;
    lbFeedbackCancelBtn.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
  
    lbShareCancelBtn.text = NSLocalizedString(@"CancelButtonTitle", nil);
    lbShareCancelBtn.textColor = buttonsTitleColor;
    lbShareCancelBtn.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
  
  
    feedBackViewVisible=NO;
    shareViewVisible = NO;
  
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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger loginFirstShow = [userDefaults integerForKey:@"loginFirstShow"];
    
    if (!loginFirstShow) {
        SSConnection *connection = [SSConnection sharedInstance];
        [connection sendData:@"" packetID:NETWORK_SET_UNAVIBLE ofLength:sizeof(int)];
        
        LoginAnimatedViewController *loginViewControllerLocal = [LoginAnimatedViewController sharedInstance];
        loginViewControllerLocal.startViewController = self;
        [loginViewControllerLocal setPayment:YES];
        [self.navigationController pushViewController:loginViewControllerLocal animated:YES];
        loginViewControllerLocal = nil;
    }

    if (self.soundCheack )
        [soundButton setImage:[UIImage imageNamed:@"pv_btn_music_on.png"] forState:UIControlStateNormal];
    else {
        [soundButton setImage:[UIImage imageNamed:@"pv_btn_music_off.png"] forState:UIControlStateNormal];
    }
    
    CGAffineTransform transform = CGAffineTransformMakeScale(-1, 1);
    cloudView.transform = transform;
    
    //Push  notifications
    NSDictionary *sInfo = [pushNotification objectForKey:@"aps"];
    NSString *message = [sInfo objectForKey:@"alert"];
    
    sInfo = [pushNotification objectForKey:@"i"];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kPushNotification
														object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:sInfo, @"messageId",message, @"message", nil]];
//    deltas for 5 iPhone
    if (iPhone5Delta>0) {
        iPhone5Delta = 25;
        
        CGRect frame = duelButton.frame;
        frame.origin.y += iPhone5Delta;
        [duelButton setFrame:frame];
        
        frame = saloon2Button.frame;
        frame.origin.y += iPhone5Delta;
        [saloon2Button setFrame:frame];
        
        frame = mapButton.frame;
        frame.origin.y += iPhone5Delta;
        [mapButton setFrame:frame];
        
        frame = profileButton.frame;
        frame.origin.y += iPhone5Delta;
        [profileButton setFrame:frame];
        
        frame = helpButton.frame;
        frame.origin.y += iPhone5Delta;
        [helpButton setFrame:frame];

    }
}
- (void)viewDidUnload {
    feedbackView = nil;
    lbPostMessage = nil;
    lbMailMessage = nil;
    lbRateMessage = nil;
    lbFeedbackCancelBtn = nil;
    shareButton = nil;
    shareView = nil;
    lbFollowFacebook = nil;
    lbShareCancelBtn = nil;
    lbFeedbackButton = nil;
    lbShareButton = nil;
    saloon2Button = nil;
    [super viewDidUnload];
}
    
-(void)viewWillAppear:(BOOL)animated
{   
    [super viewWillAppear:animated];

    [self playerStart];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FirstRun_v2.2"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstRun_v2.2"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstRunForStore_v2.2"];
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FirstRunForStore_v2.2"])
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstRunForStore_v2.2"];
            
        }
    }
        

    
    if (firstRun) {
        firstRun = NO;
        return;
    }
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName: @"www.apple.com"];
    [hostReachable startNotifier];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
       
    TestAppDelegate *app = (TestAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.adBanner setHidden:NO];
    app.clouds.hidden = YES;
    
    if (!inBackground) {
         animationCheck = YES;
        [self cloudAnimation];
        [self cloudSecondAnimation];
        cloudView.hidden = NO;
        cloudSecondView.hidden = NO;
    }
    inBackground = NO;

    SSConnection *connection = [SSConnection sharedInstance];
    [connection networkCommunicationWithPort:MASTER_SERVER_PORT andIp:MASTER_SERVER_IP];
    
    gameCenterViewController.duelStartViewController = nil;
    
    [self showProfileFirstRun];
    [self isAdvertisingOfNewVersionNeedShow];
    [self estimateApp];    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    TestAppDelegate *app = (TestAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.adBanner setHidden:YES];
    app.clouds.hidden = NO;
    
    cloudView.hidden = YES;
    cloudSecondView.hidden = YES;
    animationCheck = NO;
    
    cloudX=460;
    cloud2X=-20;
    
    CGRect frame = cloudView.frame;
    frame.origin.x = cloudX;
    cloudView.frame = frame;
    
    frame = cloudSecondView.frame;
    frame.origin.x = cloud2X;
    cloudSecondView.frame = frame;
    
    if(feedBackViewVisible){
      CGRect frame = feedbackView.frame;
      frame.origin.y = [UIScreen mainScreen].bounds.size.height;
      feedbackView.frame = frame;
      feedBackViewVisible = NO;
    }
    if (shareViewVisible) {
      CGRect frame = shareView.frame;
      frame.origin.y = [UIScreen mainScreen].bounds.size.height;
      shareView.frame = frame;
      shareViewVisible = NO;
    }
    
    isPushMessageShow = NO;
}

-(void)didBecomeActive
{
    DLog(@"did become active");
    SSConnection *connection = [SSConnection sharedInstance];
    [connection networkCommunicationWithPort:MASTER_SERVER_PORT andIp:MASTER_SERVER_IP];
    
    if (!firstRunLocal) {
        [self login];
    }
    
    //[facebook extendAccessTokenIfNeeded];
    if (profileViewController) {
        [profileViewController checkValidBlackActivity];
    }
    firstDayWithOutAdvertising=[AdvertisingAppearController advertisingCheckForAppearWithFirstDayWithOutAdvertising:firstDayWithOutAdvertising];
    
    if ((inBackground)&&[self isViewLoaded]) {
        animationCheck = YES;
        [self cloudAnimation];
        [self cloudSecondAnimation];
        cloudView.hidden = NO;
        cloudSecondView.hidden = NO;
    }
}

-(void)didEnterBackground
{
    [[SSConnection sharedInstance] disconnect];
    animationCheck = NO;
    inBackground = YES;
    
    cloudX=460;
    cloud2X=-20;
    
    CGRect frame = cloudView.frame;
    frame.origin.x = cloudX;
    cloudView.frame = frame;
    
    frame = cloudSecondView.frame;
    frame.origin.x = cloud2X;
    cloudSecondView.frame = frame;
}

-(void)didFinishLaunching
{
    NSString *filePath = [[OGHelper sharedInstance] getSavePathForList];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSError *error= nil;
    if ([fileMgr removeItemAtPath:filePath error:&error] != YES){
        DLog(@"TestAppDelegate: Unable to delete file: %@", [error localizedDescription]);
        
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
    
    filePath = [DuelProductDownloaderController getSavePathForDuelProduct];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
}

#pragma mark - IBAction main buttons

-(IBAction)startDuel
{
    [self checkNetworkStatus:nil];
    
    if (![self isNeedBlockOnlineListForAdvertasingAppear]) {
        //play duel
        [self duelButtonClick];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/saloon_click" forKey:@"event"]];
    }
}

-(void)duelButtonClick
{
    [playerAccount setActiveDuel:NO];
    [listOfItemsViewController setStatusOnLine:self.hostActive];
    if (self.navigationController.visibleViewController != listOfItemsViewController) {
        [self.navigationController pushViewController:listOfItemsViewController animated:YES];
    }
}

- (IBAction)storeButtonClick:(id)sender {
    StoreViewController *storeViewController=[[StoreViewController alloc] initWithAccount:playerAccount];
    [self.navigationController pushViewController:storeViewController animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/store" forKey:@"event"]];
    storeViewController = nil;
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
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/profile_click" forKey:@"event"]];
}


- (IBAction)startActiveDuel:(id)sender {
    [playerAccount setActiveDuel:YES];
    [listOfItemsViewController setStatusOnLine:self.hostActive];
    if (self.navigationController.visibleViewController != listOfItemsViewController) {
        [self.navigationController pushViewController:listOfItemsViewController animated:YES];
    }
    
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

-(void)profileFirstRunButtonClickWithOutAnimation;
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstRun_v2.2"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    animationCheck = NO;
    
    cloudX=460;
    cloud2X=-20;
    
    CGRect frame = cloudView.frame;
    frame.origin.x = cloudX;
    cloudView.frame = frame;
    
    frame = cloudSecondView.frame;
    frame.origin.x = cloud2X;
    cloudSecondView.frame = frame;
    
    UIViewController *topController=[self.navigationController topViewController];
    if (![topController isKindOfClass:[ProfileViewController class]]) {
        profileViewController = [[ProfileViewController alloc] initFirstStartWithAccount:playerAccount startViewController:self];
        [self.navigationController pushViewController:profileViewController animated:NO];
    }
}

- (void) showFeedbackView {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES]; 
	[UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
    [UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
    CGRect frame = feedbackView.frame;
    int delta = 0;
    if ([[UIScreen mainScreen] bounds].size.height > 480) delta = 50;
    frame.origin.y = [[UIScreen mainScreen] bounds].size.height - feedbackView.frame.size.height - delta;
    feedbackView.frame = frame;
    
    [UIView commitAnimations];
    
    feedBackViewVisible=YES;
}

- (void) showView: (UIView *)view
{
    int delta = 0;
    TestAppDelegate *app = (TestAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (app.adBanner) delta = 50;
    
  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction animations:^{
                        CGRect frame = view.frame;
                        frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height - delta;
                        view.frame = frame;
                      } completion:^(BOOL finished) {
                        ///
                      }];
}

- (void) hideView: (UIView *)view
{
  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction animations:^{
                        CGRect frame = view.frame;
                        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
                        view.frame = frame;
                      } completion:^(BOOL finished) {
                        ///
                      }];
}

-(IBAction)showHelp:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/help_click" forKey:@"event"]];
    
    HelpViewController *helpViewController = [[HelpViewController alloc] initWithStartVC:self];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; 
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:helpViewController animated:NO];
    helpViewController = nil;
}

-(void) advertButtonClick {
    //AdColonyViewController *adColonyViewController = [[AdColonyViewController alloc]initWithStartVC:self];
    SSConnection *connection = [SSConnection sharedInstance];
    [connection sendData:@"" packetID:NETWORK_SET_UNAVIBLE ofLength:sizeof(int)];
    //[self presentModalViewController:adColonyViewController animated:YES];
}
- (IBAction)soundButtonClick:(id)sender {
    [self soundOff];
    if (self.soundCheack){
        [soundButton setImage:[UIImage imageNamed:@"pv_btn_music_on.png"] forState:UIControlStateNormal];
    }else {
        [soundButton setImage:[UIImage imageNamed:@"pv_btn_music_off.png"] forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark feedback

- (IBAction)feedbackButtonClick:(id)sender {
    [self showView:feedbackView];
    feedBackViewVisible = YES;
  
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/feedBack_click" forKey:@"event"]];
}

- (IBAction)feedbackCancelButtonClick:(id)sender {
  [self hideView:feedbackView];
  feedBackViewVisible = NO;
  [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:@"/feedBack_cancel" forKey:@"event"]];

}
- (IBAction)feedbackFollowFBClick:(id)sender {
//  NSString *URL=[[NSString alloc]initWithFormat:@"https://twitter.com/intent/tweet?source=webclient&text=%@ %@",
//                 @"I'm playing in Cowboy duels",
//                 URL_FB_PAGE];
  
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[URL_COMM_FB_PAGE stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    FunPageViewController *funPageViewController = [[FunPageViewController alloc] initWithAddress:URL_COMM_FB_PAGE];

    
//    CATransition* transition = [CATransition animation];
//    transition.duration = 0.5;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    transition.type = kCATransition;
//    transition.subtype = kCATransitionFromBottom;
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
//    [self.navigationController pushViewController:funPageViewController animated:NO];
    
    funPageViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:funPageViewController animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:@"/feedBack_followFB_clicked" forKey:@"event"]];
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

#pragma mark - push notification

- (void)newMessageRecived:(NSNotification *)notification {
    
    NSString *message;
    int messageID;
    NSDictionary *messageHeader;
    
    message = [[notification userInfo] objectForKey:@"message"];
    messageHeader = [[notification userInfo] objectForKey:@"messageId"];
    
    messageID = [[messageHeader objectForKey:@"t"] intValue];
    NSLog(@"messageID %d",messageID);
    UIViewController *visibleViewController=[self.navigationController visibleViewController];
    if ([visibleViewController isKindOfClass:[ProfileViewController class]] ||
        [visibleViewController isKindOfClass:[StartViewController class]] ||
        [visibleViewController isKindOfClass:[HelpViewController class]] ||
        [visibleViewController isKindOfClass:[TopPlayersViewController class]])
    {
        switch (messageID) {
            case PUSH_NOTIFICATION_POKE:{
//                Фаворит викликає тебе на бій
            }
                break;
            case PUSH_NOTIFICATION_FAV_ONLINE:{
//                Фаворит зайшов онлайн.
                if (!isPushMessageShow) {
                    isPushMessageShow = YES;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"BE_READY", @"") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"CAN_SMALL", @"") otherButtonTitles:NSLocalizedString(@"Saloon2", @""), nil];
                    alert.tag = 1;
                    [alert show];
                    alert = nil;
                }
            }
                break;
            case PUSH_NOTIFICATION_UPDATE_CONTENT:{
//                обновити внутрішній контент
                RefreshContentDataController *refreshContentDataController=[[RefreshContentDataController alloc] init];
                [refreshContentDataController refreshContent];
            }
                break;
            case PUSH_NOTIFICATION_UPDATE_PRODUCTS:{
//                обновити продукти.
                [duelProductDownloaderController refreshDuelProducts];
            }
                break;
            default:
                break;
        }
    }
}

-(void)sendMessageForPush:(NSString *)message withType:(TypeOfPushNotification)type forPlayer:(NSString *)nick withId:(NSString *)playerId ;
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:PUSH_NOTIF_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    [theRequest setHTTPMethod:@"POST"];
    NSDictionary *dicBody= [[NSMutableDictionary alloc] init];
    [dicBody setValue:playerId forKey:@"authen"];
    [dicBody setValue:message forKey:@"message"];
    [dicBody setValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [dicBody setValue:nick forKey:@"nick"];
    [dicBody setValue:playerAccount.accountID forKey:@"id"];
    
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]];
        
    [NSURLConnection sendAsynchronousRequest:theRequest
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *err) {
//                               NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                               NSLog(@"jsonString %@",jsonString);
                           }];
    
}

#pragma mark - Share

- (IBAction)shareButtonClick:(id)sender {
  [self showView:shareView];
  shareViewVisible = YES;
  [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:@"/share_click" forKey:@"event"]];
}
- (IBAction)shareCancelButtonClick:(id)sender {
  [self hideView:shareView];
  shareViewVisible = NO;
  [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:@"/share_cancel" forKey:@"event"]];
  
}

- (IBAction)feedbackFacebookBtnClick:(id)sender {
        
    float ver_float = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver_float >= 6.0) {
        BOOL displayedNativeDialog =
        [FBNativeDialogs
         presentShareDialogModallyFrom:self
         initialText:@"Get Started"
         image:[UIImage imageNamed:@"Icon@2x.png"]
         url:[NSURL URLWithString:URL_APP_ESTIMATE]
         handler:^(FBNativeDialogResult result, NSError *error) {
             if (error) {
                 /* handle failure */
             } else {
                 if (result == FBNativeDialogResultSucceeded) {
                     /* handle success */
                 } else {
                     /* handle user cancel */
                 }
             }
         }];
        if (!displayedNativeDialog) {
            /* handle fallback to native dialog  */
        }

    }else{
        if ([[OGHelper sharedInstance]isAuthorized]) {
            [[OGHelper sharedInstance] apiDialogFeedUser];
        }else {
            [[LoginAnimatedViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusFeed];
            [[LoginAnimatedViewController sharedInstance] loginButtonClick:self];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/feedBack_Facebook_click" forKey:@"event"]];
}

- (IBAction)feedbackTweeterBtnClick:(id)sender {
    if ([TWTweetComposeViewController canSendTweet])
    {
        TWTweetComposeViewController *tweetSheet = 
        [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:@"I'm playing in Cowboy duels"];
        [tweetSheet addImage:[UIImage imageNamed:@"Icon@2x.png"]];
        [tweetSheet addURL:[NSURL URLWithString:URL_FB_PAGE]];
        
	    [self presentModalViewController:tweetSheet animated:YES];
    }
    else
    {
        float ver_float = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (ver_float < 5.0) {
            NSString *URL=[[NSString alloc]initWithFormat:@"https://twitter.com/intent/tweet?source=webclient&text=%@ %@",
                           @"I'm playing in Cowboy duels",
                           URL_FB_PAGE];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", @"AlertView")
                    message:NSLocalizedString(@"You can't send a tweet right now, make sure  your device has an internet connection and you have at least one Twitter account setup", @"AlertView")
                    delegate:self
                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"AlertView")
                    otherButtonTitles:NSLocalizedString(@"Open settings", @"AlertView"), nil];
            alertView.tag = 2;
            [alertView show];
            alertView = nil;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                    object:self
                                                  userInfo:[NSDictionary dictionaryWithObject:@"/share_Tweeter_click" forKey:@"event"]];
}

- (IBAction)feedbackMailBtnClick:(id)sender {
//
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:NSLocalizedString(@"Awesome cowboy duel", @"")];
        
        // Fill out the email body text
        NSString *emailBody = NSLocalizedString(@"Mes text", @"");
        
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentModalViewController:picker animated:YES];
      //    [picker release];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailTitle", @"AlertView")
                                                            message:NSLocalizedString(@"EmailText", @"AlertView")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"AlertView")
                                                  otherButtonTitles: nil];
        alertView.tag = 0;
        [alertView show];
        alertView = nil;
    }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:@"/share_Mail_click" forKey:@"event"]];
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

#pragma mark - Login/Logout

-(void)login
{    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:AUTORIZATION_URL encoding:NSUTF8StringEncoding]]
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

#pragma mark - CustomNSURLConnection handlers

- (void)connectionDidFinishLoading:(CustomNSURLConnection *)connection1 {
    NSString * currentParseString = [NSString stringWithFormat:@"%@",connection1.requestURL];
    
    NSMutableData *receivedData=[dicForRequests objectForKey:[currentParseString lastPathComponent]];
    if ([receivedData length] == 0) {
        return;
    }
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    [dicForRequests removeObjectForKey:[currentParseString lastPathComponent]];
    NSDictionary *responseObject = ValidateObject([jsonString JSONValue], [NSDictionary class]);

    DLog(@"StartVC \n jsonValues %@\n string %@",jsonString,currentParseString);
//    
//    OnLine
    if ([[currentParseString lastPathComponent] isEqualToString:@"authorization"]&&[responseObject objectForKey:@"session_id"]) {
        playerAccount.sessionID =[[NSString alloc] initWithString:[responseObject objectForKey:@"session_id"]];
        int revisionNumber=[[responseObject objectForKey:@"refresh_content"] intValue];
        if ([RefreshContentDataController isRefreshEvailable:revisionNumber]) {
            RefreshContentDataController *refreshContentDataController=[[RefreshContentDataController alloc] init];
            [refreshContentDataController refreshContent];
        }
        
        int revisionProductListNumber=[[responseObject objectForKey:@"v_of_store_list"] intValue];
        if ([DuelProductDownloaderController isRefreshEvailable:revisionProductListNumber]) {
            [duelProductDownloaderController refreshDuelProducts];
        }
        return;
    }       
    //avtorization
    if ((playerAccount.accountID != nil) && [[currentParseString lastPathComponent] isEqualToString:@"registration"]) {
        
        DLog(@"avtorization /n %@",responseObject);
        
        NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        if ([responseObject objectForKey:@"session_id"]) {
            playerAccount.sessionID=[responseObject objectForKey:@"session_id"];
        }
        
        if ([[responseObject objectForKey:@"level"] intValue]!=playerAccount.accountLevel) {
            playerAccount.accountLevel=[[responseObject objectForKey:@"level"] intValue];
            [playerAccount saveAccountLevel];
            [[GCHelper sharedInstance] reportAchievementIdentifier:[[GCHelper sharedInstance].GC_ACH objectAtIndex:playerAccount.accountLevel] percentComplete:100.0f];
        }
        
        NSString *nameFromServer=[responseObject objectForKey:@"name"];
        if (nameFromServer) {
            playerAccount.accountName=nameFromServer;
            [playerAccount saveAccountName];
        }
        
        if ([[responseObject objectForKey:@"points"] intValue]!=playerAccount.accountPoints) {
            playerAccount.accountPoints=[[responseObject objectForKey:@"points"] intValue];
            [playerAccount accountPoints];
        }
        int duelsWin=[[responseObject objectForKey:@"duels_win"] intValue];
        if (duelsWin!=playerAccount.accountWins) {
            playerAccount.accountWins=duelsWin;
            [playerAccount saveAccountWins];
        }
        
        int duelsLost=[[responseObject objectForKey:@"duels_lost"] intValue];
        if (duelsLost!=playerAccount.accountDraws) {
            playerAccount.accountDraws=duelsLost;
            [playerAccount saveAccountDraws];
        }
        
        int bigestWin=[[responseObject objectForKey:@"bigest_win"] intValue];
        if (bigestWin!=playerAccount.accountBigestWin) {
            playerAccount.accountBigestWin=bigestWin;
            [playerAccount saveAccountBigestWin];
        }
        
//        if (playerAccount.removeAds!=AdColonyAdsStatusRemoved) {
//            int removeAds=[[responseObject objectForKey:@"remove_ads"] intValue];
//            playerAccount.removeAds=removeAds;
//            [playerAccount saveRemoveAds];
//        }

        NSString *urlAvatar=[responseObject objectForKey:@"avatar"];
        if ([playerAccount isAvatarImage:urlAvatar]) {
            playerAccount.avatar=urlAvatar;
            [playerAccount saveAvatar];
        }
        
        NSString *playerAge=[responseObject objectForKey:@"age"];
        if (playerAge) {
            playerAccount.age=playerAge;
            [playerAccount saveAge];
        }
        
        NSString *playerHomeTown=[responseObject objectForKey:@"home_town"];
        if (playerHomeTown) {
            playerAccount.homeTown=playerHomeTown;
            [playerAccount saveHomeTown];
        }
        
        int countFriends=[[responseObject objectForKey:@"friends"] intValue];
        if (countFriends!=playerAccount.friends) {
            playerAccount.friends=countFriends;
            [playerAccount saveFriends];
        }
        
        NSString *facebookName=[responseObject objectForKey:@"facebook_name"];
        if (facebookName) {
            playerAccount.facebookName=facebookName;
            [playerAccount saveFacebookName];
        }
        
        int playerMoney=[[responseObject objectForKey:@"money"] intValue];
        if (playerMoney) {
            playerAccount.money=(playerMoney > 0) ? playerMoney : 0;
            [playerAccount saveMoney];
        }
        
        BOOL moneyForIPad=[[NSUserDefaults standardUserDefaults] boolForKey:@"moneyForIPad"];
        if (!moneyForIPad && ([[responseObject objectForKey:@"money"] intValue] == 200) && ([playerAccount.accountID rangeOfString:@"F:"].location != NSNotFound)&&([responseObject objectForKey:@"session_id"] == nil)) {
            
            CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trType = [NSNumber numberWithInt:1];
            transaction.trMoneyCh = [NSNumber numberWithInt:100];
            transaction.trLocalID = [NSNumber numberWithInt:[playerAccount increaseGlNumber]];
            playerAccount.money+=100;
            transaction.trDescription = [[NSString alloc] initWithFormat:@"forIPad"];
            [playerAccount.transactions addObject:transaction];
            [playerAccount saveTransaction];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"moneyForIPad"];
        }
        [profileViewController checkLocationOfViewForFBLogin];

        if (!modifierName) {
            [playerAccount sendTransactions:playerAccount.transactions];
        }
        
        switch ([[LoginAnimatedViewController sharedInstance] loginFacebookStatus]) {
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
        [[LoginAnimatedViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusNone];
        
        [uDef synchronize];
    }
    //
    NSDictionary *response= [responseObject objectForKey:@"response"];
    
    //    Refresh
    
    if([response objectForKey:@"refresh"]!=NULL){
        
        return;
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

#pragma mark DuelProductDownloaderControllerDelegate

-(void)didFinishDownloadWithType:(DuelProductDownloaderType)type error:(NSError *)error;
{
    if (!error) {
        if (type == DuelProductDownloaderTypeDuelProduct) {
            [duelProductDownloaderController refreshUserDuelProducts];
        }else if (type == DuelProductDownloaderTypeUserProduct) {
            if ([[self.navigationController visibleViewController] isKindOfClass:[StoreViewController class]]) {
                [(StoreViewController*)[self.navigationController visibleViewController] refreshController];
            }
        }
    }
}

#pragma mark - Authorization

-(void)authorizationModifier:(BOOL)pModifierName;
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    if ([playerAccount.accountID length] < 9) [playerAccount verifyAccountID];
    NSString *deviceToken; 
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceToken"])
        deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceToken"];
    else
        deviceToken = @"";
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    NSLocale* curentLocale = [NSLocale currentLocale];
    NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:REGISTRATION_URL encoding:NSUTF8StringEncoding]]
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
    [dicBody setValue:playerAccount.accountID forKey:@"identifier"];
    
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
    }
    
    oldAccounId=@"";
    gameCenterViewController = [GameCenterViewController sharedInstance:playerAccount andParentVC:self];
    
    if ([duelProductDownloaderController isListProductsAvailable]) {
        [duelProductDownloaderController refreshUserDuelProducts];
    }
}

-(void)modifierUser:(AccountDataSource *)playerTemp;
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:MODIFIER_USER_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    [theRequest setHTTPMethod:@"POST"]; 
    NSMutableDictionary *dicBody=[NSMutableDictionary dictionary];
    [dicBody setValue:playerTemp.accountID forKey:@"authentification"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerTemp.accountLevel ] forKey:@"level"]; 
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerTemp.accountPoints ] forKey:@"points"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerTemp.accountWins] forKey:@"duels_win"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerTemp.accountDraws] forKey:@"duels_lost"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",playerTemp.accountBigestWin] forKey:@"bigest_win"];
    
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    DLog(@"modifierUser stBody %@",dicBody);
	[theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [dicForRequests setObject:receivedData forKey:[theConnection.requestURL lastPathComponent]];
    }
}


#pragma mark - protocol GCAuthenticateDelegate 

- (void)setLocalPlayer:(GKLocalPlayer *)player1
{
    if ([playerAccount.accountName isEqualToString:@"Anonymous"]||[playerAccount.accountName isEqualToString:@""]||!playerAccount.accountName) {
        [playerAccount setAccountName:player1.alias];
    }
    [[GCHelper sharedInstance] reportAchievementIdentifier:[[GCHelper sharedInstance].GC_ACH objectAtIndex:playerAccount.accountLevel] percentComplete:100.0f];
    [[GCHelper sharedInstance] reportScore:playerAccount.money forCategory:GC_LEADEBOARD_MONEY];
}

#pragma mark - AlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        isPushMessageShow = NO;
        if (buttonIndex == 1)
        {
            [self startDuel];
        }
    }else if (alertView.tag == 2){
        if (buttonIndex == 1)
        {
            TWTweetComposeViewController *ctrl = [[TWTweetComposeViewController alloc] init];
            if ([ctrl respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
                // Manually invoke the alert view button handler
                [(id <UIAlertViewDelegate>)ctrl alertView:nil
                                     clickedButtonAtIndex:kTwitterSettingsButtonIndex];
            }
        }

    }    
}

#pragma mark Notification
-(bool)connectedToWiFi
{
	return hostActive;
}

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
                listOfItemsViewController.statusOnLine = hostActive;
                [listOfItemsViewController refreshController];
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


- (void)dealloc {
//    [super dealloc];
}

#pragma mark - Private metods

-(BOOL)isNeedBlockOnlineListForAdvertasingAppear;
{
//    BOOL advertisingWillShow=[[NSUserDefaults standardUserDefaults] boolForKey:@"advertisingWillShow"];
//    
//    int drawCount=playerAccount.accountDraws;
//    int playedMatches=playerAccount.accountWins+drawCount;
    
//    if ((playedMatches>=2)&&([self connectedToWiFi]&&[AdColonyViewController isAdStatusValid])) {
//        if ((advertisingWillShow)&&(playerAccount.removeAds!=AdColonyAdsStatusRemoved)) {
//            [self advertButtonClick];
//            return YES;
//        }
//    }
    return NO;
}

-(BOOL)isAdvertisingOfNewVersionNeedShow;
{
     self.advertisingNewVersionViewController=[[AdvertisingNewVersionViewController alloc] init];
    if ([self.advertisingNewVersionViewController advertisingNeed]) {
        [self.navigationController pushViewController:self.advertisingNewVersionViewController animated:NO];
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
    if (LoginForIPad &&(![[OGHelper sharedInstance] isAuthorized])) {
        firstRunLocal = NO;
        animationCheck = NO;
        LoginAnimatedViewController *loginViewControllerLocal =[LoginAnimatedViewController sharedInstance];
        loginViewControllerLocal.startViewController = self;
        [self.navigationController pushViewController:loginViewControllerLocal animated:YES];
        loginViewControllerLocal = nil;
    }
}

-(float)abs:(float)d
{
    if (d<0) return -1.0 * d;
    else return d;
}

#pragma mark CloudAnimation

-(void)cloudAnimation;
{
    if (animationCheck) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.7f];
        [UIView setAnimationDelegate:self];
        
        CGRect frame = cloudView.frame;
        frame.origin.x = cloudX;
        cloudView.frame = frame;
        cloudX-=10;
        
        [UIView setAnimationDidStopSelector:@selector(cloudRevAnimation)];
        [UIView commitAnimations];
    }
}

-(void)cloudRevAnimation
{
    if(cloudX == 440){
        [cloudView setHidden:NO];
    }
    
    if(cloudX==-20){
        [self cloudSecondAnimation];
    }
    
    if(cloudX==-520){
        [cloudView setHidden:YES];
        CGRect frame = cloudView.frame;
        frame.origin.x = 460;
        cloudView.frame = frame;
        cloudX=460;
    }else{
        [self cloudAnimation];
    }
}

-(void)cloudSecondAnimation
{
    if (animationCheck) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.7f];
        [UIView setAnimationDelegate:self];
        
        CGRect frame = cloudSecondView.frame;
        frame.origin.x = cloud2X;
        cloudSecondView.frame = frame;
        cloud2X-=10;
        
        [UIView setAnimationDidStopSelector:@selector(cloudSecondRevAnimation)];
        [UIView commitAnimations];
    }
}

-(void)cloudSecondRevAnimation
{
    if(cloud2X ==440){
        [cloudSecondView setHidden:NO];
    }
    if(cloud2X==-20){
        [self cloudAnimation];
    }
    if(cloud2X==-520){
        [cloudSecondView setHidden:YES];
        CGRect frame = cloudSecondView.frame;
        frame.origin.x = 460;
        cloudSecondView.frame = frame;
        cloud2X=460;
    }else{
        [self cloudSecondAnimation];
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
        transaction.trLocalID = [NSNumber numberWithInt:[playerAccount increaseGlNumber]];
        transaction.trDescription = [[NSString alloc] initWithFormat:@"Daily money"];
        
        [playerAccount.transactions addObject:transaction];
        
        [playerAccount saveTransaction];
        
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

#pragma mark Sound
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


@end
