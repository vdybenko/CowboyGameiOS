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

#define kFacebookAppId @"284932561559672"
NSString *const URL_PAGE_IPAD_COMPETITION=@"http://cdfb.webkate.com/contest/first/";

@interface LoginAnimatedViewController ()
{
    StartViewController * startViewController;
    Facebook *facebook;
    AccountDataSource *playerAccount;
    NSMutableString *stDonate;
    __unsafe_unretained IBOutlet UIView *activityView;
    __unsafe_unretained IBOutlet UIActivityIndicatorView *activityIndicatorView;
    __unsafe_unretained IBOutlet UIImageView *backgroundView;
    __unsafe_unretained IBOutlet UIImageView *boardImage;
    __unsafe_unretained IBOutlet UIImageView *tryAgainImage;
    BOOL tryAgain;
    CGRect guillBackUp;
    CGRect textBackUp;
    CGRect hatBackUp;
    BOOL animationPause;
//    int counterTryAgain;
}
@property (nonatomic) int textIndex;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSArray *textsContainer;
@property (nonatomic) AVAudioPlayer *player;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *payButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *animetedText;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *loginFBbutton;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *tryAgainView;
@property (unsafe_unretained, nonatomic) IBOutlet BEAnimationView *guillotineImage;
@property (unsafe_unretained, nonatomic) IBOutlet BEAnimationView *whiskersImage;
@property (unsafe_unretained, nonatomic) IBOutlet BEAnimationView *heatImage;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *headImage;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *noseImage;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *donateLable;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *loginLable;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *tryAgainLable;

@end

@implementation LoginAnimatedViewController
NSString * const loginProduct=@"com.webkate.cowboyduels.user.registration";
@synthesize startViewController, facebook,delegate ,loginFacebookStatus, payment;
@synthesize timer, textsContainer;

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
        loginFacebookStatus = LoginFacebookStatusNone;
//    if (!counterTryAgain) {
//          counterTryAgain = 1;
//    }
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
        frame = self.guillotineImage.frame;
        frame.size.height = 558;
        frame.origin.y = -400;
        self.guillotineImage.frame = frame;
        [self.guillotineImage setImage:[UIImage imageNamed:@"ivGuillotineFull-568h.png"]];
        
    }
    else {
        [backgroundView setImage:[UIImage imageNamed:@"la_bg.png"]];
        [boardImage setImage:[UIImage imageNamed:@"la_board.png"]];
        [tryAgainImage setImage:[UIImage imageNamed:@"la_ta_bg.png"]];
        [self.guillotineImage setImage:[UIImage imageNamed:@"ivGuillotineFull.png"]];
    }
    self.loginLable.text = NSLocalizedString(@"LOGIN", @"");
    self.loginLable.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
//    self.donateLable.text = [NSString stringWithFormat:(@"%@ %d$"),  NSLocalizedString(@"DONATE", @""),counterTryAgain];
    self.donateLable.text = NSLocalizedString(@"DONATE 1$", @"");
    self.donateLable.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    self.tryAgainLable.text = NSLocalizedString(@"TRY AGAIN", @"");
    self.tryAgainLable.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    guillBackUp = self.guillotineImage.frame;
    textBackUp = self.animetedText.frame;
    hatBackUp = self.heatImage.frame;
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/kassa.aif", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.player setVolume:1.0];
    [self.player prepareToPlay];
    [self updateLabels];
  
    [self.headImage setHidden:YES];
    [self.heatImage setHidden:NO];
    [self.noseImage setHidden:YES];
    [self.whiskersImage setHidden:YES];
  
    [self.guillotineImage setDelays:0.0];
    [self.guillotineImage animateWithType:[NSNumber numberWithInt:GUILLOTINE]];
    [self.whiskersImage animateWithType:[NSNumber numberWithInt:WHISKERS]];
    [self.heatImage animateWithType:[NSNumber numberWithInt:HAT]];
    stDonate = [NSMutableString string];
    [MKStoreManager sharedManager].delegate = sharedHelper;
    [[LoginAnimatedViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusSimple];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                         self.animetedText.frame = moveTextUp;
                         self.animetedText.bounds = moveTextUp;
                         self.animetedText.text = text;
                         [self performSelector:@selector(lableScaleIn) withObject:nil afterDelay:1.0];
                     }];
}

