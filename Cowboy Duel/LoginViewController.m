//
//  LoginViewController.m
//  Cowboy Duel 1
//
//  Created by Sergey Sobol on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "StartViewController.h"
#import "TestAppDelegate.h"
#import "ProfileViewController.h"
#import "UIButton+Image+Title.h"
#import "UIView+Dinamic_BackGround.h"

#define kFacebookAppId @"284932561559672"
NSString *const URL_PAGE_IPAD_COMPETITION=@"http://cdfb.webkate.com/contest/first/";

@implementation LoginViewController

@synthesize startViewController, facebook,delegate ,loginFacebookStatus;

static LoginViewController *sharedHelper = nil;
+ (LoginViewController *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[LoginViewController alloc] init];
    }
    return sharedHelper;
}

-(id)init;
{
    self = [super initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    
	if (self) {
        playerAccount=[AccountDataSource sharedInstance];
        loginFacebookStatus = LoginFacebookStatusNone;
    }
    return self;
    
}


- (void)initFacebook {
    if (!facebook) {
        self.facebook = [[Facebook alloc] initWithAppId:kFacebookAppId andDelegate:self];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        facebook.accessToken = [userDefaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [userDefaults objectForKey:@"FBExpirationDateKey"];
        
        [[OGHelper sharedInstance] createControllsWithAccount:playerAccount facebook:facebook];
//        [facebook release];
    }
}

- (void)viewDidLoad{
    UIColor *mainColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    congLabel.text = NSLocalizedString(@"LoginTitleAtStart", nil);
    congLabel.textColor = mainColor;
    congLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
    link.layer.masksToBounds = YES;
    [link setBackgroundColor:[UIColor clearColor]];
    [link setOpaque:NO];
    link.userInteractionEnabled = YES;
    [link setDelegate:self];
    [(UIScrollView *)[[link subviews] lastObject] setScrollEnabled:NO];
    [link loadHTMLString:NSLocalizedString(@"LoginText", nil) baseURL:Nil];
    
    loginBtnTitle.text = NSLocalizedString(@"LoginBtnLogInAtStart", nil);
    loginBtnTitle.textColor = btnColor;
    loginBtnTitle.textAlignment = UITextAlignmentCenter;
    loginBtnTitle.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    nextTimeBtnTitle.text = NSLocalizedString(@"LoginBtnNextTimeAtStart", nil);
    nextTimeBtnTitle.textColor = btnColor;
    nextTimeBtnTitle.textAlignment = UITextAlignmentCenter;
    nextTimeBtnTitle.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    [mainLoginView setDinamicHeightBackground];
}

-(void)viewWillAppear:(BOOL)animated;
{
    [[LoginViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusSimple];
}

#pragma mark -

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)fbLoginBtnClick:(id)sender
{
//    if ([delegate respondsToSelector:@selector(loginToFB)]) {
//        [delegate loginToFB];
//    }
    [self initFacebook];

    TestAppDelegate *testAppDelegate = (TestAppDelegate *) [[UIApplication sharedApplication] delegate];

    [testAppDelegate setLoginViewController:self];
    
    NSLog(@"fbLogIn");
	[facebook authorize:[NSArray arrayWithObjects:@"publish_stream", @"publish_actions" ,@"offline_access",@"user_games_activity",@"user_birthday",@" user_location",nil]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"login_FB" forKey:@"event"]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IPad"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.view removeFromSuperview];
}

-(IBAction)scipLoginBtnClick:(id)sender
{
//    if ([delegate respondsToSelector:@selector(skipLoginFB)]) {
//        [delegate skipLoginFB];
//    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IPad"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithAccount:playerAccount startViewController:startViewController];
    [profileViewController setNeedAnimation:YES];
    [self.navigationController pushViewController:profileViewController animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"login_cancel" forKey:@"event"]];
}

-(void)logOutFB;
{
    [self initFacebook];
	[facebook logout:self];
}
#pragma mark -
#pragma mark FConnect Methods

- (void)fbDidLogin {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"FBAccessTokenKey"]) {
        
        //    [userDefaults setObject:self.facebook.accessToken forKey:@"AccessToken"];
        [userDefaults setObject:self.facebook.accessToken forKey:@"FBAccessTokenKey"];
        [userDefaults setObject:self.facebook.expirationDate forKey:@"FBExpirationDateKey"];
                
        [[OGHelper sharedInstance] createControllsWithAccount:playerAccount facebook:facebook];
        
        NSInteger facebookLogIn = 1;
        [userDefaults setInteger:facebookLogIn forKey:@"facebookLogIn"];
        [userDefaults synchronize];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"birthday,id,name,picture,location",@"fields",nil];
        [[OGHelper sharedInstance] getCountOfUserFriends];
        
        [self.facebook requestWithGraphPath:@"me" andParams:params andDelegate:startViewController];
        
        
        switch (loginFacebookStatus) {
            case LoginFacebookStatusSimple:
                [startViewController profileButtonClickWithOutAnimation];
                loginFacebookStatus = LoginFacebookStatusNone;
                break;
            case LoginFacebookStatusFeed:
                if (startViewController.feedBackViewVisible) {
                    [startViewController feedbackFacebookBtnClick:self];
                }
                loginFacebookStatus = LoginFacebookStatusNone;
                break;
            default:
                break;
        }
    }
}

