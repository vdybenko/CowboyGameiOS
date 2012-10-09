//
//  ProfileViewController.m
//  Test
//
//  Created by Sobol on 11.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "AccountDataSource.h"
#import <QuartzCore/QuartzCore.h>
#import "OGHelper.h"
#import "GCHelper.h"
#import "UIButton+Image+Title.h"
#import "FinalViewController.h"
#import "UIImage+Save.h"
#import "LoginViewController.h"
#import "DuelRewardLogicController.h"
#import "LeaderBoardViewController.h"
#import "UIImage+Tint.h"


@interface ProfileViewController (private)
    -(void)setImageFromFacebook;
@end

@implementation ProfileViewController
@synthesize needAnimation, ivBlack;

-(id)initWithAccount:(AccountDataSource *)userAccount startViewController:(StartViewController *)startViewController;
{
    self = [super initWithNibName:@"ProfileViewController" bundle:[NSBundle mainBundle]];

    if (self) {
        needAnimation = NO;
        firstRun = NO;
        playerAccount=userAccount;
         
        loginViewController = [LoginViewController sharedInstance]; 
        loginViewController.startViewController = startViewController;
        
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

        
        [[GCHelper sharedInstance] reportScore:playerAccount.money forCategory:GC_LEADEBOARD_MONEY];
            
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(setImageFromFacebookWithHideIndicator)
                                                     name:kReceiveImagefromFBNotification 
                                                   object:nil];	
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(changeFBSesionAction)
                                                     name:kCheckfFBLoginSession 
                                                   object:nil];
        
        [self loadView];
        [self initMainControls];
    }
    return self;
}

