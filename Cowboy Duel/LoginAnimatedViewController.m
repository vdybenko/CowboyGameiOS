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
#import "ActiveDuelViewController.h"

#define kFacebookAppId @"284932561559672"
NSString *const URL_PAGE_IPAD_COMPETITION=@"http://cdfb.webkate.com/contest/first/";

@interface LoginAnimatedViewController ()
{
    StartViewController * startViewController;
    AccountDataSource *playerAccount;
    NSMutableString *stDonate;
    __weak IBOutlet UIView *activityView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicatorView;
    __weak IBOutlet UIImageView *backgroundView;
    __weak IBOutlet UIImageView *boardImage;
    __weak IBOutlet UIImageView *tryAgainImage;
//    __weak IBOutlet UIButton *payButton;
    __weak IBOutlet UIButton *practiceButton;
    __weak IBOutlet UILabel *animetedText;
    __weak IBOutlet UIButton *loginFBbutton;
    __weak IBOutlet UIView *tryAgainView;
    __weak IBOutlet BEAnimationView *guillotineImage;
    __weak IBOutlet BEAnimationView *whiskersImage;
    __weak IBOutlet BEAnimationView *heatImage;
    __weak IBOutlet UIImageView *headImage;
    __weak IBOutlet UIImageView *noseImage;
//    __weak IBOutlet UILabel *donateLable;
    __weak IBOutlet UILabel *practiceLable;
    __weak IBOutlet UILabel *loginLable;
    __weak IBOutlet UILabel *tryAgainLable;
    __weak IBOutlet UIButton *tryAgainButton;
    
    BOOL tryAgain;
    CGRect guillBackUp;
    CGRect textBackUp;
    CGRect hatBackUp;
    BOOL animationPause;
}
@property (nonatomic) int textIndex;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSArray *textsContainer;
@property (nonatomic) AVAudioPlayer *player;

@end