- (void)fbDidLogout {
    //    	[self setCurrentViewState:SocialNetworkStateNotLogged];      
    //      [[DataProvider sharedInstance].karmaDataSource clearKarma];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"FBAccessTokenKey"];
    [userDefaults removeObjectForKey:@"FBExpirationDateKey"];
    NSInteger facebookLogIn = 0;
    [userDefaults setInteger:facebookLogIn forKey:@"facebookLogIn"];
    [userDefaults synchronize];
    
    startViewController.oldAccounId=playerAccount.accountID;
    [playerAccount makeLocalAccountID];
     [[NSUserDefaults standardUserDefaults] setObject:ValidateObject(playerAccount.accountID, [NSString class]) forKey:@"id"];
    [startViewController authorizationModifier:NO];
    
//    gameCenterViewController = [GameCenterViewController sharedInstance:playerAccount andParentVC:startViewController];
//    if (!gameCenterViewController.multiplayerServerViewController.isRunServer && !gameCenterViewController.multiplayerServerViewController.neadRestart)    [gameCenterViewController startServerWithName:playerAccount.accountID];
//    else if (gameCenterViewController.multiplayerServerViewController.isRunServer)
//    {
//        gameCenterViewController.multiplayerServerViewController.neadRestart = YES;
//        gameCenterViewController.multiplayerServerViewController.serverNameGlobal = playerAccount.accountID;
//        [gameCenterViewController.multiplayerServerViewController shutDownServer];
//    }
//    
//    gameCenterViewController.duelStartViewController = nil;
    
}

-(void)fbDidNotLogin:(BOOL)cancelled
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kCheckfFBLoginSession
                                                        object:self
                                                      userInfo:nil];
} 

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	
    NSLog(@"Facebook request failed: %@", [error description]);
    //	[delegate hideHudWithAns:NO];
    //    [[NetworkActivityIndicatorManager sharedInstance] hide];
	
	[facebook logout:self];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    
    facebook.accessToken = accessToken;
    facebook.expirationDate = expiresAt;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];    
}

- (void)fbSessionInvalidated;
{
    NSLog(@"OGHelper fbSessionInvalidated");
}
#pragma mark -

- (void)viewDidUnload {
//    achievMainView = nil;
//    btnUpdate = nil;
//    lbUpdateBtnTitle = nil;
//    btnTellFriends = nil;
//    btnNextTime = nil;
    mainLoginView = nil;
//    webMesView = nil;
    [super viewDidUnload];
    _btnFBLogin = nil;
    _btnNextTime = nil;
    loginBtnTitle = nil;
    nextTimeBtnTitle = nil;
//    achievTellFriendsBtnTitle = nil;
//    achievNextTimeBtnTitle = nil;
    link = nil;
}
- (void)dealloc {
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
    NSLog(@"login Error %@",[error description]);
}
#pragma mark -

@end