-(id)initForFirstRunWithLoginVC:(LoginViewController*) pLoginViewController Account:(AccountDataSource *)userAccount;
{
    self = [super initWithNibName:@"ProfileViewController" bundle:[NSBundle mainBundle]];
    
    if (self) {
        
        firstRun = YES;
        playerAccount=userAccount;
        
        loginViewController=pLoginViewController;
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

        
        [self loadView];
        [self initMainControls];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated {
    lbGoldCount.text =[numberFormatter stringFromNumber:[NSNumber numberWithInt:(playerAccount.money/2)]];
    
//    [self initMainControls];
    [self checkLocationOfViewForFBLogin];
    
    didDisappear=NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    lbGoldCount.text =[numberFormatter stringFromNumber:[NSNumber numberWithInt:(playerAccount.money/2)]];
    
    CGRect liveChRect = ivPointsLine.frame;
    liveChRect.size.width=0;
    ivPointsLine.frame = liveChRect;
    
    didDisappear=YES;
}
-(void)initMainControls;
{    
    UIFont *titlesFont = [UIFont systemFontOfSize:12.0f];
    UIFont *NameFont = [UIFont  systemFontOfSize:18.0f];
    UIFont *CountFont = [UIFont systemFontOfSize:15.0f];
    
//    UIFont *fontSimpleText=[UIFont fontWithName: @"MyriadPro-Semibold" size:13];
    UIColor *mainColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    
    lbProfileMain.text = NSLocalizedString(@"ProfileTitle", @"");
    lbProfileMain.textColor = mainColor;
    lbProfileMain.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
   
    lbTitleTitle.text = NSLocalizedString(@"TitleTitle", @"");
    lbTitleTitle.font = titlesFont;
    
    lbPointsTitle.text = NSLocalizedString(@"PointsTitle", @"");
    lbPointsTitle.font = titlesFont;

    lbPointsCount.font = CountFont;
    
    lbGoldCount.font = NameFont;
    
    lbPlayerStats.text = NSLocalizedString(@"PlayerStatsTitle", @"");
    lbPlayerStats.font = CountFont;
    
    lbDuelsWon.text = NSLocalizedString(@"DuelsWonTitle", @"");
    lbDuelsWon.font = titlesFont;
    
    
    lbDuelsLost.text = NSLocalizedString(@"DuelsLostTitle", @"");
    lbDuelsLost.font = titlesFont;
    
    lbDuelsLostCount.font = CountFont;
    [lbDuelsLostCount dinamicAttachToView:lbDuelsLost withDirection:DirectionToAnimateRight ];
    
    lbBiggestWin.text = NSLocalizedString(@"TheBiggestWinGold", @"");
    lbBiggestWin.font = titlesFont;
    
    lbBiggestWinCount.font = CountFont;
//    [lbBiggestWinCount dinamicAttachToView:lbBiggestWin withDirection:DirectionToAnimateRight ];
    
    lbLeaderboardTitle.text = NSLocalizedString(@"LeaderboardTitle", @"");
    lbLeaderboardTitle.font = [UIFont fontWithName: @"DecreeNarrow" size:18];

    lbNotifyMessage.text = NSLocalizedString(@"SoundButton", @"");
    lbNotifyMessage.font = [UIFont systemFontOfSize:15];
    lbNotifyMessage.numberOfLines = 0;

    
    CGRect frame=btnLogInFB.frame; 
    frame.origin.x=33;
    frame.origin.y=-1;
    frame.size.width=frame.size.width-15;
    UILabel *label1 = [[UILabel alloc] initWithFrame:frame];
    [label1 setFont: [UIFont systemFontOfSize:9.0f]];
    label1.textAlignment = UITextAlignmentLeft; 
    [label1 setBackgroundColor:[UIColor clearColor]];
    [label1 setTextColor:[UIColor whiteColor]];
    [label1 setNumberOfLines:2];
    [label1 setLineBreakMode:UILineBreakModeWordWrap];
    [label1 setText:NSLocalizedString(@"LOGIN TO FACEBOOK", @"")];
    [btnLogInFB addSubview:label1]; 
    
    lbDuelsWonCount.font = CountFont;
    
    _lbMenuTitle.text = NSLocalizedString(@"BACK", @"");
    _lbMenuTitle.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    lbUserTitle.font = NameFont;
    
    lbFBName.font = NameFont;
    [lbFBName setDelegate:self];
    
    lbPlayerStats.font = CountFont;
   
    [ivPointsLine setClipsToBounds:YES];

    UIImageView *liveImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130 , 13)];
    [liveImage setImage:[UIImage imageNamed:@"pv_points.png"]];
    [ivPointsLine.layer addSublayer:liveImage.layer];
    
    [mainProfileView setDinamicHeightBackground];
//music button background change:

    
    if ([StartViewController sharedInstance].soundCheack )
        [_btnMusicContoller setImage:[UIImage imageNamed:@"pv_btn_music_on.png"] forState:UIControlStateNormal];
    else {
        [_btnMusicContoller setImage:[UIImage imageNamed:@"pv_btn_music_off.png"] forState:UIControlStateNormal];
    }

}

#pragma mark -
-(void)checkLocationOfViewForFBLogin;
{
    [self refreshContentFromPlayerAccount];
    NSUserDefaults *uDef=[NSUserDefaults standardUserDefaults];

    if (![uDef objectForKey:@"FBAccessTokenKey"]) {
        [btnLogOutFB setHidden:YES];
        [btnLogInFB setHidden:NO];
        [btnLeaderboard setEnabled:NO];
        _ivIconUser.contentMode = UIViewContentModeBottomLeft;
        _ivIconUser.image = [UIImage imageNamed:@"pv_photo_default.png"];
    }
    else 
    {
        _ivIconUser.contentMode = UIViewContentModeScaleAspectFit;
        [btnLogOutFB setHidden:NO];
        [btnLogInFB setHidden:YES];
        [btnLeaderboard setEnabled:YES];
        [self setImageFromFacebook];
    }
    lbFBName.text = playerAccount.accountName;
}

