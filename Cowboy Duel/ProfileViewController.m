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
#import "DuelStartViewController.h"
#import "StoreViewController.h"
#import "ActiveDuelViewController.h"
#import "FavouritesViewController.h"
#import "FavouritesDataSource.h"
#import "UIView+Dinamic_BackGround.h"

static const CGFloat changeYPointWhenKeyboard = 155;
static const CGFloat timeToStandartTitles = 1.8;

@interface ProfileViewController ()
{
    AccountDataSource *playerAccount;
    
    SSServer *playerServer;
    
    IconDownloader *iconDownloader;
    
    NSString *namePlayerSaved;
    
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
    __weak IBOutlet UIButton *btnAddToFavorites;
    
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
    
    __weak IBOutlet UIButton *duelButton;
    
    __weak IBOutlet UILabel *lbPointsCountMain;
    __weak IBOutlet UIImageView *ivCurrentRank;
    
    __weak IBOutlet UILabel *lbPointsText;
    __weak IBOutlet UILabel *lbFavouritesTitle;
    
//  Favourites
    
    __weak IBOutlet UIButton *btnFavourites;
    
    NSNumberFormatter *numberFormatter;
    
    BOOL didDisappear;
    BOOL needMoneyAnimation;
    
    
    __weak IBOutlet UIImageView *ivBackground;
    
//    First run
    int textIndex;
    __weak IBOutlet UILabel *lbDescription;
    __weak IBOutlet UIImageView *ivPhotoFrame;
    
    DuelStartViewController *duelStartViewController;
    __weak IBOutlet UIActivityIndicatorView *activityIndicatorView;
    __weak IBOutlet UIView *bgActivityIndicator;
}
-(void)setImageFromFacebook;
-(void)initStatsWithAccount: (AccountDataSource *)oponentAccount;
-(IBAction)showStoreWeapon:(id)sender;
-(IBAction)showStoreDefence:(id)sender;
@end

@implementation ProfileViewController
@synthesize needAnimation, ivBlack,profilePictureViewDefault;

#pragma mark

-(id)initWithAccount:(AccountDataSource *)userAccount;
{
    self = [super initWithNibName:@"ProfileViewController" bundle:[NSBundle mainBundle]];

    if (self) {
        needAnimation = NO;
        needMoneyAnimation = YES;
        playerAccount=userAccount;
        
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

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
        
        [self initMainControls];
        [mainProfileView setDinamicHeightBackground];
        [self checkLocationOfViewForFBLogin];
    }
    return self;
}

-(id)initForOponent:(AccountDataSource *)oponentAccount andOpponentServer:(SSServer *)server
{
    self = [super initWithNibName:@"ProfileViewControllerWanted" bundle:[NSBundle mainBundle]];
    
    if (self) {
        playerServer = server;

        [self initStatsWithAccount:oponentAccount];
        
        if ([playerServer.status isEqualToString:@"A"]) {
            [duelButton changeTitleByLabel:@"DUEL"];
            [duelButton setEnabled:YES];
        }
        else {
            [duelButton changeTitleByLabel:@"Busy"];
            [duelButton setEnabled:NO];
        }
        userAtackView.hidden = NO;
        userDefenseView.hidden = NO;
        
        userAtack.text = [NSString stringWithFormat:@"%d",playerServer.weapon + [DuelRewardLogicController countUpBuletsWithPlayerLevel:[playerServer.rank intValue]]];
        userAtack.hidden = NO;
        userAtack = nil;
        
        userDefense.text = [NSString stringWithFormat:@"%d",playerServer.defense + [DuelRewardLogicController countUpBuletsWithPlayerLevel:[playerServer.rank intValue]]];
        
        userDefense.hidden = NO;
        userDefense = nil;        
        [self checkIsOpponentFavorite];
    }
    return self;
}

-(id)initForFavourite:(CDFavPlayer *)favPlayer withAccount:(AccountDataSource *)oponentAccount
{
    self = [super initWithNibName:@"ProfileViewControllerWanted" bundle:[NSBundle mainBundle]];
    
    if (self) {
        [self initStatsWithAccount:oponentAccount];

        [btnAddToFavorites setHidden:YES];
        [bgActivityIndicator setHidden:NO];
        [activityIndicatorView startAnimating];
        
        userAtack.text = [NSString stringWithFormat:@"%d",favPlayer.dAttack];
        userAtack.hidden = NO;
        userDefense.text = [NSString stringWithFormat:@"%d",favPlayer.dDefense];
        userDefense.hidden = NO;
        userAtackView.hidden = NO;
        userDefenseView.hidden = NO;
    }
    return self;
}

