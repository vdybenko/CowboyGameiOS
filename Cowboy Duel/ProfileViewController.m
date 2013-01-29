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
#import "SSServer.h"
#import "DuelStartViewController.h"
#import "StoreViewController.h"
#import "ActiveDuelViewController.h"

static const CGFloat changeYPointWhenKeyboard = 155;
static const CGFloat timeToStandartTitles = 1.8;

@interface ProfileViewController ()
{
    AccountDataSource *playerAccount;
    LoginAnimatedViewController *loginViewController;
    
    SSServer *playerServer;
    
    IconDownloader *iconDownloader;
    
    NSString *namePlayerSaved;
    
    __weak IBOutlet UIImageView *_ivIconUser;
    
    //Labels
    __weak IBOutlet UILabel *lbProfileMain;
    __weak IBOutlet UIView *mainProfileView;
    __weak IBOutlet UITextField *tfFBName;
    __weak IBOutlet UILabel *lbUserTitle;
    
    __weak IBOutlet UIView *ivPointsLine;
    
    __weak IBOutlet UILabel *lbGoldCount;
    __weak IBOutlet UIImageView *lbGoldIcon;
    
    __weak IBOutlet UILabel *lbWantedText;
    __weak IBOutlet UILabel *lbWantedTitle;
    __weak IBOutlet UILabel *lbAward;
    
    __weak IBOutlet UIButton *btnLogInFB;
    __weak IBOutlet UIButton *btnLogOutFB;
    
    __weak IBOutlet UIButton *btnLeaderboard;
    __weak IBOutlet UIButton *btnLeaderboardBig;
    __weak IBOutlet UIButton *btnBack;
    __weak IBOutlet UILabel *lbPlayerStats;
    __weak IBOutlet UILabel *lbDuelsWon;
    __weak IBOutlet UILabel *lbDuelsWonCount;
    __weak IBOutlet UILabel *lbDuelsLost;
    __weak IBOutlet UILabel *lbDuelsLostCount;
    __weak IBOutlet UILabel *lbBiggestWin;
    __weak IBOutlet UILabel *lbBiggestWinCount;
    __weak IBOutlet UILabel *lbLeaderboardTitle;
    
    __weak IBOutlet UIView *userAtackView;
    __weak IBOutlet UIView *userDefenseView;
    __weak IBOutlet UILabel *userAtack;
    __weak IBOutlet UILabel *userDefense;
    __weak IBOutlet FBProfilePictureView *profilePictureView;
    
    __weak IBOutlet UIImageView *profilePictureViewDefault;
    __weak IBOutlet UIButton *duelButton;
    
    __weak IBOutlet UILabel *lbPointsCountMain;
    __weak IBOutlet UIImageView *ivCurrentRank;
    
    __weak IBOutlet UILabel *lbPointsText;
    NSNumberFormatter *numberFormatter;
    
    BOOL didDisappear;
    BOOL needMoneyAnimation;
    
//    First run
    int textIndex;
    __weak IBOutlet UILabel *lbDescription;
    NSMutableArray *textsContainer;
}
-(void)setImageFromFacebook;
-(IBAction)showStoreWeapon:(id)sender;
-(IBAction)showStoreDefence:(id)sender;
@end

@implementation ProfileViewController
@synthesize needAnimation, ivBlack;

#pragma mark

-(id)initWithAccount:(AccountDataSource *)userAccount startViewController:(StartViewController *)startViewController;
{
    self = [super initWithNibName:@"ProfileViewController" bundle:[NSBundle mainBundle]];

    if (self) {
        needAnimation = NO;
        needMoneyAnimation = YES;
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
                                                     name:SCSessionStateChangedNotification
                                                   object:nil];
        
        [self loadView];
        UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
        [btnBack setTitleByLabel:@"BACK" withColor:buttonsTitleColor fontSize:24];
        [btnLeaderboardBig setTitleByLabel:@"LeaderboardTitle" withColor:buttonsTitleColor fontSize:24];
       ;
        
        [self initMainControls];
        [self checkLocationOfViewForFBLogin];
    }
    return self;
}

