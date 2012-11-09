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
#import "LevelCongratViewController.h"
#import "MoneyCongratViewController.h"

#import "DuelProductDownloaderController.h"
#import "StoreViewController.h"

@interface StartViewController ()
{
    AccountDataSource *playerAccount;
    AccountDataSource *oponentAccount;
    ActivityIndicatorView *activityIndicatorView;
    CollectionAppViewController *collectionAppViewController;
    ListOfItemsViewController *listOfItemsViewController;
    ProfileViewController *profileViewController;
    TopPlayersDataSource *topPlayersDataSource;
    DuelProductDownloaderController *duelProductDownloaderController;
    
    UIView *hudView;
    
    BOOL firstRun;
    BOOL firstRunLocal;
    BOOL firstDayWithOutAdvertising;
    
    AVAudioPlayer *player;
    
    UIView *v10DolarsForDay;
    
    BOOL soundCheack;
    
    BOOL avtorizationInProcess;
    
    BOOL internetActive;
    BOOL hostActive;
    
    BOOL feedBackViewVisible;
    
    Reachability* internetReachable;
    Reachability* hostReachable;
    Facebook *facebook;
    
    UIImageView_AttachedView *arrowImage;
    
    NSString *oldAccounId;
    LoginViewController *loginViewController;
    
    NSMutableDictionary *dicForRequests;
    BOOL modifierName;
    //buttons
    IBOutlet UIButton *teachingButton;
    IBOutlet UIButton *duelButton;
    IBOutlet UIButton *mapButton;
    IBOutlet UIButton *profileButton;
    IBOutlet UIButton *feedbackButton;
    IBOutlet UIButton *helpButton;
    
    IBOutlet UIView *feedbackView;
    
    IBOutlet UIImageView *backGroundfeedbackView;
    IBOutlet UIActivityIndicatorView *indicatorfeedbackView;
    
    
    IBOutlet UILabel *lbPostMessage;
    IBOutlet UILabel *lbMailMessage;
    IBOutlet UILabel *lbRateMessage;
    IBOutlet UILabel *lbFeedbackCancelBtn;
}
@property (strong, nonatomic) IBOutlet UIButton *teachingButton;
@property (strong, nonatomic) IBOutlet UIButton *duelButton;
@property (strong, nonatomic) IBOutlet UIButton *mapButton;
@property (strong, nonatomic) IBOutlet UIButton *helpButton;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (strong, nonatomic) IBOutlet UIButton *feedbackButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorfeedbackView;
@property (strong, nonatomic) IBOutlet UIImageView *backGroundfeedbackView;

@property (strong) GameCenterViewController *gameCenterViewController;

@property (strong,nonatomic) AVAudioPlayer *player;

@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL hostActive;

@property (strong) LoginViewController *loginViewController;

-(void)sendRequestWithDonateSum:(int)sum;
- (NSString *)deviceType;
-(void)arrowAnimation;

@end

#define BOT_DUEL_TAG 3

#define iTunesId @"http://cowboyduel.mobi/r/"

// http://itunes.apple.com/ua/app/platforma/id525730690?mt=8

@implementation StartViewController

@synthesize gameCenterViewController, player, internetActive, hostActive, soundCheack, loginViewController;
@synthesize feedbackButton, duelButton, profileButton, teachingButton, helpButton, mapButton;
@synthesize oldAccounId,feedBackViewVisible,showFeedAtFirst,topPlayersDataSource;

static const char *AUTORIZATION_URL =  BASE_URL"api/authorization";
static const char *MODIFIER_USER_URL =  BASE_URL"api/user";
static const char *A_URL =  BASE_URL"api/a";
static const char *OUT_URL =  BASE_URL"api/out";

