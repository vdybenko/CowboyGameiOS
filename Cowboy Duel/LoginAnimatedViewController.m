//
//  LoginAnimatedViewController.m
//  Cowboy Duels
//
//  Created by Sergey Sobol on 07.11.12.
//
//

#import "LoginAnimatedViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "BEAnimationView.h"
#import "StartViewController.h"
#import "TestAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Facebook.h"
#import "ActiveDuelViewController.h"
#import "UIView+Dinamic_BackGround.h"

#define kFacebookAppId @"284932561559672"
NSString *const URL_PAGE_IPAD_COMPETITION=@"http://cdfb.webkate.com/contest/first/";

@interface LoginAnimatedViewController ()
{
    AccountDataSource *playerAccount;
    NSMutableString *stDonate;
    __weak IBOutlet UIView *activityView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicatorView;
    __weak IBOutlet UIImageView *backgroundView;
    __weak IBOutlet UIButton *practiceButton;
    __weak IBOutlet UILabel *animetedText;
    __weak IBOutlet UILabel *animetedText2;
    __weak IBOutlet UIButton *loginFBbutton;
    __weak IBOutlet UILabel *practiceLable;
    __weak IBOutlet UILabel *loginLable;
    
    __weak IBOutlet UIView *textsBackground;
    
    __weak IBOutlet UIScrollView *scroolView;
    
    BOOL tryAgain;
    BOOL animationPause;
}

@end

@implementation LoginAnimatedViewController
@synthesize delegate ,loginFacebookStatus, payment;

static LoginAnimatedViewController *sharedHelper = nil;
+ (LoginAnimatedViewController *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[LoginAnimatedViewController alloc] init];
    }
    return sharedHelper;
}

-(id)init;
{
    self = [super initWithNibName:@"LoginAnimatedViewController" bundle:[NSBundle mainBundle]];
    
	if (self) {
        playerAccount=[AccountDataSource sharedInstance];
        playerAccount.loginAnimatedViewController = self;
        loginFacebookStatus = LoginFacebookStatusNone;
    }
    return self;
    
}

- (void)initFacebook {
    [[OGHelper sharedInstance] createControllsWithAccount:playerAccount];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    animationPause = NO;

    loginLable.text = NSLocalizedString(@"LOGIN", @"");
    loginLable.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    practiceLable.text = NSLocalizedString(@"PRACTICE", @"");
    practiceLable.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    [textsBackground setDinamicHeightBackground];
    
    animetedText.text = NSLocalizedString(@"1stIntro", @"");
    animetedText2.text = NSLocalizedString(@"2ndIntro", @"");
    
    scroolView.contentSize = (CGSize){2*scroolView.frame.size.width,scroolView.frame.size.height};
    
    stDonate = [NSMutableString string];
    [[LoginAnimatedViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusSimple];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstRun_v2.2"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[StartViewController sharedInstance] playerStart];
    
    if (!animationPause) {
        [self performSelector:@selector(scroolViewAnimation) withObject:Nil afterDelay:10.5f];
        
        [self performSelector:@selector(scaleView:) withObject:practiceLable  afterDelay:14.0];
        [self performSelector:@selector(scaleView:) withObject:practiceButton  afterDelay:14.0];
        [self performSelector:@selector(scaleView:) withObject:loginFBbutton  afterDelay:18.2];
        [self performSelector:@selector(scaleView:) withObject:loginLable  afterDelay:18.2];
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/LoginAnimatedVC" forKey:@"page"]];
  
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[StartViewController sharedInstance] playerStop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IBActions

- (IBAction)practiceButtonClick:(id)sender {
    //stop animations
    animationPause = YES;

    [LoginAnimatedViewController sharedInstance].isDemoPractice = YES;
    
    //creating ActiveDuelVC
    AccountDataSource *oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer];
    playerAccount.sessionID = @"-1";
    UINavigationController *nav = ((TestAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController;
    ActiveDuelViewController *activeDuelViewController = [[ActiveDuelViewController alloc] initWithAccount:playerAccount oponentAccount:oponentAccount];
    [nav pushViewController:activeDuelViewController animated:YES];
    activeDuelViewController = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/LoginAnimatedVC_practice" forKey:@"page"]];
}

- (IBAction)loginButtonClick:(id)sender {
    [[StartViewController sharedInstance] checkNetworkStatus:nil];
    if ([[StartViewController sharedInstance] connectedToWiFi]) {
        [activityView setHidden:NO];
        [activityIndicatorView startAnimating];
        animationPause = YES;
        
        TestAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate openSessionWithAllowLoginUI:YES];
        
        [self initFacebook];
        
        [playerAccount cleareWeaponAndDefense];
        
        DLog(@"fbLogIn");
        
        playerAccount.loginAnimatedViewController = self;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/LoginAnimatedVC_login_FB" forKey:@"page"]];
        [LoginAnimatedViewController sharedInstance].isDemoPractice = NO;
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", @"AlertView")
                                                            message:NSLocalizedString(@"Internet_down", @"AlertView")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"AlertView")
                                                  otherButtonTitles: nil];
        [alertView show];
        alertView = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/LoginAnimatedVC_Internet_down" forKey:@"page"]];
    }
}


#pragma mark Animations

-(void)scaleView:(UIView *)view
{
    [UIView animateWithDuration:0.6 animations:^{
        view.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL complete) {
        [UIView animateWithDuration:0.6 animations:^{
            view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }completion:^(BOOL complete){
        } ];
    }];
}

-(void)scroolViewAnimation;
{    
    [UIView animateWithDuration:0.8 animations:^{
        [scroolView setContentOffset:(CGPoint){animetedText.frame.size.width,0}];
    }completion:^(BOOL complete){
    } ];
}
#pragma mark -


-(void)logOutFB;
{
    [self initFacebook];
    [[FBSession activeSession] closeAndClearTokenInformation];
	//[facebook logout:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/LoginAnimatedVC_logOut_FB" forKey:@"page"]];
}


- (void)fbDidLogin {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"FBAccessTokenKey"] || ![userDefaults objectForKey:@"FBLoginV2.1"]) {
        [userDefaults setInteger:1 forKey:@"FBLoginV2.1"];
        [userDefaults setObject:[FBSession activeSession].accessToken forKey:@"FBAccessTokenKey"];
        [userDefaults setObject:[FBSession activeSession].expirationDate forKey:@"FBExpirationDateKey"];
        
        [[OGHelper sharedInstance] createControllsWithAccount:playerAccount];
        
        NSInteger facebookLogIn = 1;
        [userDefaults setInteger:facebookLogIn forKey:@"facebookLogIn"];
        [userDefaults synchronize];
                
        [FBRequestConnection startWithGraphPath:@"me" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [self request:nil didLoad:result];
            DLog(@"%@ %@", result, error);
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kCheckfFBLoginSession
                                                            object:self
                                                          userInfo:nil];
        
        [[StartViewController sharedInstance] profileFirstRunButtonClickWithOutAnimation];
    }
}