-(id)initFirstStartWithAccount:(AccountDataSource *)userAccount;
{
    self = [super initWithNibName:@"ProfileViewControllerFirstRun" bundle:[NSBundle mainBundle]];
    
    if (self) {
        needAnimation = NO;
        needMoneyAnimation = YES;
        playerAccount=userAccount;
                
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        // above
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setImageFromFacebookWithHideIndicator)
                                                     name:kReceiveImagefromFBNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeFBSesionAction)
                                                     name:SCSessionStateChangedNotification
                                                   object:nil];
        
        textIndex = 0;
        [self loadView];
        UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
        [btnBack setTitleByLabel:@"CONTINUE" withColor:buttonsTitleColor fontSize:24];
        [btnLeaderboardBig setTitleByLabel:@"LeaderboardTitle" withColor:buttonsTitleColor fontSize:24];
        [self initMainControls];
        [mainProfileView setDinamicHeightBackground];
        lbDescription.hidden = NO;
        [self checkLocationOfViewForFBLogin];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/profile_first_run" forKey:@"event"]];

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
    if (![lbFavouritesTitle isHidden] && lbFavouritesTitle) {
        [self refreshContentFromPlayerAccount];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    
//    lbGoldCount.text =[numberFormatter stringFromNumber:[NSNumber numberWithInt:(playerAccount.money/2)]];
    
    CGRect liveChRect = ivPointsLine.frame;
    liveChRect.size.width=0;
    ivPointsLine.frame = liveChRect;
    if (duelStartViewController.waitTimer) [duelStartViewController.waitTimer invalidate];
    didDisappear=YES;
}

-(void)releaseComponents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveImagefromFBNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCheckfFBLoginSession object:nil];
    
    playerAccount = nil;
    playerServer = nil;
    iconDownloader = nil;
    namePlayerSaved = nil;
    lbProfileMain = nil;
    mainProfileView = nil;
    tfFBName = nil;
    lbUserTitle = nil;
    ivPointsLine = nil;
    lbGoldCount = nil;
    lbGoldIcon = nil;
    lbAward = nil;
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
    duelStartViewController = nil;
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
    
    lbFavouritesTitle.text = NSLocalizedString(@"FavouritesTitle", @"");
    lbFavouritesTitle.font = [UIFont fontWithName:@"DecreeNarrow" size:18];

    lbDuelsWonCount.font = CountFont;
    
    lbUserTitle.font = [UIFont  systemFontOfSize:lbUserTitle.font.pointSize];;
    
    tfFBName.font = NameFont;
    [tfFBName setDelegate:self];
    
    lbPlayerStats.font = CountFont;
   
    [ivPointsLine setClipsToBounds:YES];

}