-(void)changePointsLine:(int)points maxValue:(int) maxValue animated:(BOOL)animated;
{
    if (maxValue==0) {
        [self animationOfMoney];
    }
    CGRect liveChRect = ivPointsLine.frame;
    liveChRect.size.width=0;
    ivPointsLine.frame = liveChRect;

    if (points <= 0) points = 0;
    int firstWidthOfLine=130;
    float changeWidth=(points*firstWidthOfLine)/maxValue;
    liveChRect.size.width = changeWidth;
    
    if (animated) {
        [self performSelector:@selector(animationOfMoney) withObject:nil afterDelay:0.75f];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES]; 
        [UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
        [UIView setAnimationDuration:1.5f];
        [UIView setAnimationDelegate:self];
        
        ivPointsLine.frame = liveChRect;
        [UIView commitAnimations];
    }else {
        ivPointsLine.frame = liveChRect;
    }
}

-(void)animationOfMoney;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self animateLabelShowText];
    });
    
}

-(void)animateLabelShowText {
    float goldForGoldAnimation;
    if (playerAccount.money<200) {
        goldForGoldAnimation=1;
    }else {
        goldForGoldAnimation=playerAccount.money/200;
    }
    for (int i=playerAccount.money/2; i<=playerAccount.money; i+=goldForGoldAnimation) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            lbGoldCount.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(i)]];
        });
        
        [NSThread sleepForTimeInterval:0.005];
        
        if(didDisappear){
            break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        lbGoldCount.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(playerAccount.money)]]; 
    });
    needAnimation = NO;
}
    
-(void)refreshContentFromPlayerAccount;
{
    // added for thousands separate   
    
    [lbDuelsWonCount dinamicAttachToView:lbDuelsWon withDirection:DirectionToAnimateRight ];
    
    NSArray *array=[DuelRewardLogicController getStaticPointsForEachLevels];
    
    if (playerAccount.accountLevel < 0 || playerAccount.accountLevel > 10 ){
        [playerAccount setAccountLevel:10];
    }

    NSInteger num = playerAccount.accountLevel;
    int  moneyForNextLevel=[[array objectAtIndex:num] intValue];
    
    int moneyForPrewLevel;
    if (playerAccount.accountLevel==0) {
        moneyForPrewLevel = 0;
    }else{
        moneyForPrewLevel=[[array objectAtIndex:(playerAccount.accountLevel-1)] intValue];
    }
    if (playerAccount.accountPoints>moneyForNextLevel) {
        playerAccount.accountPoints=moneyForPrewLevel;
        [[NSUserDefaults standardUserDefaults] setInteger:playerAccount.accountPoints forKey:@"lvlPoints"];
    }
    
    NSString *nameOfRank=[NSString stringWithFormat:@"%dRank",playerAccount.accountLevel];
    lbUserTitle.text = NSLocalizedString(nameOfRank, @"");
    
    if (playerAccount.accountPoints <= moneyForPrewLevel) {
        playerAccount.accountPoints = moneyForPrewLevel;
        [[NSUserDefaults standardUserDefaults] setInteger:playerAccount.accountPoints forKey:@"lvlPoints"];    
    }
    int curentPoints=(playerAccount.accountPoints-moneyForPrewLevel);
    int maxPoints=(moneyForNextLevel-moneyForPrewLevel);
    lbPointsCount.text = [NSString stringWithFormat:@"%d",(moneyForNextLevel-playerAccount.accountPoints)];

    if (!needAnimation) {
        lbGoldCount.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(playerAccount.money)]]; 
    }
    [self changePointsLine:curentPoints maxValue:maxPoints animated:needAnimation];
    
    DLog(@"Profile info points %d points to next level %d",playerAccount.accountPoints,(moneyForNextLevel-playerAccount.accountPoints));
    
    lbDuelsWonCount.text=[NSString stringWithFormat:@"%d",playerAccount.accountWins];
    lbDuelsLostCount.text=[NSString stringWithFormat:@"%d",playerAccount.accountDraws];
    
    lbBiggestWinCount.text=[numberFormatter stringFromNumber:[NSNumber numberWithInt:( playerAccount.accountBigestWin)]];
}

#pragma mark -
#pragma mark Delegate metods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    namePlayerSaved=[[NSString alloc] initWithString:textField.text];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length != 0){
        playerAccount.accountName = [NSString stringWithFormat:@"%@",  textField.text];
        NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
        [usrDef setObject:ValidateObject(playerAccount.accountName, [NSString class]) forKey:@"name"];
        [usrDef synchronize];
        [textField resignFirstResponder]; 
        if (![namePlayerSaved isEqualToString:textField.text]) {
            [loginViewController.startViewController authorizationModifier:YES];
        }
    }
    return YES;
}
#pragma mark ProfileWithLoginDelegate