-(void)lableScaleIn
{
  if (animationPause) return;
  if (self.textIndex == 0) {
    [self.headImage setHidden:NO];
    [self.heatImage setHidden:YES];
    [self.noseImage setHidden:NO];
    [self.whiskersImage setHidden:NO];
    
  }
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.animetedText.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL complete) {
                         [self.player setCurrentTime:0];
                         [self.player play];
                         if (self.textIndex<8){

                             if (self.textIndex==6) {                 ////"Pay for me $1...
                                 [self scaleButton:self.payButton];   //Scale 1$
                                 [self scaleButton:self.donateLable];

                             }
                             if (self.textIndex==7) {                 ////...or give me your ID"

                               [self scaleButton:self.loginFBbutton]; //Scale Facebook login
                               [self scaleButton:self.loginLable];
                               [self.headImage setHidden:YES];
                               [self.heatImage setHidden:NO];
                               [self.noseImage setHidden:YES];
                               [self.whiskersImage setHidden:YES];
                             }

                             [self performSelector:@selector(updateLabels) withObject:nil afterDelay:2.0];
                             self.textIndex++;
                         }
                         else {
                             if(tryAgain) return;
                             [self.guillotineImage animateWithType:[NSNumber numberWithInt:FALL]];
                             [self.heatImage performSelector:@selector(animateWithType:) withObject:[NSNumber numberWithInt:FALL] afterDelay:0.2];
                             [self performSelector:@selector(showTryAgain) withObject:nil afterDelay:0.7];
                         }
                     }];
}

-(void)lableScaleOut
{
    self.animetedText.transform = CGAffineTransformMakeScale(0.01, 0.01);
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
    [self.heatImage setHidden:YES];
    [self.tryAgainView setHidden:NO];
}

- (IBAction)tryAgainButtonClick:(id)sender
{
    tryAgain = NO;
//    counterTryAgain++;
//    self.donateLable.text = [NSString stringWithFormat:(@"%@ %d$"),  NSLocalizedString(@"DONATE", @""),counterTryAgain];
//    CGRect frame = self.guillotineImage.frame;
//    frame.origin.y = -310;
//    self.guillotineImage.frame = frame;

    self.guillotineImage.frame = guillBackUp;
    self.guillotineImage.stopAnimation = NO;
    self.heatImage.frame = hatBackUp;
    [self.noseImage setHidden:NO];
    [self.tryAgainView setHidden:YES];
    [self.headImage setHidden:NO];
    [self.whiskersImage setHidden:NO];
    self.textIndex = 0;
    [self updateLabels];
    [self.guillotineImage animateWithType:[NSNumber numberWithInt:GUILLOTINE]];
    if (sender) [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/first_login_again" forKey:@"event"]];
}

- (IBAction)donateButtonClick:(id)sender {
    [self.player stop];
    [self.player setVolume:0.0];
    animationPause = YES;
    self.heatImage.stopAnimation = YES;
    self.whiskersImage.stopAnimation = YES;
    self.guillotineImage.stopAnimation = YES;
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

- (IBAction)loginButtonClick:(id)sender {
//    [self.player stop];
//    [self.player setVolume:0.0];
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

#pragma mark -


-(void)logOutFB;
{
    [self initFacebook];
	[facebook logout:self];
  [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:@"/logOut_FB_click" forKey:@"event"]];
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
        [self.player setVolume:0.0];
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
        [self.player stop];
        [self.player setVolume:0.0];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IPad"];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"loginFirstShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
    [self donateButtonClick:nil];
    
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
    self.heatImage.stopAnimation = NO;
    self.whiskersImage.stopAnimation = NO;
    self.guillotineImage.stopAnimation = NO;
    [self.heatImage setHidden:YES];
    [self tryAgainButtonClick:nil];
    [self.whiskersImage animateWithType:[NSNumber numberWithInt:WHISKERS]];
    [self.heatImage animateWithType:[NSNumber numberWithInt:HAT]];
}

- (void)viewDidUnload {
    [self setAnimetedText:nil];
    [self setPayButton:nil];
    [self setLoginFBbutton:nil];
    [self setTryAgainView:nil];
    [self setGuillotineImage:nil];
    [self setWhiskersImage:nil];
    [self setHeatImage:nil];
    [self setHeadImage:nil];
    [self setNoseImage:nil];
    [CATransaction begin];
    [self.view.layer removeAllAnimations];
    [CATransaction commit];
    [self setDonateLable:nil];
    [self setLoginLable:nil];
    [self setTryAgainLable:nil];
    [self setPlayer:nil];
    backgroundView = nil;
    boardImage = nil;
    tryAgainImage = nil;
    [super viewDidUnload];
}
@end