@implementation LoginAnimatedViewController
@synthesize startViewController, delegate ,loginFacebookStatus, payment;
@synthesize timer, textsContainer;
@synthesize player;

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
//    if (!facebook) {
//        self.facebook = [[Facebook alloc] initWithAppId:kFacebookAppId andDelegate:self];
//        
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        facebook.accessToken = [userDefaults objectForKey:@"FBAccessTokenKey"];
//        facebook.expirationDate = [userDefaults objectForKey:@"FBExpirationDateKey"];
//        
//        [[OGHelper sharedInstance] createControllsWithAccount:playerAccount];
//    }
    
    //[FBSession openActiveSessionWithAllowLoginUI:YES];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    animationPause = NO;
    if (self.view.frame.size.height > 480) {
        [backgroundView setImage:[UIImage imageNamed:@"la_bg-568h.png"]];
        [boardImage setImage:[UIImage imageNamed:@"la_board-568h.png"]];
        CGRect frame = CGRectMake(0, 356, 320, 212);
        [boardImage setFrame:frame];
        [tryAgainImage setImage:[UIImage imageNamed:@"la_ta_bg-568h.png"]];
        frame = guillotineImage.frame;
        frame.size.height = 558;
        frame.origin.y = -400;
        guillotineImage.frame = frame;
        [guillotineImage setImage:[UIImage imageNamed:@"ivGuillotineFull-568h.png"]];
        
    }
    else {
        [backgroundView setImage:[UIImage imageNamed:@"la_bg.png"]];
        [boardImage setImage:[UIImage imageNamed:@"la_board.png"]];
        [tryAgainImage setImage:[UIImage imageNamed:@"la_ta_bg.png"]];
        [guillotineImage setImage:[UIImage imageNamed:@"ivGuillotineFull.png"]];
    }
    loginLable.text = NSLocalizedString(@"LOGIN", @"");
    loginLable.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    practiceLable.text = NSLocalizedString(@"PRACTICE", @"");
    practiceLable.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    tryAgainLable.text = NSLocalizedString(@"TRY AGAIN", @"");
    tryAgainLable.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [tryAgainButton setHidden:YES];
    [tryAgainLable setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    textsContainer = [NSArray arrayWithObjects:
                    NSLocalizedString(@"HEY", nil),             //"Hey guy. Do you hear me?"
                    NSLocalizedString(@"HEY_YOU", nil),         //"Yes, you! Come here."
                    NSLocalizedString(@"IPAD", nil),            //"Do you want an iPad mini?"
                    NSLocalizedString(@"REALLY", nil),          //"Really? Do you like it?"
                    NSLocalizedString(@"HELP_ME", nil),         //"Great. Help me. I know where it is."
                    NSLocalizedString(@"HELP_NOW", nil),        //"Help me!!!"
                    NSLocalizedString(@"CHOOSE_DOLLAR", nil),   //"Pay for me $1...
                    NSLocalizedString(@"CHOOSE_FACEBOOK", nil), //...or give me your ID"
                    nil];
    self.textIndex = 0;
    guillBackUp = guillotineImage.frame;
    textBackUp = animetedText.frame;
    hatBackUp = heatImage.frame;
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/kassa.aif", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.player setVolume:1.0];
    [self.player prepareToPlay];
    [self updateLabels];
  
    [headImage setHidden:YES];
    [heatImage setHidden:NO];
    [noseImage setHidden:YES];
    [whiskersImage setHidden:YES];
  
    [guillotineImage setDelays:0.0];
    [guillotineImage animateWithType:[NSNumber numberWithInt:GUILLOTINE]];
    [whiskersImage animateWithType:[NSNumber numberWithInt:WHISKERS]];
    [heatImage animateWithType:[NSNumber numberWithInt:HAT]];
    stDonate = [NSMutableString string];
    [MKStoreManager sharedManager].delegate = sharedHelper;
    [[LoginAnimatedViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusSimple];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstRun_v2.2"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    guillotineImage.stopAnimation = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)releaseComponents
{
    startViewController = nil;
    playerAccount = nil;
    stDonate = nil;
    activityView = nil;
    activityIndicatorView = nil;
    backgroundView = nil;
    boardImage = nil;
    tryAgainImage = nil;
    timer = nil;
    textsContainer = nil;
    player = nil;
    practiceButton = nil;
    animetedText = nil;
    loginFBbutton = nil;
    tryAgainView = nil;
    guillotineImage = nil;
    whiskersImage = nil;
    heatImage = nil;
    headImage = nil;
    noseImage = nil;
    practiceLable = nil;
    loginLable = nil;
    tryAgainLable = nil;
    tryAgainButton = nil;
}

#pragma mark Animations

- (void)updateLabels
{
  if (animationPause) return;
    
    NSString * text = (self.textIndex<=7)?[textsContainer objectAtIndex:self.textIndex]:@"";
    [UIView animateWithDuration:1.0
                     animations:^{
                        [self lableScaleOut];
                     } completion:^(BOOL complete) {
                         CGRect moveTextUp = textBackUp;
                         if (self.textIndex >= 5) moveTextUp.origin.y -= 100;
                         animetedText.frame = moveTextUp;
                         animetedText.bounds = moveTextUp;
                         animetedText.text = text;
                         [self performSelector:@selector(lableScaleIn) withObject:nil afterDelay:1.0];
                     }];
}

-(void)lableScaleIn
{
  if (animationPause) return;
  if (self.textIndex == 0) {
    [headImage setHidden:NO];
    [heatImage setHidden:YES];
    [noseImage setHidden:NO];
    [whiskersImage setHidden:NO];
    
  }
    [UIView animateWithDuration:0.5
                     animations:^{
                         animetedText.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL complete) {
                         [self.player setCurrentTime:0];
                         [self.player play];
                         if (self.textIndex<8){

                             if (self.textIndex==6) {                 ////"Pay for me $1.....
                                 [self scaleButton:practiceButton];   //Scale 1$
                                 [self scaleButton:practiceLable];

                             }
                             if (self.textIndex==7) {                 ////...or give me your ID"

                               [self scaleButton:loginFBbutton]; //Scale Facebook login
                               [self scaleButton:loginLable];
//                               [self.headImage setHidden:YES];
//                               [self.heatImage setHidden:NO];
//                               [self.noseImage setHidden:YES];
//                               [self.whiskersImage setHidden:YES];
                             }

                             [self performSelector:@selector(updateLabels) withObject:nil afterDelay:2.0];
                             self.textIndex++;
                         }
                         else {
                             if(tryAgain) return;
                             //[self.guillotineImage animateWithType:[NSNumber numberWithInt:FALL]];
                             //[self.heatImage performSelector:@selector(animateWithType:) withObject:[NSNumber numberWithInt:FALL] afterDelay:0.2];
                             [self performSelector:@selector(showTryAgain) withObject:nil afterDelay:0.7];
                             
                         }
                     }];
}

-(void)lableScaleOut
{
    animetedText.transform = CGAffineTransformMakeScale(0.01, 0.01);
}

-(void)scaleButton:(UIView *)button
{
    [UIView animateWithDuration:0.5 animations:^{
        button.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL complete) {
        [UIView animateWithDuration:0.5 animations:^{
            button.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }completion:^(BOOL complete){
//            [self updateLabels];
        } ];
        
    }];
}

-(void)showTryAgain
{
    tryAgain = YES;
    [tryAgainButton setHidden:NO];
    [tryAgainLable setHidden:NO];
    
    //[self.heatImage setHidden:YES];
    //[self.tryAgainView setHidden:NO];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)tryAgainButtonClick:(id)sender
{
    tryAgain = NO;
//    counterTryAgain++;
//    self.donateLable.text = [NSString stringWithFormat:(@"%@ %d$"),  NSLocalizedString(@"DONATE", @""),counterTryAgain];
//    CGRect frame = self.guillotineImage.frame;
//    frame.origin.y = -310;
//    self.guillotineImage.frame = frame;
    guillotineImage.stopAnimation = YES;
    [self.view.layer removeAllAnimations];
    for (CALayer* layer in [self.view.layer sublayers]) {
        [CATransaction begin];
        [layer removeAllAnimations];
        [CATransaction commit];
        
    }
    [guillotineImage.layer removeAllAnimations];
    for (CALayer* layer in [guillotineImage.layer sublayers]) {
        [CATransaction begin];
        [layer removeAllAnimations];
        [CATransaction commit];
    }
    [tryAgainButton setHidden:YES];
    [tryAgainLable setHidden:YES];
    guillotineImage.frame = guillBackUp;
    
    heatImage.frame = hatBackUp;
    [noseImage setHidden:NO];
    [tryAgainView setHidden:YES];
    [headImage setHidden:NO];
    [whiskersImage setHidden:NO];
    self.textIndex = 0;
    [self updateLabels];
    //self.guillotineImage.stopAnimation = NO;
    [guillotineImage performSelector:@selector(animateWithType:) withObject:[NSNumber numberWithInt:GUILLOTINE] afterDelay:0.5];
    if (sender) [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/first_login_again" forKey:@"event"]];
}
/*
- (IBAction)donateButtonClick:(id)sender {
    stDonate = [NSMutableString string];
    [self.player stop];
    [self.player setVolume:0.0];
    animationPause = YES;
    heatImage.stopAnimation = YES;
    whiskersImage.stopAnimation = YES;
    guillotineImage.stopAnimation = YES;
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
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"loginFirstShow"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  
    ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithAccount:playerAccount startViewController:startViewController];
    [profileViewController setNeedAnimation:YES];
    [self.navigationController popViewControllerAnimated:YES];
    [startViewController authorizationModifier:NO];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
//														object:self
//													  userInfo:[NSDictionary dictionaryWithObject:@"/donate_click" forKey:@"event"]];
}
*/

- (IBAction)practiceButtonClick:(id)sender {
    int randomTime = arc4random() % 6;
    AccountDataSource *oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer];
    [oponentAccount setAccountName:@"TestName"];
    ActiveDuelViewController *activeDuelViewController = [[ActiveDuelViewController alloc] initWithTime:randomTime Account:playerAccount oponentAccount:oponentAccount];
    [self.navigationController pushViewController:activeDuelViewController animated:YES];
}


- (IBAction)loginButtonClick:(id)sender {
//    [self.player stop];
//    [self.player setVolume:0.0];
    [activityView setHidden:NO];
    [activityIndicatorView startAnimating];
    animationPause = YES;
    heatImage.stopAnimation = YES;
    whiskersImage.stopAnimation = YES;
    guillotineImage.stopAnimation = YES;
    
    TestAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSessionWithAllowLoginUI:YES];
    
    
    
    [self initFacebook];
    
    [playerAccount cleareWeaponAndDefense];
    
//    TestAppDelegate *testAppDelegate = (TestAppDelegate *) [[UIApplication sharedApplication] delegate];
//    
//    [testAppDelegate setLoginViewController:self];
    
    DLog(@"fbLogIn");
    
    playerAccount.loginAnimatedViewController = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/login_FB" forKey:@"event"]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IPad"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

#pragma mark -


-(void)logOutFB;
{
    [self initFacebook];
    [[FBSession activeSession] closeAndClearTokenInformation];
	//[facebook logout:self];
  [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:@"/logOut_FB_click" forKey:@"event"]];
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
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"birthday,id,name,picture,location",@"fields",nil];
        //[[OGHelper sharedInstance] getCountOfUserFriends];
        
        [FBRequestConnection startWithGraphPath:@"me" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [self request:nil didLoad:result];
            DLog(@"%@ %@", result, error);
        }];
        //[self.facebook requestWithGraphPath:@"me" andParams:params andDelegate:self];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kCheckfFBLoginSession
                                                            object:self
                                                          userInfo:nil];
        