//-(void)skipLoginFB;
//{
////    [_tfNick becomeFirstResponder];
//}
-(void)loginToFB;
{
    [self backToMenu:nil];
}
#pragma mark -

-(NSString *)description
{
    return @"Profile";
}

#pragma mark -

-(void)setImageFromFacebook
{
    NSString *pathToImage=[[OGHelper sharedInstance] apiGraphGetImage:@"me"];
    UIImage *image=[UIImage getImage:[pathToImage lastPathComponent]];
    [_ivIconUser setImage:image];
}

-(void)setImageFromFacebookWithHideIndicator
{
    [self setImageFromFacebook];
    [ivBlack setHidden:YES];
}

-(void)changeFBSesionAction
{
    needAnimation = YES;
    [self checkLocationOfViewForFBLogin];
    if (![[OGHelper sharedInstance] isAuthorized]) {
        [ivBlack setHidden:YES];
    }
}
#pragma mark - IBAction

-(IBAction)backToMenu:(id)sender;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveImagefromFBNotification object:nil];	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCheckfFBLoginSession object:nil];	

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"moneyForIPad"];
    
    [[NSUserDefaults standardUserDefaults] setObject:ValidateObject(playerAccount.typeImage, [NSString class]) forKey:@"typeImage"];
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromRight; //kCATransitionFromLeft, kCATransitionFromTop, kCATransitionFromTop,
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
}

- (IBAction)btnSoundClick:(id)sender {
    StartViewController *startViewController=[[self.navigationController viewControllers] objectAtIndex:0];
    [startViewController soundOff];
}

- (IBAction)btnFBLoginClick:(id)sender {
    [ivBlack setHidden:NO];
    [[LoginViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusSimple];
    [loginViewController fbLoginBtnClick:self];
}

- (IBAction)btnFBLogOutClick:(id)sender {
    [ivBlack setHidden:NO];
    [loginViewController logOutFB];
        
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *FilePath = [NSString stringWithFormat:@"%@/me.png",docDir];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSError *error= nil;
    if ([fileMgr removeItemAtPath:FilePath error:&error] != YES)
        DLog(@"Profile: Unable to delete file: %@", [error localizedDescription]);
}

- (IBAction)soundControll:(id)sender {
    StartViewController *startViewController = [[self.navigationController viewControllers] objectAtIndex:1];
    [startViewController soundOff];
    if (startViewController.soundCheack == YES) [_btnMusicContoller setImage:[UIImage imageNamed:@"pv_btn_music_on.png"] forState:UIControlStateNormal];
    else {
        [_btnMusicContoller setImage:[UIImage imageNamed:@"pv_btn_music_off.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)btnLeaderbordClick:(id)sender {
    TopPlayersViewController *topPlayersViewController =[[TopPlayersViewController alloc] initWithAccount:playerAccount];
    [self.navigationController pushViewController:topPlayersViewController animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"leaderBoard_click" forKey:@"event"]];
}

- (void)viewDidUnload {
    _lbMenuTitle = nil;
    lbProfileMain = nil;
    mainProfileView = nil;
    lbFBName = nil;
    lbTitleTitle = nil;
    lbUserTitle = nil;
    lbPointsCount = nil;
    lbGoldCount = nil;
    btnLogInFB = nil;
    btnLogOutFB = nil;
    btnLeaderboard = nil;
    lbPlayerStats = nil;
    lbDuelsWon = nil;
    lbDuelsWonCount = nil;
    lbDuelsLost = nil;
    lbDuelsLostCount = nil;
    lbBiggestWin = nil;
    lbBiggestWinCount = nil;
    lbNotifyMessage = nil;
    lbLeaderboardTitle = nil;
    [super viewDidUnload];
}

- (void)dealloc {
}
@end
