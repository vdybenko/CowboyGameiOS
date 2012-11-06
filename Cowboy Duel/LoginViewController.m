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

@interface LoginViewController ()
{
    StartViewController * startViewController;
    Facebook *facebook;
    AccountDataSource *playerAccount;
    IBOutlet UIView *view;
    IBOutlet UILabel *congLabel;
    IBOutlet UILabel *loginBtnTitle;
    IBOutlet UILabel *nextTimeBtnTitle;
    IBOutlet UIView *mainLoginView;
    
    IBOutlet UIButton *_btnFBLogin;
    IBOutlet UIButton *_btnNextTime;
    IBOutlet UIWebView *link;
    UIAlertView *baseAlert;
    NSMutableString *stDonate;
    
    LoginFacebookStatus loginFacebookStatus;
    __unsafe_unretained IBOutlet UIView *activityView;
    __unsafe_unretained IBOutlet UIActivityIndicatorView *activityIndicatorView;
   
}
@end

@implementation LoginViewController
NSString * const loginProduct=@"com.webkate.cowboyduels.registration";
@synthesize startViewController, facebook,delegate ,loginFacebookStatus, payment;

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
    }
}

- (void)viewDidLoad{
    UIColor *mainColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    
    congLabel.textColor = mainColor;
    congLabel.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    congLabel.text = NSLocalizedString(@"LoginTitleAtStart", nil);
    
    link.layer.masksToBounds = YES;
    [link setBackgroundColor:[UIColor clearColor]];
    [link setOpaque:NO];
    link.userInteractionEnabled = YES;
    [link setDelegate:self];
    [(UIScrollView *)[[link subviews] lastObject] setScrollEnabled:NO];
    
    
    
    loginBtnTitle.textColor = btnColor;
    loginBtnTitle.textAlignment = UITextAlignmentCenter;
    loginBtnTitle.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    
    nextTimeBtnTitle.textColor = btnColor;
    nextTimeBtnTitle.textAlignment = UITextAlignmentCenter;
    nextTimeBtnTitle.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    if (payment) {
        [link loadHTMLString:NSLocalizedString(@"LoginTextPayment", nil) baseURL:Nil];
        loginBtnTitle.text = NSLocalizedString(@"LoginBtnLogInAtStartPayment", nil);
        nextTimeBtnTitle.text = NSLocalizedString(@"LoginBtnNextTimeAtStartPayment", nil);

    }
    else{
        
        [link loadHTMLString:NSLocalizedString(@"LoginText", nil) baseURL:Nil];
        loginBtnTitle.text = NSLocalizedString(@"LoginBtnLogInAtStart", nil);
        nextTimeBtnTitle.text = NSLocalizedString(@"LoginBtnNextTimeAtStart", nil);

    }
    
    [mainLoginView setDinamicHeightBackground];
}

-(void)viewWillAppear:(BOOL)animated;
{
    [MKStoreManager sharedManager].delegate = sharedHelper;
    [[LoginViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusSimple];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -

-(IBAction)fbLoginBtnClick:(id)sender
{
    [self initFacebook];

    TestAppDelegate *testAppDelegate = (TestAppDelegate *) [[UIApplication sharedApplication] delegate];

    [testAppDelegate setLoginViewController:self];
    
    DLog(@"fbLogIn");
	[facebook authorize:[NSArray arrayWithObjects:@"publish_stream", @"publish_actions" ,@"offline_access",@"user_games_activity",@"user_birthday",@" user_location",nil]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/login_FB" forKey:@"event"]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IPad"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.view removeFromSuperview];
}

-(IBAction)scipLoginBtnClick:(id)sender
{
    stDonate=[[NSMutableString alloc] init];
    if (payment) {
        [[MKStoreManager sharedManager] buyFeatureA];
        [activityView setHidden:NO];
        [activityIndicatorView startAnimating];
        [stDonate appendString:@"/paymentRegistration"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:stDonate forKey:@"event"]];
    
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IPad"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithAccount:playerAccount startViewController:startViewController];
    [profileViewController setNeedAnimation:YES];
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/login_cancel" forKey:@"event"]];
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
        
        [userDefaults setObject:self.facebook.accessToken forKey:@"FBAccessTokenKey"];
        [userDefaults setObject:self.facebook.expirationDate forKey:@"FBExpirationDateKey"];
                
        [[OGHelper sharedInstance] createControllsWithAccount:playerAccount facebook:facebook];
        
        NSInteger facebookLogIn = 1;
        [userDefaults setInteger:facebookLogIn forKey:@"facebookLogIn"];
        [userDefaults synchronize];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"birthday,id,name,picture,location",@"fields",nil];
        [[OGHelper sharedInstance] getCountOfUserFriends];
        
        [self.facebook requestWithGraphPath:@"me" andParams:params andDelegate:self];
        
        
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
        
        //        putch for 1.4.1
        BOOL modifierUserInfo = NO;
        if (([playerAccount.accountID rangeOfString:@"F:"].location != NSNotFound)&&[playerAccount putchAvatarImageSendInfo]) {
            modifierUserInfo = YES;
        }
        //
        startViewController.oldAccounId = [[NSString alloc] initWithFormat:@"%@",playerAccount.accountID];
        
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
        
        [startViewController authorizationModifier:modifierUserInfo];
        payment = NO;
        [self scipLoginBtnClick:nil];
    }
    
}


- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	
    DLog(@"Facebook request failed: %@", [error description]);
	
	[facebook logout:self];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    DLog(@"token extended");
    
    facebook.accessToken = accessToken;
    facebook.expirationDate = expiresAt;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];    
}

- (void)fbSessionInvalidated;
{
    DLog(@"OGHelper fbSessionInvalidated");
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

#pragma mark MKStoreKitDelegate

- (void)productAPurchased
{
	DLog(@"completedPurchaseTransaction");
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [activityView setHidden:YES];
    [activityIndicatorView stopAnimating];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger paymentRegistration = 1;
    [userDefaults setInteger:paymentRegistration forKey:@"paymentRegistration"];
    [userDefaults synchronize];
    
    [stDonate appendString:@"/done"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:stDonate forKey:@"event"]];
    
    payment = NO;
    [self scipLoginBtnClick:nil];

}

- (void)failed
{
    [stDonate appendString:@"/error"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:stDonate forKey:@"event"]];
	[activityView setHidden:YES];
    [activityIndicatorView stopAnimating];
}

#pragma mark -

- (void)viewDidUnload {
    mainLoginView = nil;
    _btnFBLogin = nil;
    _btnNextTime = nil;
    loginBtnTitle = nil;
    nextTimeBtnTitle = nil;
    link = nil;
    activityView = nil;
    activityIndicatorView = nil;
    [super viewDidUnload];
}
- (void)dealloc {
}
@end