-(id)initForOponent:(AccountDataSource *)oponentAccount
{
    self = [super initWithNibName:@"ProfileViewControllerWanted" bundle:[NSBundle mainBundle]];
    
    if (self) {
        needAnimation = NO;
        needMoneyAnimation = NO;
        playerAccount=oponentAccount;
        
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        [self loadView];
        UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
        [btnBack setTitleByLabel:@"BACK" withColor:buttonsTitleColor fontSize:24];
        [btnLeaderboardBig setTitleByLabel:@"LeaderboardTitle" withColor:buttonsTitleColor fontSize:24];
        [duelButton setTitleByLabel:@"DUEL"];
        [duelButton changeColorOfTitleByLabel:buttonsTitleColor];
        
        needAnimation = YES;
        [self initMainControls];
        
        lbProfileMain.text = NSLocalizedString(@"WANTED", @"");
        [lbWantedTitle setFont: [UIFont fontWithName: @"DecreeNarrow" size:lbProfileMain.font.pointSize]];
        lbWantedTitle.text = NSLocalizedString(@"DOL", @"");
        [lbAward setFont: [UIFont fontWithName: @"DecreeNarrow" size:lbAward.font.pointSize]];
        lbAward.text = NSLocalizedString(@"AWARD", @"");
        [lbWantedText setFont: [UIFont fontWithName: @"DecreeNarrow" size:lbWantedText.font.pointSize]];
        lbWantedText.text = NSLocalizedString(@"ForBody", @"");
        
        int moneyExch  = playerAccount.money < 10 ? 1: playerAccount.money / 10.0;
        lbGoldCount.text = [NSString stringWithFormat:@"%d$",moneyExch];
        [lbGoldCount setFont: [UIFont  systemFontOfSize:25.0f]];
                
        [tfFBName setFont: [UIFont fontWithName: @"DecreeNarrow" size:30]];
        tfFBName.text = [NSString stringWithFormat:@"\"%@\"",playerAccount.accountName];
        
//avatar magic!
        NSString *name = [[OGHelper sharedInstance ] getClearName:playerAccount.accountID];
        if ([playerAccount.accountID rangeOfString:@"A"].location != NSNotFound){
            iconDownloader = [[IconDownloader alloc] init];
            iconDownloader.namePlayer=name;
            iconDownloader.delegate = self;
            [iconDownloader setAvatarURL:playerAccount.avatar];
            [iconDownloader startDownloadSimpleIcon];
        }
        
        if ([playerAccount.accountID rangeOfString:@"F"].location != NSNotFound) {
            iconDownloader = [[IconDownloader alloc] init];
            
            iconDownloader.namePlayer=name;
            iconDownloader.delegate = self;
            if ([playerAccount.avatar isEqualToString:@""]) {
                NSString *urlOponent=[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",name];
                [iconDownloader setAvatarURL:urlOponent];
            }else {
                [iconDownloader setAvatarURL:playerAccount.avatar];
            }
            [iconDownloader startDownloadSimpleIcon];
        }else {
            profilePictureViewDefault.image = [UIImage imageNamed:@"pv_photo_default.png"];
            profilePictureViewDefault.transform = CGAffineTransformIdentity;
            profilePictureViewDefault.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            
        }
//        
        
    }
    return self;
}

-(id)initFirstStartWithAccount:(AccountDataSource *)userAccount startViewController:(StartViewController *)startViewController;
{
    self = [super initWithNibName:@"ProfileViewControllerFirstRun" bundle:[NSBundle mainBundle]];
    
    if (self) {
        needAnimation = NO;
        needMoneyAnimation = YES;
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
                                                     name:SCSessionStateChangedNotification
                                                   object:nil];
        
        textsContainer = [NSMutableArray arrayWithObjects:
                          NSLocalizedString(@"PROFILE_MESS_1_THANKS", nil),
                          [NSString stringWithFormat:NSLocalizedString(@"PROFILE_MESS_2_NAME", nil),playerAccount.accountName],
                          NSLocalizedString(@"PROFILE_MESS_3_NAME", nil),            
                          NSLocalizedString(@"PROFILE_MESS_4_SALOON", nil),          
                          NSLocalizedString(@"PROFILE_MESS_5_LEAD", nil),         
                          NSLocalizedString(@"PROFILE_MESS_6_GOLD", nil),
                          NSLocalizedString(@"PROFILE_MESS_7_LETS", nil),
                          nil];
        
        textIndex = 0;
        [self loadView];
        UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
        [btnBack setTitleByLabel:@"CONTINUE" withColor:buttonsTitleColor fontSize:24];
        [btnLeaderboardBig setTitleByLabel:@"LeaderboardTitle" withColor:buttonsTitleColor fontSize:24];
        [self initMainControls];
        lbDescription.hidden = NO;
        [self checkLocationOfViewForFBLogin];
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
    [profilePictureView setProfileID:nil];
    [profilePictureView setProfileID:playerAccount.facebookUser.id];
    lbPointsText.font = [UIFont fontWithName: @"MyriadPro-Semibold" size:12];

//    NSString *name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel];
//    ivCurrentRank.image = [UIImage imageNamed:name];
    didDisappear=NO;
    
    if (![lbDescription isHidden] && lbDescription) {
        [self updateLabels];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    
//    lbGoldCount.text =[numberFormatter stringFromNumber:[NSNumber numberWithInt:(playerAccount.money/2)]];
    
    CGRect liveChRect = ivPointsLine.frame;
    liveChRect.size.width=0;
    ivPointsLine.frame = liveChRect;
    
    didDisappear=YES;
}

-(void)releaseComponents
{
    playerAccount = nil;
    playerServer = nil;
    iconDownloader = nil;
    namePlayerSaved = nil;
    _ivIconUser = nil;
    lbProfileMain = nil;
    mainProfileView = nil;
    tfFBName = nil;
    lbUserTitle = nil;
    ivPointsLine = nil;
    lbGoldCount = nil;
    lbGoldIcon = nil;
    lbAward = nil;
    btnLogInFB = nil;
    btnLogOutFB = nil;
    btnLeaderboard = nil;
    btnLeaderboardBig = nil;
    btnBack = nil;
    lbPlayerStats = nil;
    lbDuelsWon = nil;
    lbDuelsWonCount = nil;
    lbDuelsLost = nil;
    lbDuelsLostCount = nil;
    lbBiggestWin = nil;
    lbBiggestWinCount = nil;
    lbLeaderboardTitle = nil;
    userAtackView = nil;
    userDefenseView = nil;
    userAtack = nil;
    userDefense = nil;
    profilePictureView = nil;
    profilePictureViewDefault = nil;
    duelButton = nil;
    lbPointsCountMain = nil;
    ivCurrentRank = nil;
    ivBlack = nil;
    lbPointsText = nil;
    numberFormatter  = nil;
}

-(void)initMainControls;
{    
    UIFont *titlesFont = [UIFont systemFontOfSize:12.0f];
    UIFont *NameFont = [UIFont  systemFontOfSize:18.0f];
    UIFont *CountFont = [UIFont systemFontOfSize:15.0f];
    
//    UIFont *fontSimpleText=[UIFont fontWithName: @"MyriadPro-Semibold" size:13];
    UIColor *mainColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    
    _ivIconUser.clipsToBounds = YES;
    
    lbProfileMain.text = NSLocalizedString(@"ProfileTitle", @"");
    lbProfileMain.textColor = mainColor;
    lbProfileMain.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
    lbGoldCount.font = NameFont;
    lbGoldCount.text =[numberFormatter stringFromNumber:[NSNumber numberWithInt:(playerAccount.money/2)]];
    
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
    
    lbPointsCountMain.font = [UIFont fontWithName: @"MyriadPro-Bold" size:15];
    
    lbBiggestWinCount.font = CountFont;
//    [lbBiggestWinCount dinamicAttachToView:lbBiggestWin withDirection:DirectionToAnimateRight ];
    
    lbLeaderboardTitle.text = NSLocalizedString(@"LeaderboardTitle", @"");
    lbLeaderboardTitle.font = [UIFont fontWithName: @"DecreeNarrow" size:18];

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
    label1 = nil;
    lbDuelsWonCount.font = CountFont;
    
    lbUserTitle.font = [UIFont  systemFontOfSize:lbUserTitle.font.pointSize];;
    
    tfFBName.font = NameFont;
    [tfFBName setDelegate:self];
    
    lbPlayerStats.font = CountFont;
   
    [ivPointsLine setClipsToBounds:YES];

    [mainProfileView setDinamicHeightBackground];

}

#pragma mark -
-(void)checkLocationOfViewForFBLogin;
{
    [self refreshContentFromPlayerAccount];
    NSUserDefaults *uDef=[NSUserDefaults standardUserDefaults];
    [profilePictureView setProfileID:nil];
    [profilePictureView setProfileID:playerAccount.facebookUser.id];
    if (![uDef objectForKey:@"FBAccessTokenKey"]) {
        [btnLogOutFB setHidden:YES];
        [btnLogInFB setHidden:NO];
        [btnLeaderboard setEnabled:NO];
        [profilePictureView setHidden:YES];
        profilePictureViewDefault.contentMode = UIViewContentModeScaleAspectFit;
        //profilePictureViewDefault.contentMode = UIViewContentModeBottomLeft;
        profilePictureViewDefault.image = [UIImage imageNamed:@"pv_photo_default.png"];
        [profilePictureViewDefault setHidden:NO];
    }
    else 
    {
        [profilePictureView setHidden:NO];
        [profilePictureViewDefault setHidden:YES];
        profilePictureViewDefault.contentMode = UIViewContentModeScaleAspectFit;
        [btnLogOutFB setHidden:NO];
        [btnLogInFB setHidden:YES];
        [btnLeaderboard setEnabled:YES];
        [self setImageFromFacebook];
    }
    if(!duelButton.isHidden){
        [btnLogOutFB setHidden:YES];
        [btnLogInFB setHidden:YES];
    }
    
    NSString *name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel];
    ivCurrentRank.image = [UIImage imageNamed:name];
    tfFBName.text = playerAccount.accountName;
    if([textsContainer count]){
        [textsContainer replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:NSLocalizedString(@"PROFILE_MESS_2_NAME", nil),playerAccount.accountName]];
    }
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
    int firstWidthOfLine=121;
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
    if (playerAccount.accountLevel != kCountOfLevels) {
        lbPointsCountMain.text = [NSString stringWithFormat:@"%@/%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:playerAccount.accountPoints]], [[DuelRewardLogicController getStaticPointsForEachLevels] objectAtIndex:playerAccount.accountLevel]];
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//            [self animateLabel:lbPointsCountMain toValue:playerAccount.accountPoints];
//        });
    }
    
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
            else
                label.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(i)]];
        });
        
        [NSThread sleepForTimeInterval:0.005];
        
        if(didDisappear){
            break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(label == lbPointsCountMain)
            label.text = [NSString stringWithFormat:@"%@/%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:(value)]], [[DuelRewardLogicController getStaticPointsForEachLevels] objectAtIndex:playerAccount.accountLevel]];
        else
            label.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(value)]];
    });
    needAnimation = NO;
}
    
