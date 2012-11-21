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
#import "UIImage+Save.h"
#import "LoginAnimatedViewController.h"
#import "DuelRewardLogicController.h"
#import "TopPlayersViewController.h"

@interface ProfileViewController ()
{
    AccountDataSource *playerAccount;
    LoginAnimatedViewController *loginViewController;
    
    NSString *namePlayerSaved;
    
    IBOutlet UIImageView *_ivIconUser;
    
    //Labels
    IBOutlet UILabel *lbProfileMain;
    IBOutlet UIView *mainProfileView;
    IBOutlet UITextField *lbFBName;
    IBOutlet UILabel *lbUserTitle;
    
    IBOutlet UIView *ivPointsLine;
    
    IBOutlet UILabel *lbGoldCount;
    
    IBOutlet UIButton *btnLogInFB;
    IBOutlet UIButton *btnLogOutFB;
    
    IBOutlet UIButton *btnLeaderboard;
    IBOutlet UIButton *btnBack;
    IBOutlet UILabel *lbPlayerStats;
    IBOutlet UILabel *lbDuelsWon;
    IBOutlet UILabel *lbDuelsWonCount;
    IBOutlet UILabel *lbDuelsLost;
    IBOutlet UILabel *lbDuelsLostCount;
    IBOutlet UILabel *lbBiggestWin;
    IBOutlet UILabel *lbBiggestWinCount;
    IBOutlet UILabel *lbNotifyMessage;
    IBOutlet UILabel *lbLeaderboardTitle;
    IBOutlet UILabel *_lbMenuTitle;
    
    IBOutlet UIView *userAtackView;
    IBOutlet UIView *userDefenseView;
    IBOutlet UILabel *userAtack;
    IBOutlet UILabel *userDefense;
    
    
    __unsafe_unretained IBOutlet UILabel *lbPointsCountMain;
    __unsafe_unretained IBOutlet UIImageView *ivCurrentRank;
    //Buttons    
    IBOutlet UIView *ivBlack;
    
    __unsafe_unretained IBOutlet UILabel *lbPointsText;
    NSNumberFormatter *numberFormatter;
    
    BOOL didDisappear;
    
//    First run
    int textIndex;
    IBOutlet UILabel *lbDescription;
    NSArray *textsContainer;
}
    -(void)setImageFromFacebook;
@end

@implementation ProfileViewController
@synthesize needAnimation, ivBlack;

#pragma mark

-(id)initWithAccount:(AccountDataSource *)userAccount startViewController:(StartViewController *)startViewController;
{
    self = [super initWithNibName:@"ProfileViewController" bundle:[NSBundle mainBundle]];

    if (self) {
        needAnimation = NO;
        playerAccount=userAccount;
         
        loginViewController = [LoginAnimatedViewController sharedInstance]; 
        loginViewController.startViewController = startViewController;
        
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

        // added for GC
        if (![GCHelper sharedInstance].GClocalPlayer.isAuthenticated && ![startViewController firstRun]) {
          [[GCHelper sharedInstance] authenticateLocalUser];
        

          [[GCHelper sharedInstance] reportScore:playerAccount.money forCategory:GC_LEADEBOARD_MONEY];
        }
        // above    
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

-(id)initFirstStartWithAccount:(AccountDataSource *)userAccount startViewController:(StartViewController *)startViewController;
{
    self = [super initWithNibName:@"ProfileViewControllerFirstRun" bundle:[NSBundle mainBundle]];
    
    if (self) {
        needAnimation = NO;
        playerAccount=userAccount;
        
        loginViewController = [LoginAnimatedViewController sharedInstance];
        loginViewController.startViewController = startViewController;
        
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        // added for GC
        if (![GCHelper sharedInstance].GClocalPlayer.isAuthenticated && ![startViewController firstRun]) {
            [[GCHelper sharedInstance] authenticateLocalUser];
            
            
            [[GCHelper sharedInstance] reportScore:playerAccount.money forCategory:GC_LEADEBOARD_MONEY];
        }
        // above
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setImageFromFacebookWithHideIndicator)
                                                     name:kReceiveImagefromFBNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeFBSesionAction)
                                                     name:kCheckfFBLoginSession
                                                   object:nil];
        
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
        textIndex = 0;

        [self loadView];
        [self initMainControls];
        lbDescription.hidden = NO;
        lbDescription.text =@"123";
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"loginFirstShow"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated {
    lbPointsText.font = [UIFont fontWithName: @"MyriadPro-Semibold" size:12];
    
    lbPointsCountMain.font = [UIFont fontWithName: @"MyriadPro-Bold" size:15];
    lbGoldCount.text =[numberFormatter stringFromNumber:[NSNumber numberWithInt:(playerAccount.money/2)]];
    
    [self checkLocationOfViewForFBLogin];
    NSString *name = [NSString stringWithFormat:@"fv_img_%drank.png", playerAccount.accountLevel];
    ivCurrentRank.image = [UIImage imageNamed:name];
    didDisappear=NO;
    
    [self updateLabels];
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
    
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    [btnBack setTitleByLabel:@"BACK" withColor:buttonsTitleColor];
    
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

    [mainProfileView setDinamicHeightBackground];
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
    SSConnection *connection = [SSConnection sharedInstance];
    [connection sendInfoPacket];
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
        [self animateLabel:lbGoldCount toValue:playerAccount.money];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self animateLabel:lbPointsCountMain toValue:playerAccount.accountPoints];
    });

    
}

