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
    __weak IBOutlet UIButton *loginFBbutton;
    __weak IBOutlet UILabel *practiceLable;
    __weak IBOutlet UILabel *loginLable;
    
    __weak IBOutlet UIView *textsBackground;
    
    
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
@synthesize delegate ,loginFacebookStatus, payment;
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
    loginLable.text = NSLocalizedString(@"LOGIN", @"");
    loginLable.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    practiceLable.text = NSLocalizedString(@"PRACTICE", @"");
    practiceLable.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
       
    [textsBackground setDinamicHeightBackground];
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
                    NSLocalizedString(@"INTRO1", nil),  //"Ye know who bounty hunters are, boy?";
                    NSLocalizedString(@"INTRO2", nil),  //"They chase criminals 'n get a reward for 'em,\ndead or alive";
                    NSLocalizedString(@"INTRO3", nil),  //"The harder to get these bastards are,\nthe bigger’s the reward for their head.";
                    NSLocalizedString(@"INTRO4", nil),  //"I'm one of the best hunters out there,\n 'n I could do with some help.";
                    NSLocalizedString(@"INTRO5", nil),  //"Seems yer tough enough for the job.";
                    NSLocalizedString(@"INTRO6", nil),  //"Come with me, help me get'em bad guys,\nand ye'll get yer freedom.";
                    NSLocalizedString(@"INTRO7", nil),  //"If yer good, yer gonna be a big bounty hunter,\njust like me.";
                    NSLocalizedString(@"INTRO8", nil),  //"Remember: their guns are fast.\nYe better be faster.";
                    nil];
    
    self.textIndex = 0;
    /*
    animetedText.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n",
                         NSLocalizedString(@"INTRO1", nil),
                         NSLocalizedString(@"INTRO2", nil),
                         NSLocalizedString(@"INTRO3", nil),
                         NSLocalizedString(@"INTRO4", nil),
                         NSLocalizedString(@"INTRO5", nil),
                         NSLocalizedString(@"INTRO6", nil),
                         NSLocalizedString(@"INTRO7", nil),
                         NSLocalizedString(@"INTRO8", nil)];
     */
    textBackUp = animetedText.frame;
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/kassa.aif", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.player setVolume:1.0];
    [self.player prepareToPlay];
  
    stDonate = [NSMutableString string];
    [[LoginAnimatedViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusSimple];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstRun_v2.2"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[StartViewController sharedInstance] playerStart];
    
    [self updateLabelsWithString:NSLocalizedString(@"1stIntro", @"")];
    self.textIndex++;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    int randomTime = (arc4random() % 3)-2;
    AccountDataSource *oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer];
    playerAccount.sessionID = @"-1";
    ActiveDuelViewController *activeDuelViewController = [[ActiveDuelViewController alloc] initWithTime:randomTime Account:playerAccount oponentAccount:oponentAccount];
    [self.navigationController pushViewController:activeDuelViewController animated:YES];
    activeDuelViewController = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/first_screen_teaching" forKey:@"event"]];
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
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/login_FB" forKey:@"event"]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IPad"];
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
    }
}


#pragma mark Animations

- (void)updateLabelsWithString: (NSString *)text
{
    if (animationPause) return;

    [animetedText setText:text];
    [animetedText setAlpha:0.0f];

    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         [animetedText setAlpha:1.0f];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:1.0f
                                               delay:2.0f
                                             options:UIViewAnimationCurveLinear
                                          animations:^{
                                               [animetedText setAlpha:0.0f];
                                          } completion:^(BOOL finished) {
                                              [animetedText setText:NSLocalizedString(@"2ndIntro", @"")];
                                              [UIView animateWithDuration:1.0f
                                                                    delay:0.0f
                                                                  options:UIViewAnimationCurveLinear animations:^{
                                                                      [animetedText setAlpha:1.0f];
                                                                  } completion:^(BOOL finished) {
                                                                      
                                                                  }];
                                          }];
                     }];

}

-(void)scaleButton:(UIView *)button
{
    [UIView animateWithDuration:0.4 animations:^{
        button.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL complete) {
        [UIView animateWithDuration:0.4 animations:^{
            button.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }completion:^(BOOL complete){
        } ];
    }];
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
                
        [FBRequestConnection startWithGraphPath:@"me" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [self request:nil didLoad:result];
            DLog(@"%@ %@", result, error);
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kCheckfFBLoginSession
                                                            object:self
                                                          userInfo:nil];
        
        [self.player setVolume:0.0];
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
        [self.player stop];
        [self.player setVolume:0.0];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IPad"];
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
    [super viewDidUnload];
}
@end