NSString *const URL_FB_PAGE=@"http://cowboyduel.mobi/"; 
NSString *const NewMessageReceivedNotification = @"NewMessageReceivedNotification";

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
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    
    if (self == [super initWithNibName:nil bundle:nil]) {
        
        playerAccount = [AccountDataSource sharedInstance];
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
            NSInteger kFrequencyOfAdvertising = [[NSUserDefaults standardUserDefaults] integerForKey:@"kFrequencyOfAdvertising"];
            if (kFrequencyOfAdvertising==0) {
                [[NSUserDefaults standardUserDefaults] setInteger:kFrequencyOfAdvertisingDefault forKey:@"kFrequencyOfAdvertising"];
            }
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
        
        if(firstRun){
            
            [uDef setBool:TRUE forKey:@"FirstRunForGun"];
            [uDef setBool:TRUE forKey:@"FirstRunForDuel"];
            [playerAccount saveMoney];
            [playerAccount saveAccountName];
            NSString *accID=[[NSString alloc]init];
            if(playerAccount.accountID==NULL){
                accID=@"NoGC";
            }else{
                accID=playerAccount.accountID;
            }
            [playerAccount saveID];
            [playerAccount saveDeviceType];
            playerAccount.glNumber = [NSNumber numberWithInt:0];
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
                        
            [uDef synchronize];
        }else{
            
            [uDef setBool:FALSE forKey:@"FirstRunForGun"];
            [uDef setBool:FALSE forKey:@"FirstRunForDuel"];
            [uDef setInteger:2 forKey:@"FirstRunForPractice"];
            
            [playerAccount loadAllParametrs];
            
//          putch for 1.4.1
            [playerAccount putchAvatarImageToInitStartVC:self];
//            
            if (!([playerAccount.accountID rangeOfString:@"F"].location == NSNotFound)){ 
                facebook = [[Facebook alloc] initWithAppId:kFacebookAppId andDelegate:[LoginViewController sharedInstance]];
                
                if ([uDef objectForKey:@"FBAccessTokenKey"] 
                    && [uDef objectForKey:@"FBExpirationDateKey"]) {
                    facebook.accessToken = [uDef objectForKey:@"FBAccessTokenKey"];
                    facebook.expirationDate = [uDef objectForKey:@"FBExpirationDateKey"];
                }
                [[LoginViewController sharedInstance] setFacebook:facebook];
                [[OGHelper sharedInstance ] initWithAccount:playerAccount facebook:facebook];
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
            CDTransaction *localTransaction = [playerAccount.transactions lastObject];
            playerAccount.glNumber = localTransaction.trLocalID;
          DLog(@"Transactions count = %d", [playerAccount.transactions count]);            
            
            NSArray *oldLocations2 = [uDef arrayForKey:@"duels"];
            if( playerAccount.duels )
            {
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
        }
               
        dicForRequests=[[NSMutableDictionary alloc] init];
        
        gameCenterViewController = [GameCenterViewController sharedInstance:playerAccount andParentVC:self];
        listOfItemsViewController=[[ListOfItemsViewController alloc]initWithGCVC:gameCenterViewController Account:playerAccount OnLine:self.hostActive];
        duelProductDownloaderController = [[DuelProductDownloaderController alloc] init];
        
        if (firstRun) {
            [gameCenterViewController stopServer];
        }
        
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
        
        hostReachable = [Reachability reachabilityWithHostName: @"www.apple.com"];
        [hostReachable startNotifier];

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
    
    [mapButton setTitle:NSLocalizedString(@"STORE", @"") forState:UIControlStateNormal];
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
        arrowImage=[[UIImageView_AttachedView alloc] initWithImage:[UIImage imageNamed:@"st_arrow.png"] attachedToFrame:teachingButton frequence:0.5 amplitude:10 direction:DirectionToAnimateLeft];
        
        hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 480)];
        hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
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
    
    [self changeRankOfBlackHelpViews];
    
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
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    if (!gameCenterViewController.multiplayerServerViewController.isRunServer && !gameCenterViewController.multiplayerServerViewController.neadRestart && mutchEnded && [userDef integerForKey:@"FirstRunForPractice"] == 2)
    {
       [gameCenterViewController startServerWithName:playerAccount.accountID];
    }
    gameCenterViewController.duelStartViewController = nil;
    
    [self showProfileFirstRun];
    [self isAdvertisingOfNewVersionNeedShow];
    [self estimateApp];
}

-(void)didBecomeActive
{
    DLog(@"did become active");
    if (!firstRunLocal) {
         [self login];
    }
    
    [facebook extendAccessTokenIfNeeded];
    if (profileViewController) {
        [profileViewController checkValidBlackActivity];
    }
    firstDayWithOutAdvertising=[AdvertisingAppearController advertisingCheckForAppearWithFirstDayWithOutAdvertising:firstDayWithOutAdvertising];
}