-(void)refreshContentFromPlayerAccount;
{
    // added for thousands separate   
    [ivBlack setHidden:YES];
    [lbDuelsWonCount dinamicAttachToView:lbDuelsWon withDirection:DirectionToAnimateRight ];
    NSString *nameOfRank=[NSString stringWithFormat:@"%dRank",playerAccount.accountLevel];
    lbUserTitle.text = NSLocalizedString(nameOfRank, @"");
    NSArray *array=[DuelRewardLogicController getStaticPointsForEachLevels];
    
    if (playerAccount.accountLevel < kCountOfLevelsMinimal || playerAccount.accountLevel > kCountOfLevels){
        [playerAccount setAccountLevel:kCountOfLevels];
    }
if (playerAccount.accountLevel != kCountOfLevels) {
    NSInteger num = playerAccount.accountLevel;
    int  moneyForNextLevel=[[array objectAtIndex:num] intValue];
    
    int moneyForPrewLevel;
    if (playerAccount.accountLevel==kCountOfLevelsMinimal) {
        moneyForPrewLevel = 0;
    }else{
        moneyForPrewLevel=[[array objectAtIndex:(playerAccount.accountLevel-1)] intValue];
    }
    if (playerAccount.accountPoints>moneyForNextLevel) {
        playerAccount.accountPoints=moneyForPrewLevel;
        [playerAccount saveAccountPoints];
    }
   
    if (playerAccount.accountPoints <= moneyForPrewLevel) {
        playerAccount.accountPoints = moneyForPrewLevel;
        [playerAccount saveAccountPoints];
    }
    int curentPoints=playerAccount.accountPoints - moneyForPrewLevel;
    int maxPoints=moneyForNextLevel - moneyForPrewLevel;
    
    lbPointsCountMain.text = [NSString stringWithFormat:@"%@/%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:playerAccount.accountPoints]], [[DuelRewardLogicController getStaticPointsForEachLevels] objectAtIndex:playerAccount.accountLevel]];

    if (needMoneyAnimation) {
        [self changePointsLine:curentPoints maxValue:maxPoints animated:needAnimation];
    }
    
    DLog(@"Profile info points %d points to next level %d",playerAccount.accountPoints,(moneyForNextLevel-playerAccount.accountPoints));
}else{
    DLog(@"Profile info points %d points ",playerAccount.accountPoints);

        lbPointsCountMain.text = [NSString stringWithFormat:@"%d",playerAccount.accountPoints];
    DLog(@"%@", lbPointsCountMain.text);
}
    if (!needAnimation) {
        lbGoldCount.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(playerAccount.money)]];
    }

    
    lbDuelsWonCount.text=[NSString stringWithFormat:@"%d",playerAccount.accountWins];
    lbDuelsLostCount.text=[NSString stringWithFormat:@"%d",playerAccount.accountDraws];
    
    lbBiggestWinCount.text=[numberFormatter stringFromNumber:[NSNumber numberWithInt:( playerAccount.accountBigestWin)]];
    
    userAtackView.hidden = NO;
    userDefenseView.hidden = NO;
    if (playerAccount.accountWeapon.dDamage!=0) {
        userAtack.text = [NSString stringWithFormat:@"+%d",playerAccount.accountWeapon.dDamage];
       
    }else{
        userAtack.text = @"+0";
    }
    if (playerAccount.accountDefenseValue!=0) {
        userDefense.text = [NSString stringWithFormat:@"+%d",playerAccount.accountDefenseValue];
    }else{
        userDefense.text = @"+0";
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
        
        if (![lbDescription isHidden] && lbDescription) {
            [UIView animateWithDuration:0.4
                             animations:^{
                                 CGRect frame = mainProfileView.frame;
                                 frame.origin.y += changeYPointWhenKeyboard;
                                 mainProfileView.frame = frame;
                             } completion:^(BOOL complete) {
                                 [self updateLabels];
                             }];
        }
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
    NSString * text;
    if (textIndex==0) {
        text = [textsContainer objectAtIndex:0];
        lbDescription.transform = CGAffineTransformMakeScale(0.01, 0.01);
        lbDescription.text = text;
        [self performSelector:@selector(lableScaleIn) withObject:nil afterDelay:1.0];
    }else{
        text = (textIndex<=6)?[textsContainer objectAtIndex:textIndex]:@"";
        [UIView animateWithDuration:1.0
                         animations:^{
                             [self lableScaleOut];
                         } completion:^(BOOL complete) {
                             lbDescription.text = text;
                             [self performSelector:@selector(lableScaleIn) withObject:nil afterDelay:1.0];
                         }];
    }
}