//        switch (loginFacebookStatus) {
//            case LoginFacebookStatusSimple:
//                [startViewController profileFirstRunButtonClickWithOutAnimation];
//                loginFacebookStatus = LoginFacebookStatusNone;
//                break;
//            case LoginFacebookStatusFeed:
//                if (startViewController.feedBackViewVisible) {
//                    [startViewController feedbackFacebookBtnClick:self];
//                }
//                loginFacebookStatus = LoginFacebookStatusNone;
//                break;
//            default:
//                break;
//        }
        [self.player setVolume:0.0];
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
        BOOL modifierUserInfo = YES;
//        if (([playerAccount.accountID rangeOfString:@"F:"].location != NSNotFound)&&[playerAccount putchAvatarImageSendInfo]) {
//            modifierUserInfo = YES;
//        }
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
        [self.player stop];
        [self.player setVolume:0.0];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IPad"];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"loginFirstShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        payment = NO;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self donateButtonClick:nil];
//        });
    }
}


- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	
    DLog(@"Facebook request failed: %@", [error description]);
	
	//[facebook logout:self];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    DLog(@"token extended");
    
//    facebook.accessToken = accessToken;
//    facebook.expirationDate = expiresAt;
    
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
//    [self donateButtonClick:nil];
    
}

- (void)failed
{
    [stDonate appendString:@"/error"];
    
    if (stDonate) [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                                      object:self
                                                                    userInfo:[NSDictionary dictionaryWithObject:stDonate forKey:@"event"]];
	[activityView setHidden:YES];
    [activityIndicatorView stopAnimating];
    animationPause = NO;
    heatImage.stopAnimation = NO;
    whiskersImage.stopAnimation = NO;
    guillotineImage.stopAnimation = NO;
    [heatImage setHidden:YES];
    [self tryAgainButtonClick:nil];
    [whiskersImage animateWithType:[NSNumber numberWithInt:WHISKERS]];
    [heatImage animateWithType:[NSNumber numberWithInt:HAT]];
}

- (void)viewDidUnload {
    practiceButton = nil;
    practiceLable = nil;
    [super viewDidUnload];
}
@end