-(void)didEnterBackground
{
    [self logout];
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
    [listOfItemsViewController setStatusOnLine:self.hostActive];
    [self.navigationController pushViewController:listOfItemsViewController animated:YES];
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
    StoreViewController *svc=[[StoreViewController alloc] initWithAccount:playerAccount];
    [self.navigationController pushViewController:svc animated:YES];
    return;

    collectionAppViewController=[[CollectionAppViewController alloc] init];
    [self presentModalViewController:collectionAppViewController animated:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/more_games" forKey:@"event"]];

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

-(void)profileButtonClickWithOutAnimation;
{   
    UIViewController *topController=[self.navigationController topViewController];
    if (![topController isKindOfClass:[ProfileViewController class]]) {
        profileViewController = [[ProfileViewController alloc] initWithAccount:playerAccount startViewController:self];
        [profileViewController.ivBlack setHidden:NO];
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
//    DuelProductDownloaderController *dw=[[DuelProductDownloaderController alloc] init];
////    [dw downloadUserProductsIsListProductsAvailable];
//    [dw refreshDuelProducts];
////    [dw buyProductID:23 transactionID:23];
//    return;
    
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
            NSString *URL=[[NSString alloc]initWithFormat:@"https://twitter.com/intent/tweet?source=webclient&text=%@ %@",
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

#pragma mark - Login/Logout

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

#pragma mark - CustomNSURLConnection handlers

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
        
        if (playerAccount.removeAds!=AdColonyAdsStatusRemoved) {
            int removeAds=[[responseObject objectForKey:@"remove_ads"] intValue];
            playerAccount.removeAds=removeAds;
            [playerAccount saveRemoveAds];
        }

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
        
        BOOL moneyForIPad=[[NSUserDefaults standardUserDefaults] boolForKey:@"moneyForIPad"];
        if (!moneyForIPad && ([[responseObject objectForKey:@"money"] intValue] == 200) && ([playerAccount.accountID rangeOfString:@"F:"].location != NSNotFound)) {
            
            CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trType = [NSNumber numberWithInt:1];
            transaction.trMoneyCh = [NSNumber numberWithInt:100];
            playerAccount.money+=100;
            transaction.trDescription = [[NSString alloc] initWithFormat:@"forIPad"];
            [playerAccount.transactions addObject:transaction];
            [playerAccount saveTransaction];
            
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


#pragma mark - Authorization

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
    
    if (![duelProductDownloaderController isListProductsAvailable] && !modifierName) {
        [duelProductDownloaderController downloadUserProducts];
    }
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


#pragma mark - protocol GCAuthenticateDelegate 

- (void)setLocalPlayer:(GKLocalPlayer *)player1
{
    if ([playerAccount.accountName isEqualToString:@"Anonymous"]||[playerAccount.accountName isEqualToString:@""]||!playerAccount.accountName) {
        [playerAccount setAccountName:player1.alias];
    }
    if (playerAccount.accountLevel>=1) {
        [[GCHelper sharedInstance] reportAchievementIdentifier:[[GCHelper sharedInstance].GC_ACH objectAtIndex:1] percentComplete:100.0f];
    }
}

#pragma mark - AlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case BOT_DUEL_TAG:
        {
            if(buttonIndex==alertView.cancelButtonIndex  )
            {
                [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];
            }
        }
            break;   
            
        default:
            break;
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

#pragma mark FConnect Methods

- (void)request:(FBRequest *)request didLoad:(id)result {
	
    
	if ([result isKindOfClass:[NSDictionary class]]) {

//        putch for 1.4.1
        BOOL modifierUserInfo = NO;
        if (([playerAccount.accountID rangeOfString:@"F:"].location != NSNotFound)&&[playerAccount putchAvatarImageSendInfo]) {
            modifierUserInfo = YES;
        }
//
        oldAccounId = [[NSString alloc] initWithFormat:@"%@",playerAccount.accountID];
        
		NSString *userId = [NSString stringWithFormat:@"F:%@", ValidateObject([result objectForKey:@"id"], [NSString class])];
        playerAccount.accountID=userId;
		NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        NSString *playerName=[NSString stringWithFormat:@"%@", ValidateObject([result objectForKey:@"name"], [NSString class])];
                
        if ([playerAccount.accountName isEqualToString:@"Anonymous"]||[playerAccount.accountName isEqualToString:@""]||!playerAccount.accountName) {
            [playerAccount setAccountName:playerName];  
        } 
        playerAccount.facebookName=playerName;
        
        NSDictionary *data = ValidateObject([result objectForKey:@"picture"], [NSDictionary class]);
        NSDictionary *imageDictionary = ValidateObject([data objectForKey:@"data"], [NSDictionary class]);
        playerAccount.avatar=[NSString stringWithFormat:@"%@", ValidateObject([imageDictionary objectForKey:@"url"], [NSString class])];
        
        playerAccount.age=[NSString stringWithFormat:@"%@", ValidateObject([result objectForKey:@"birthday"], [NSString class])];
        
        NSDictionary *town=ValidateObject([result objectForKey:@"location"], [NSDictionary class]);
        playerAccount.homeTown=[NSString stringWithFormat:@"%@", ValidateObject([town objectForKey:@"name"], [NSString class])];
        
        [playerAccount saveAge];
        [playerAccount saveHomeTown];
        [playerAccount saveFacebookName];
        [playerAccount saveAvatar];
        
        [uDef setObject:ValidateObject(playerAccount.accountID, [NSString class]) forKey:@"id"];
        
        [uDef setObject:ValidateObject(playerAccount.accountName, [NSString class]) forKey:@"name"];
            
        [uDef synchronize];
        
        [self authorizationModifier:modifierUserInfo];
    }

}

- (void)dealloc {
//    [super dealloc];
}

#pragma mark - Private metods

-(BOOL)isNeedBlockOnlineListForAdvertasingAppear;
{
    BOOL advertisingWillShow=[[NSUserDefaults standardUserDefaults] boolForKey:@"advertisingWillShow"];
    
    int drawCount=playerAccount.accountDraws;
    int playedMatches=playerAccount.accountWins+drawCount;
    
    if ((playedMatches>=2)&&([self connectedToWiFi]&&[AdColonyViewController isAdStatusValid])) {
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
-(void)changeRankOfBlackHelpViews
{
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
        [hudView setHidden:YES];
        [hudView removeFromSuperview];
    }
}

-(float)abs:(float)d
{
    if (d<0) return -1.0 * d;
    else return d;
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