-(void)lableScaleIn
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         lbDescription.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    }completion:^(BOOL complete) {
                        if (textIndex==2) {
                            [tfFBName becomeFirstResponder];
                            [UIView animateWithDuration:0.4
                                             animations:^{
                                                 CGRect frame = mainProfileView.frame;
                                                 frame.origin.y -=changeYPointWhenKeyboard;
                                                 mainProfileView.frame = frame;
                                                 textIndex++;
                                             } completion:nil];
                        }else if(textIndex==4){
                            [self scaleButton:btnLeaderboardBig];
                            textIndex++;
                            [self performSelector:@selector(updateLabels) withObject:nil afterDelay:timeToStandartTitles];
                        }else if(textIndex==5){
                            [self scaleButton:lbGoldCount];
                            [self scaleButton:lbGoldIcon];
                            textIndex++;
                            [self performSelector:@selector(updateLabels) withObject:nil afterDelay:timeToStandartTitles];
                        }else if(textIndex==6){
                            [self scaleButton:btnBack];
                            textIndex++;
                            [self performSelector:@selector(updateLabels) withObject:nil afterDelay:timeToStandartTitles];
                        }else if (textIndex<=6){
                            [self performSelector:@selector(updateLabels) withObject:nil afterDelay:timeToStandartTitles];
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
        button.transform = CGAffineTransformMakeScale(1.4, 1.4);
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
    
    if (duelButton.hidden) {
        transition.subtype = kCATransitionFromRight;
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:NO];
    }
    else {
        [UIView animateWithDuration:0.75
                         animations:^{
                             [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                         }];
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self releaseComponents];
}

- (IBAction)backToMenuFirstRun:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveImagefromFBNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCheckfFBLoginSession object:nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"moneyForIPad"];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                     }];
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:NO];
    [self releaseComponents];
}