- (void)fbDidLogout {
    [[FBSession activeSession] closeAndClearTokenInformation];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"FBAccessTokenKey"];
    [userDefaults removeObjectForKey:@"FBExpirationDateKey"];
    NSInteger facebookLogIn = 0;
    [userDefaults setInteger:facebookLogIn forKey:@"facebookLogIn"];
    [userDefaults synchronize];
    
    [StartViewController sharedInstance].oldAccounId=playerAccount.accountID;
    [playerAccount makeLocalAccountID];
    [[NSUserDefaults standardUserDefaults] setObject:ValidateObject(playerAccount.accountID, [NSString class]) forKey:@"id"];
    [[StartViewController sharedInstance] authorizationModifier:NO];
}

-(void)fbDidNotLogin:(BOOL)cancelled
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kCheckfFBLoginSession
                                                        object:self
                                                      userInfo:nil];
}

#pragma mark FConnect Methods

- (void)request:(FBRequest *)request didLoad:(id)result {
	
    
	if ([result isKindOfClass:[NSDictionary class]]) {
        [StartViewController sharedInstance].oldAccounId = [[NSString alloc] initWithFormat:@"%@",playerAccount.accountID];
        
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
        
        [[StartViewController sharedInstance] authorizationModifier:YES];
        payment = NO;
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"loginFirstShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        payment = NO;
    }
}


- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	
    DLog(@"Facebook request failed: %@", [error description]);
	
	//[facebook logout:self];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    DLog(@"token extended");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)fbSessionInvalidated;
{
    DLog(@"OGHelper fbSessionInvalidated");
}

-(void)failed
{
    [activityView setHidden:YES];
}

#pragma mark - UIWebViewDelegate

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    static NSString *urlPrefix = @"http://";
    NSString *url = [[inRequest URL] absoluteString];
    
    if ([url hasPrefix:urlPrefix]) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }else {
        return YES;
    }
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    DLog(@"login Error %@",[error description]);
}
- (void)viewDidUnload {
    textsBackground = nil;
    animetedText2 = nil;
    scroolView = nil;
    [super viewDidUnload];
}
@end