-(void)initStatsWithAccount: (AccountDataSource *)oponentAccount;
{
    playerAccount=oponentAccount;

    needAnimation = YES;
    needMoneyAnimation = NO;

    numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    [self loadView];
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    [btnBack setTitleByLabel:@"BACK" withColor:buttonsTitleColor fontSize:24];
    [btnLeaderboardBig setTitleByLabel:@"LeaderboardTitle" withColor:buttonsTitleColor fontSize:24];
    [duelButton setTitleByLabel:@"DUEL"];
    [duelButton setEnabled:NO];
    [duelButton changeColorOfTitleByLabel:buttonsTitleColor];
    
    needAnimation = YES;
    [self initMainControls];
    
    [lbAward setFont: [UIFont fontWithName: @"MyriadPro-Bold" size:18]];//lbAward.font.pointSize]];
    lbAward.text = NSLocalizedString(@"AWARD", @"");
    
    [lbGoldCount setFont: [UIFont fontWithName: @"MyriadPro-Bold" size:18]];
    int moneyExch  = playerAccount.money < 10 ? 1: playerAccount.money / 10.0;
    lbGoldCount.text = [NSString stringWithFormat:@"%d",moneyExch];
    
    [tfFBName setFont: [UIFont fontWithName: @"MyriadPro-Bold" size:18]];
    tfFBName.text = [NSString stringWithFormat:@"%@",playerAccount.accountName];
    
    //avatar magic!
    NSString *name = [[OGHelper sharedInstance ] getClearName:playerAccount.accountID];
    if ([playerAccount.accountID rangeOfString:@"A"].location != NSNotFound){
        profilePictureViewDefault.contentMode = UIViewContentModeScaleAspectFit;
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.namePlayer=name;
        iconDownloader.delegate = self;
        [iconDownloader setAvatarURL:playerAccount.avatar];
        [iconDownloader startDownloadSimpleIcon];
    }
    
    if ([playerAccount.accountID rangeOfString:@"F"].location != NSNotFound) {
        iconDownloader = [[IconDownloader alloc] init];
        profilePictureViewDefault.contentMode = UIViewContentModeScaleAspectFit;
        
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
        
    }
    //
    //  check iphone 5 delta
    if ([UIScreen mainScreen].bounds.size.height > 480) {
        [ivBackground setImage:[UIImage imageNamed:@"pv_wanted_back-568h@2x.png"]];
        
        CGRect deltaFrame =  mainProfileView.frame;
        deltaFrame.size.height += 77;
        mainProfileView.frame = deltaFrame;
        ivBackground.frame = deltaFrame;
        
        deltaFrame = tfFBName.frame;
        deltaFrame.origin.y += 30;
        tfFBName.frame = deltaFrame;
        
        deltaFrame = profilePictureView.frame;
        deltaFrame.origin.y += 27;
        profilePictureView.frame = deltaFrame;
        
        deltaFrame = profilePictureViewDefault.frame;
        deltaFrame.origin.y += 27;
        profilePictureViewDefault.frame = deltaFrame;
        
        deltaFrame = userAtackView.frame;
        deltaFrame.origin.y += 27;
        userAtackView.frame = deltaFrame;
        
        deltaFrame = userDefenseView.frame;
        deltaFrame.origin.y += 27;
        userDefenseView.frame = deltaFrame;
        
        deltaFrame = ivPhotoFrame.frame;
        deltaFrame.origin.y += 27;
        ivPhotoFrame.frame = deltaFrame;

        deltaFrame = bgActivityIndicator.frame;
        deltaFrame.origin.y += 27;
        bgActivityIndicator.frame = deltaFrame;
        
        deltaFrame = lbGoldCount.frame;
        deltaFrame.origin.y += 27;
        lbGoldCount.frame = deltaFrame;
        
        deltaFrame = lbAward.frame;
        deltaFrame.origin.y += 27;
        lbAward.frame = deltaFrame;
        
        deltaFrame = lbGoldIcon.frame;
        deltaFrame.origin.y += 27;
        lbGoldIcon.frame = deltaFrame;
        
        deltaFrame = duelButton.frame;
        deltaFrame.origin.y += 47;
        duelButton.frame = deltaFrame;
    }
    
}
#pragma mark -
-(void)checkLocationOfViewForFBLogin;
{
    [self refreshContentFromPlayerAccount];
    [profilePictureView setProfileID:nil];
    [profilePictureView setProfileID:playerAccount.facebookUser.id];
    [profilePictureView setHidden:NO];
    [profilePictureViewDefault setHidden:YES];
    profilePictureViewDefault.contentMode = UIViewContentModeScaleAspectFit;
    [btnLeaderboard setEnabled:YES];
    [btnFavourites setEnabled:YES];
    [self setImageFromFacebook];
    
    NSString *name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel];
    ivCurrentRank.image = [UIImage imageNamed:name];
    tfFBName.text = playerAccount.accountName;
    
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
    userAtack.text =[NSString stringWithFormat:@" %d",playerAccount.accountWeapon.dDamage + [DuelRewardLogicController countUpBuletsWithPlayerLevel:playerAccount.accountLevel]];
       
    userDefense.text = [NSString stringWithFormat:@" %d",playerAccount.accountDefenseValue + [DuelRewardLogicController countUpBuletsWithPlayerLevel:playerAccount.accountLevel]];
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
            [[StartViewController sharedInstance] authorizationModifier:YES];
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