- (IBAction)btnSoundClick:(id)sender {
    StartViewController *startViewController=[[self.navigationController viewControllers] objectAtIndex:0];
    [startViewController soundOff];
}

- (IBAction)btnFBLoginClick:(id)sender {
    [ivBlack setHidden:NO];
    [playerAccount cleareWeaponAndDefense];
    [[LoginAnimatedViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusSimple];
    [loginViewController loginButtonClick:self];
}

- (IBAction)btnFBLogOutClick:(id)sender {
    [playerAccount cleareWeaponAndDefense];
    [ivBlack setHidden:NO];
    [loginViewController fbDidLogout];
        
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
    topPlayersViewController = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/leaderBoard_click" forKey:@"event"]];
}

- (IBAction)duelButtonClick:(id)sender {
        
    if ([playerAccount.sessionID isEqualToString:@"-1"]) {
        [playerAccount.finalInfoTable removeAllObjects];
        int randomTime = arc4random() % 6;
        
        if ([AccountDataSource sharedInstance].activeDuel) {
            ActiveDuelViewController *activeDuelViewController = [[ActiveDuelViewController alloc] initWithTime:randomTime Account:[AccountDataSource sharedInstance] oponentAccount:playerAccount];
            [self.navigationController pushViewController:activeDuelViewController animated:YES];
        }
        else
        {
            TeachingViewController *teachingViewController = [[TeachingViewController alloc] initWithTime:randomTime andAccount:[AccountDataSource sharedInstance] andOpAccount:playerAccount];
            [self.navigationController pushViewController:teachingViewController animated:YES];
        }
        SSConnection *connection = [SSConnection sharedInstance];
        [connection sendData:@"" packetID:NETWORK_SET_UNAVIBLE ofLength:sizeof(int)];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/duel_teaching" forKey:@"event"]];
        return;
    }
    
    DuelStartViewController *duelStartViewController = [[DuelStartViewController alloc]initWithAccount:[AccountDataSource sharedInstance] andOpAccount:playerAccount opopnentAvailable:NO andServerType:NO andTryAgain:NO];
    duelStartViewController.serverName = playerAccount.accountID;
    
    GameCenterViewController *gameCenterViewController = [GameCenterViewController sharedInstance:[AccountDataSource sharedInstance] andParentVC:self];
    duelStartViewController.delegate = gameCenterViewController;
    gameCenterViewController.duelStartViewController = duelStartViewController;
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:duelStartViewController animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                     }];
    duelStartViewController = nil;
}

-(IBAction)showStoreWeapon:(id)sender
{
    StoreViewController *storeViewController=[[StoreViewController alloc] initWithAccount:playerAccount];
    storeViewController.bagFlag = YES;
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:storeViewController animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                     }];
    storeViewController = nil;
}

-(IBAction)showStoreDefence:(id)sender
{
    StoreViewController *storeViewController=[[StoreViewController alloc] initWithAccount:playerAccount];
    storeViewController.bagFlag = YES;
    storeViewController.storeDataSource.typeOfTable = StoreDataSourceTypeTablesDefenses;
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:storeViewController animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                     }];
    storeViewController = nil;
}
#pragma mark IconDownloaderDelegate
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    profilePictureViewDefault.image = iconDownloader.imageDownloaded;
    profilePictureViewDefault.hidden = NO;
}

- (void)dealloc {
}
@end