-(void)animateLabel:(UILabel *)label toValue:(int)value {
    float valueForGoldAnimation;
    if (value<200) {
        valueForGoldAnimation=1;
    }else {
        valueForGoldAnimation=value/200;
    }
    for (int i=value/2; i<=value; i+=valueForGoldAnimation) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(label == lbPointsCountMain)
            label.text = [NSString stringWithFormat:@"%@/%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:(i)]], [[DuelRewardLogicController getStaticPointsForEachLevels] objectAtIndex:playerAccount.accountLevel]];
            else label.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(i)]];
            
        });
        
        [NSThread sleepForTimeInterval:0.005];
        
        if(didDisappear){
            break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(label == lbPointsCountMain)
            label.text = [NSString stringWithFormat:@"%@/%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:(value)]], [[DuelRewardLogicController getStaticPointsForEachLevels] objectAtIndex:playerAccount.accountLevel]];
        else label.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(value)]];
    });
    needAnimation = NO;
}
    
-(void)refreshContentFromPlayerAccount;
{
    // added for thousands separate   
    
    [lbDuelsWonCount dinamicAttachToView:lbDuelsWon withDirection:DirectionToAnimateRight ];
    
    NSArray *array=[DuelRewardLogicController getStaticPointsForEachLevels];
    
    if (playerAccount.accountLevel < 0 || playerAccount.accountLevel > 9 ){
        [playerAccount setAccountLevel:9];
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
        [playerAccount saveAccountPoints];
    }
    
    NSString *nameOfRank=[NSString stringWithFormat:@"%dRank",playerAccount.accountLevel];
    lbUserTitle.text = NSLocalizedString(nameOfRank, @"");
    
    if (playerAccount.accountPoints <= moneyForPrewLevel) {
        playerAccount.accountPoints = moneyForPrewLevel;
        [playerAccount saveAccountPoints];
    }
    int curentPoints=playerAccount.accountPoints;
    int maxPoints=moneyForNextLevel;

    if (!needAnimation) {
        lbGoldCount.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(playerAccount.money)]]; 
    }
    [self changePointsLine:curentPoints maxValue:maxPoints animated:needAnimation];
    
    DLog(@"Profile info points %d points to next level %d",playerAccount.accountPoints,(moneyForNextLevel-playerAccount.accountPoints));
    
    lbDuelsWonCount.text=[NSString stringWithFormat:@"%d",playerAccount.accountWins];
    lbDuelsLostCount.text=[NSString stringWithFormat:@"%d",playerAccount.accountDraws];
    
    lbBiggestWinCount.text=[numberFormatter stringFromNumber:[NSNumber numberWithInt:( playerAccount.accountBigestWin)]];
    
    if (playerAccount.accountWeapon.dDamage!=0) {
        userAtack.text = [NSString stringWithFormat:@"+%d",playerAccount.accountWeapon.dDamage];
        userAtackView.hidden = NO;
    }
    if (playerAccount.accountDefenseValue!=0) {
        userDefense.text = [NSString stringWithFormat:@"+%d",playerAccount.accountDefenseValue];
        userDefenseView.hidden = NO;
    }
}

-(void)checkValidBlackActivity{
    if ((![ivBlack isHidden])&&(![[OGHelper sharedInstance] isAuthorized])) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveImagefromFBNotification object:nil];	
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kCheckfFBLoginSession object:nil];	
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"moneyForIPad"];
        
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:NO];
    }
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
        const char *name = [textField.text cStringUsingEncoding:NSUTF8StringEncoding];
        playerAccount.accountName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
      
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
    UIImage *image=[UIImage loadImageFromDocumentDirectory:[pathToImage lastPathComponent]];
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
#pragma mark Animation description

- (void)updateLabels
{
    NSString * text = (textIndex<=7)?[textsContainer objectAtIndex:textIndex]:@"";
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         [self lableScaleOut];
                     } completion:^(BOOL complete) {
                         lbDescription.text = text;
                         [self performSelector:@selector(lableScaleIn) withObject:nil afterDelay:1.0];
                     }];
}

-(void)lableScaleIn
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         if (textIndex<8){
                             lbDescription.transform = CGAffineTransformMakeScale(1.0, 1.0);
                             [self performSelector:@selector(updateLabels) withObject:nil afterDelay:2.0];
                             textIndex++;
                         }
                     }];
}

-(void)lableScaleOut
{
    lbDescription.transform = CGAffineTransformMakeScale(0.01, 0.01);
}

-(void)scaleButton:(UIView *)button
{
    [UIView animateWithDuration:0.5 animations:^{
        button.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL complete) {
        [UIView animateWithDuration:0.5 animations:^{
            button.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }completion:^(BOOL complete){
        } ];
    }];
}

#pragma mark - IBAction

-(IBAction)backToMenu:(id)sender;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveImagefromFBNotification object:nil];	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCheckfFBLoginSession object:nil];	

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"moneyForIPad"];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; 
    transition.subtype = kCATransitionFromRight;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
}

- (IBAction)btnSoundClick:(id)sender {
    StartViewController *startViewController=[[self.navigationController viewControllers] objectAtIndex:0];
    [startViewController soundOff];
}

- (IBAction)btnFBLoginClick:(id)sender {
    [ivBlack setHidden:NO];
    [[LoginAnimatedViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusSimple];
    [loginViewController loginButtonClick:self];
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


- (IBAction)btnLeaderbordClick:(id)sender {
    TopPlayersViewController *topPlayersViewController =[[TopPlayersViewController alloc] initWithAccount:playerAccount];
    [self.navigationController pushViewController:topPlayersViewController animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/leaderBoard_click" forKey:@"event"]];
}

- (void)viewDidUnload {
    _lbMenuTitle = nil;
    lbProfileMain = nil;
    mainProfileView = nil;
    lbFBName = nil;
    lbUserTitle = nil;
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
    lbPointsCountMain = nil;
    ivCurrentRank = nil;
    lbPointsText = nil;
    [super viewDidUnload];
}

- (void)dealloc {
}
@end