-(void)checkIsOpponentFavorite
{
    if ([playerAccount isPlayerForPractice]) {
        btnAddToFavorites.hidden = YES;
    }else{
        if (playerServer.favorite) {
            NSLog(@"server %@ YES",playerServer.displayName);
            dispatch_async(dispatch_get_main_queue(), ^{
                [btnAddToFavorites setImage:[UIImage imageNamed:@"topPlayerStarSelected.png"] forState:UIControlStateNormal];
                [btnAddToFavorites setImage:[UIImage imageNamed:@"topPlayerStarSelected.png"] forState:UIControlStateDisabled];
            });
        }else{
            NSLog(@"server %@ NO",playerServer.displayName);
            dispatch_async(dispatch_get_main_queue(), ^{
                [btnAddToFavorites setImage:[UIImage imageNamed:@"topPlayerStar.png"] forState:UIControlStateNormal];
                [btnAddToFavorites setImage:[UIImage imageNamed:@"topPlayerStar.png"] forState:UIControlStateDisabled];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            btnAddToFavorites.enabled = YES;
            duelButton.enabled = YES;
        });
    }
}

#pragma mark Animation description

- (void)updateLabels
{
    NSString * text;
    if (textIndex==0) {
        text = NSLocalizedString(@"PROFILE_MESS_2_NAME", nil);
        lbDescription.transform = CGAffineTransformMakeScale(0.01, 0.01);
        lbDescription.text = text;
        [self performSelector:@selector(lableScaleIn) withObject:nil afterDelay:1.0];
    }else{
        [UIView animateWithDuration:1.0
                         animations:^{
                             [self lableScaleOut];
                         } completion:^(BOOL complete) {
                             
                         }];
    }
}

-(void)lableScaleIn
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         lbDescription.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    }completion:^(BOOL complete) {
                        if (textIndex==0) {
                            [tfFBName becomeFirstResponder];
                            [UIView animateWithDuration:0.4
                                             animations:^{
                                                 CGRect frame = mainProfileView.frame;
                                                 frame.origin.y -=changeYPointWhenKeyboard;
                                                 mainProfileView.frame = frame;
                                                 textIndex++;
                                             } completion:nil];
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

- (IBAction)backToMenu:(id)sender {
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
}

- (IBAction)backToMenuFirstRun:(id)sender {
    [tfFBName resignFirstResponder];
    
    [[StartViewController sharedInstance] favoritesDownloadListAfterAvtorization];
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/first_profile_continue_click" forKey:@"event"]];
    [self releaseComponents];
}

- (IBAction)backToMenuWanted:(id)sender {
    [self backToMenu:sender];
    [self releaseComponents];
}

- (IBAction)btnLeaderbordFirstRunClick:(id)sender {
    TopPlayersViewController *topPlayersViewController =[[TopPlayersViewController alloc] initWithAccount:playerAccount];
    [self.navigationController pushViewController:topPlayersViewController animated:YES];
    topPlayersViewController = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/first_profile_leaderBoard_click" forKey:@"event"]];
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
    if ([playerAccount isPlayerForPractice]) {
        [playerAccount.finalInfoTable removeAllObjects];
        
        if ([AccountDataSource sharedInstance].activeDuel) {
            ActiveDuelViewController *activeDuelViewController = [[ActiveDuelViewController alloc] initWithAccount:[AccountDataSource sharedInstance] oponentAccount:playerAccount];
            [self.navigationController pushViewController:activeDuelViewController animated:YES];
            activeDuelViewController = nil;
        }
        
        SSConnection *connection = [SSConnection sharedInstance];
        [connection sendData:@"" packetID:NETWORK_SET_UNAVIBLE ofLength:sizeof(int)];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/duel_teaching" forKey:@"event"]];
//        [self releaseComponents];
        return;
    }
    
    duelStartViewController = [[DuelStartViewController alloc]initWithAccount:[AccountDataSource sharedInstance] andOpAccount:playerAccount opopnentAvailable:NO andServerType:NO andTryAgain:NO];
    
    GameCenterViewController *gameCenterViewController = [GameCenterViewController sharedInstance:[AccountDataSource sharedInstance] andParentVC:self];
    duelStartViewController.delegate = gameCenterViewController;
    gameCenterViewController.duelStartViewController = duelStartViewController;
    
    if (!playerAccount.bot) {
        const char *name = [playerAccount.accountID cStringUsingEncoding:NSUTF8StringEncoding];
        SSConnection *connection = [SSConnection sharedInstance];
        [connection sendData:(void *)(name) packetID:NETWORK_SET_PAIR ofLength:sizeof(char) * [playerAccount.accountID length]];
    }
    else {
        SSConnection *connection = [SSConnection sharedInstance];
        [connection sendData:@"" packetID:NETWORK_SET_UNAVIBLE ofLength:sizeof(int)];
        [self performSelector:@selector(startBotDuel) withObject:nil afterDelay:0.5];
    }

    [activityIndicatorView startAnimating];
    [bgActivityIndicator setHidden:NO];
    [duelButton setEnabled:NO];
    btnAddToFavorites.enabled = NO;
    //duelStartViewController = nil;
}

- (IBAction)btnFavouritesClick:(id)sender {
//    [[StartViewController sharedInstance].favsDataSource reloadDataSource];
    if ([[StartViewController sharedInstance] connectedToWiFi]) {
    FavouritesViewController *favVC = [[FavouritesViewController alloc] initWithAccount:playerAccount];
    [self.navigationController pushViewController:favVC animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/profile_favorites_click" forKey:@"event"]];
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



-(void)startBotDuel
{
    ActiveDuelViewController __block *activeDuelViewController = [[ActiveDuelViewController alloc] initWithAccount:[AccountDataSource sharedInstance] oponentAccount:playerAccount];
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:activeDuelViewController animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                     } completion:^(BOOL complete){
                         activeDuelViewController = nil;
                     }];
//    [self releaseComponents];
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

- (IBAction)btnAddToFavoritesClick:(id)sender {
    bgActivityIndicator.hidden = NO;
    
    btnAddToFavorites.enabled = NO;
    duelButton.enabled = NO;
    __weak ProfileViewController *bself = self;
    
    if (playerServer.favorite) {
        [FavouritesDataSource deleteFavoriteId:playerAccount.accountID completionHandler:^(NSURLResponse *response,
                                                                                           NSData *data,
                                                                                           NSError *error)
         {
             if ([data length] >0 && error == nil)
             {
                 NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 NSDictionary *responseObject = ValidateObject([jsonString JSONValue], [NSDictionary class]);
                 int errCode=[[responseObject objectForKey:@"err_code"] intValue];
                 if (errCode == 1) {
                     playerServer.favorite = NO;
                     [[StartViewController sharedInstance].favsDataSource deleteFromDBFavoriteWithId:playerAccount.accountID];
                     [[StartViewController sharedInstance].favsDataSource saveFavorites:[StartViewController sharedInstance].favsDataSource.arrItemsList];
                 }
             }
             else if ([data length] == 0 && error == nil)
             {
                 DLog(@"Nothing was downloaded.");
                 playerServer.favorite = YES;
             }
             else if (error != nil){
                 DLog(@"DuelProductDownloaderController Connection failed! Error - %@ %@",
                      [error localizedDescription],
                      [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
                 playerServer.favorite = YES;
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 bgActivityIndicator.hidden = YES;
             });
             [bself checkIsOpponentFavorite];
         }];
    }else{
        [FavouritesDataSource addFavoriteId:playerAccount.accountID completionHandler:^(NSURLResponse *response,
                                                                                        NSData *data,
                                                                                        NSError *error)
         {
             if ([data length] >0 && error == nil)
             {
                 NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 NSLog(@"jsonString %@",jsonString);
                 NSDictionary *responseObject = ValidateObject([jsonString JSONValue], [NSDictionary class]);
                 int errCode=[[responseObject objectForKey:@"err_code"] intValue];
                 if (errCode == 1) {
                      playerServer.favorite = YES;
                     CDFavPlayer *favPlayer = [[CDFavPlayer alloc] init];
                     favPlayer.dNickName = playerServer.displayName;
                     favPlayer.dAvatar = playerServer.fbImageUrl;
                     favPlayer.dMoney = [playerServer.money intValue];
                     favPlayer.dLevel = [playerServer.rank intValue];
                     favPlayer.dAttack = playerServer.weapon;
                     favPlayer.dDefense = playerServer.defense;
                     favPlayer.dAuth = playerServer.serverName;
                     favPlayer.dBot = playerServer.bot;
                     favPlayer.dSessionId = playerServer.sessionId;
                     favPlayer.dStatus = playerServer.status;
                     
                     [[StartViewController sharedInstance].favsDataSource addToDBFavotitePlayer:favPlayer];
                     [[StartViewController sharedInstance].favsDataSource saveFavorites:[StartViewController sharedInstance].favsDataSource.arrItemsList];
                 }
             }
             else if ([data length] == 0 && error == nil)
             {
                 DLog(@"Nothing was downloaded.");
                 playerServer.favorite = NO; 
             }
             else if (error != nil){
                 DLog(@"DuelProductDownloaderController Connection failed! Error - %@ %@",
                      [error localizedDescription],
                      [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
                 playerServer.favorite = NO;
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 bgActivityIndicator.hidden = YES;
             });
             [bself checkIsOpponentFavorite];
         }];
    }
}

#pragma mark IconDownloaderDelegate
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    profilePictureViewDefault.image = iconDownloader.imageDownloaded;
    profilePictureViewDefault.hidden = NO;
}

#pragma mark -
- (void)dealloc {
}
- (void)viewDidUnload {
    activityIndicatorView = nil;
    bgActivityIndicator = nil;
    ivBackground = nil;
    ivPhotoFrame = nil;
    btnAddToFavorites = nil;
    btnFavourites = nil;
    lbFavouritesTitle = nil;
    [super viewDidUnload];
}
@end
