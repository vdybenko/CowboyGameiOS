//
//  DuelStartViewController.m
//  Test
//
//  Created by Sobol on 08.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DuelStartViewController.h"
#import "GameCenterViewController.h"
#import "UIButton+Image+Title.h"
#import "DuelRewardLogicController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Save.h"
#import "CustomNSURLConnection.h"
#import "UIView+Dinamic_BackGround.h"
#import "ActiveDuelViewController.h"
#import "DuelRewardLogicController.h"

@interface DuelStartViewController ()

- (void)setOponentInfo;
@property (weak, nonatomic) IBOutlet UIView *userAtackView;
@property (weak, nonatomic) IBOutlet UIView *userDefenseView;
@property (weak, nonatomic) IBOutlet UIView *oponentAtackView;
@property (weak, nonatomic) IBOutlet UIView *oponentDefenseView;
@property (weak, nonatomic) IBOutlet UILabel *userAtack;
@property (weak, nonatomic) IBOutlet UILabel *userDefense;
@property (weak, nonatomic) IBOutlet UILabel *oponentAtack;
@property (weak, nonatomic) IBOutlet UILabel *oponentDefense;

@end

@implementation DuelStartViewController
@synthesize _ivOponent, delegate ,oponentNameOnLine, serverName, oponentAvailable, tryAgain;
@synthesize _btnStart, _ivPlayer, _vBackground, _lbNamePlayer, _lbNameOponent, _btnBack;
@synthesize _vWait, lbOpponentDuelsWinCount;
@synthesize userAtack;
@synthesize userDefense;
@synthesize oponentAtack;
@synthesize oponentDefense;
@synthesize userAtackView;
@synthesize userDefenseView;
@synthesize oponentAtackView;
@synthesize oponentDefenseView;
@synthesize waitTimer;

static const char *GC_URL =  BASE_URL"api/gc";

#pragma mark

-(id)initWithAccount:(AccountDataSource *)userAccount andOpAccount:(AccountDataSource *)opAccount opopnentAvailable:(BOOL)available andServerType:(BOOL)server andTryAgain:(BOOL)tryA;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        oponentAvailable=available;
        tryAgain = tryA;
        serverType = server;
        playerAccount = userAccount;
        oponentAccount = opAccount;
        
        if (playerAccount.isTryingWeapon) {
            playerAccount.isTryingWeapon = NO;
        }
    }
    return self;
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewDidLoad{
        
    if (oponentAvailable) {
        
    }
    else
    {
        runAnimation=YES;
        timerIndex = 0;
    }
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    
    if([uDef boolForKey:@"FirstRunForDuel"])  firstRun = YES;
    else firstRun = NO;
    [uDef setBool:FALSE forKey:@"FirstRunForDuel"];
    
    CGRect frame;
    //player image
   
    UIColor *buttonsTitleColor = [[UIColor alloc] initWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    [_btnBack setTitleByLabel:@"BACK"];
    [_btnBack changeColorOfTitleByLabel:buttonsTitleColor];
    
    [_btnStart setTitleByLabel:@"START"];
    [_btnStart changeColorOfTitleByLabel:buttonsTitleColor];

    UIFont *fontNames=[UIFont fontWithName: @"MyriadPro-Semibold" size:16];
    UIFont *fontSimpleText=[UIFont fontWithName: @"MyriadPro-Semibold" size:13];
    
    if (playerAccount.accountName != nil)
        _lbNamePlayer.text = playerAccount.accountName;
    else 
        _lbNamePlayer.text = @"YOU";
    
    _lbNamePlayer.font=fontNames;
    //_lbMoneyPlayer.text =  [NSString stringWithFormat:@"%@%d",@"$",playerAccount.money];
        
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Back2.mp3", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [player play];
    [player stop];
    [player setNumberOfLoops:999];
    [playerAccount.finalInfoTable removeAllObjects];
            
    //title
    UIColor *mainColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    lbDuelStart.textColor = mainColor;
    lbDuelStart.text = NSLocalizedString(@"StartDuelTitle", nil);
    lbDuelStart.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
    //User's labels
    _ivPlayer.contentMode = UIViewContentModeScaleAspectFit;
    if([[OGHelper sharedInstance] isAuthorized]){
        NSString *pathToImage=[[OGHelper sharedInstance] apiGraphGetImage:@"me"];
        UIImage *image=[UIImage loadImageFromDocumentDirectory:[pathToImage lastPathComponent]];
        [_ivPlayer setImage:image];
    }else {
        [_ivPlayer setImage:[UIImage imageNamed:@"pv_photo_default.png"]];
    }
    
    lbUserDuelsWin.text = NSLocalizedString(@"DuelsWonsTitle", nil);
    lbUserDuelsWin.font=fontSimpleText; 
    
    lbUserRank.text = [NSString stringWithFormat:@" %d",playerAccount.accountWins];
    NSString *Rank=[NSString stringWithFormat:@"%dRank",playerAccount.accountLevel];
    lbUserRank.text = NSLocalizedString(Rank, @"");
    lbUserRank.font=fontSimpleText;
    
    userAtack.text = [NSString stringWithFormat:@" %d",playerAccount.accountAtackValue+[DuelRewardLogicController countUpBuletsWithPlayerLevel:playerAccount.accountLevel]];
    userAtackView.hidden = NO;

    userDefense.text = [NSString stringWithFormat:@"%d",playerAccount.accountDefenseValue+[DuelRewardLogicController countUpBuletsWithPlayerLevel:playerAccount.accountLevel]];
    userDefenseView.hidden = NO;
    
    [self setAttackAndDefenseOfOponent:oponentAccount];
    
    lbUserDuelsWinCount.text = [NSString stringWithFormat:@"%d",playerAccount.accountWins];
    lbUserDuelsWinCount.font=fontSimpleText;

    //Opponent's labels
    _lbNameOponent.text = oponentAccount.accountName;
    _lbNameOponent.font=fontNames;

    _ivOponent.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *nameOfRank=[NSString stringWithFormat:@"%dRank",oponentAccount.accountLevel];
    lbOpponentRank.text = NSLocalizedString(nameOfRank, @"");
    lbOpponentRank.font=fontSimpleText;

    lbOpponentDuelsWin.text = NSLocalizedString(@"DuelsWonsTitle", nil);    
    lbOpponentDuelsWin.font=fontSimpleText;

    lbOpponentDuelsWinCount.text = [NSString stringWithFormat:@"%d",oponentAccount.accountWins];
    lbOpponentDuelsWinCount.font=fontSimpleText;

    lbForTheMurder.text = NSLocalizedString(@"MotivationText1", nil);
    lbForTheMurder.font=fontSimpleText;

    lbReward.text = NSLocalizedString(@"MotivationText2", nil);
    lbReward.font=fontSimpleText;

    [self setOponentMoney:oponentAccount.money];

    lbGold.text = NSLocalizedString(@"MotivationGold", nil);
    lbGold.font=fontSimpleText;
    
    lbPoints.text = NSLocalizedString(@"MotivationPoints", nil);
    lbPoints.font=fontSimpleText;

    lbPointsCount.text = [NSString stringWithFormat:@"%d",[DuelRewardLogicController getPointsForWinWithOponentLevel:oponentAccount.accountLevel]];
    lbPointsCount.font = fontSimpleText;

    frame=lbPointsCount.frame;
    CGSize size=[lbPointsCount fitSizeToText:lbPointsCount];
    frame.size.width=size.width;
    [lbPointsCount setFrame:frame];
    
    [lbPoints dinamicAttachToView:lbPointsCount withDirection:DirectionToAnimateRight];
    if (([playerAccount.accountID rangeOfString:@"F:"].location != NSNotFound))
    {
        [self.fbPlayerImage setHidden:NO];
        NSMutableString *playerName = [playerAccount.accountID mutableCopy];
        [playerName replaceCharactersInRange:[playerAccount.accountID rangeOfString:@"F:"] withString:@""];
        self.fbPlayerImage.profileID = playerName;
    } else {
        [self.fbPlayerImage setHidden:YES];
    }
    
    if (([oponentAccount.accountID rangeOfString:@"F:"].location != NSNotFound))
    {
        [self.fbOpponentImage setHidden:NO];
        NSMutableString *playerName = [oponentAccount.accountID mutableCopy];
        [playerName replaceCharactersInRange:[oponentAccount.accountID rangeOfString:@"F:"] withString:@""];
        self.fbOpponentImage.profileID = playerName;
    } else {
        [self.fbOpponentImage setHidden:YES];
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [mainDuelView setDinamicHeightBackground];
    _vWait.hidden = YES;
    [self setOponentImage];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (oponentAvailable) {
        [_btnStart setEnabled:YES];
        [_btnStart setHidden:NO];
        [_vWait setHidden:YES];
    }else{
        [_btnStart setHidden:YES];
        [_vWait setHidden:NO];
    }
    if ((!serverType)&&(!tryAgain)) {
        if (!oponentAccount.bot) {
            const char *name = [serverName cStringUsingEncoding:NSUTF8StringEncoding];
            SSConnection *connection = [SSConnection sharedInstance];
            [connection sendData:(void *)(name) packetID:NETWORK_SET_PAIR ofLength:sizeof(char) * [serverName length]];
        }
        else {
            SSConnection *connection = [SSConnection sharedInstance];
            [connection sendData:@"" packetID:NETWORK_SET_UNAVIBLE ofLength:sizeof(int)];
            [self performSelector:@selector(startBotDuel) withObject:nil afterDelay:0.5];
        }
    }
    [[self.navigationController.viewControllers objectAtIndex:1] performSelector:@selector(playerStop)];
    [player play];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/DuelStartVC" forKey:@"page"]];
}


-(void)viewWillDisappear:(BOOL)animated
{
    runAnimation = NO;
    if (waitTimer) [waitTimer invalidate];
    [player stop];
}

-(void)viewDidDisappear:(BOOL)animated
{
    _ivOponent.image = nil;
    [_vWait setHidden:YES];
    _vWait.hidden = YES;
}

-(void)releaseComponents
{
    _ivOponent = nil;
    oponentNameOnLine = nil;
    serverName = nil;
    _btnStart = nil;
    _ivPlayer = nil;
    _vBackground = nil;
    _lbNamePlayer = nil;
    _lbNameOponent = nil;
    _btnBack = nil;
    _vWait = nil;
    lbOpponentDuelsWinCount = nil;
    userAtack = nil;
    userDefense = nil;
    oponentAtack = nil;
    oponentDefense = nil;
    userAtackView = nil;
    userDefenseView = nil;
    oponentAtackView = nil;
    oponentDefenseView = nil;
    oponentAccount = nil;
    oponentNameOnLine = nil;
    player = nil;
    pathFile = nil;
    [waitTimer invalidate];
    waitTimer = nil;    
    lineViews = nil;
    twoLineViews = nil;    
    iconDownloader = nil;
    mainDuelView = nil;
    lbDuelStart = nil;
    lbUserRank = nil;
    lbUserDuelsWin = nil;
    lbUserDuelsWinCount = nil;
    lbOpponentRank = nil;
    lbOpponentDuelsWin = nil;
    lbForTheMurder = nil;
    lbReward = nil;
    lbGoldCount = nil;
    lbGold = nil;
    lbPointsCount = nil;
    lbPoints = nil;
    serverName = nil;
}
#pragma mark - 


-(void)waitTimerTick
{
    if (!waitTimer) return;
    [self cancelButtonClick];
    [waitTimer invalidate];
    waitTimer = nil;
    DLog(@"waitTimerTick");
    
}

-(void)stopWaitTimer;
{
    [waitTimer invalidate];
    waitTimer = nil;
}

-(IBAction)startButtonClick;
{
    if (!serverType) waitTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(waitTimerTick) userInfo:nil repeats:NO];
    [delegate btnClickStart];
    _btnStart.enabled = NO;
    _vWait.hidden = NO;
}

-(IBAction)cancelButtonClick;
{
    TestAppDelegate *testAppDelegate = (TestAppDelegate *)[[UIApplication sharedApplication] delegate];
    [testAppDelegate.navigationController popToViewController:[testAppDelegate.navigationController.viewControllers objectAtIndex:1] animated:YES];
    
    [delegate duelCancel];
    [self releaseComponents];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/DuelStartVC_cancel" forKey:@"page"]];
}

#pragma mark FConnect Methods

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    
    if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
        result = [result objectAtIndex:0];
    }
    _ivOponent.image = [[UIImage alloc] initWithData:result];
    
    NSString *name=[[OGHelper sharedInstance ] getClearName:oponentAccount.accountID];
    NSString *path = [NSString stringWithFormat:@"%@/icon_%@.png",[[OGHelper sharedInstance] getSavePathForList],name];
    [UIImagePNGRepresentation(_ivOponent.image) writeToFile:path atomically:YES];
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    DLog(@"DuelStartViewController didFailWithError: %@  error %@"  , request,[error description]);
    _ivOponent.image = [UIImage imageNamed:@"pv_photo_default.png"];
    _ivOponent.transform = CGAffineTransformIdentity;
    _ivOponent.transform = CGAffineTransformMakeScale(-1.0, 1.0);
}

#pragma mark -
#pragma mark DuelStartViewControllerDelegate protocol Methods

#pragma mark -
#pragma mark DuelStartViewControllerDelegate protocol Methods

-(void)setOponent:(NSString*)iv Label1:(NSString*)uil1 Label1:(int)uil2;
{   
//    runAnimation = NO;
//    [_vWait setHidden:YES];
//    
//    pathFile=[NSString stringWithFormat:@"%@%@%@",@"pv_bm_",iv,@".png"];
//    [_ivOponent setImage:[UIImage imageNamed:pathFile]];
//    _ivOponent.transform = CGAffineTransformIdentity;
//    _ivOponent.transform = CGAffineTransformMakeScale(-1.0, 1.0);
//    
//    [self setOponentInfo];
//
//    _lbNameOponent.text = uil1;
//    //_lbMoneyOponent.text =  [NSString stringWithFormat:@"%@%d",@"$",uil2];
//    [_lbNameOponent setHidden:NO];
//    //[_lbMoneyOponent setHidden:NO];
//    
//    [_btnStart setEnabled:YES];
    
}

- (void)setOponentInfo 
{	
//    [_lbNameOponent setFont: [UIFont fontWithName: @"DecreeNarrow" size:22]];
//    UIColor *col=[[UIColor alloc] initWithRed:0.317 green:0.274 blue:0.184 alpha:1];
//    [_lbNameOponent setTextColor:col];
//    
//    //[_lbMoneyOponent setFont: [UIFont fontWithName: @"MyriadPro-Bold" size:15]];
//    col=[[UIColor alloc] initWithRed:0.317 green:0.274 blue:0.184 alpha:1];
//    //[_lbMoneyOponent setTextColor:col];
}

-(void)cancelDuel;
{
//   Выводитса сообщение NSLocalizedString(@"RanAway", @"")
    _vWait.hidden = YES;
    [_btnStart setEnabled:NO];
}

- (void)setMessageTry   
{	
    
}

-(void)setUserMoney:(int)money;
{   
    //_lbMoneyPlayer.text =  [NSString stringWithFormat:@"%@%d",@"$",money];
}

-(void)setAttackAndDefenseOfOponent:(AccountDataSource*)oponent;
{
    oponentAtack.text = [NSString stringWithFormat:@" %d",oponent.accountAtackValue+[DuelRewardLogicController countUpBuletsWithPlayerLevel:oponent.accountLevel]];
    oponentAtackView.hidden = NO;
    oponentDefense.text = [NSString stringWithFormat:@" %d",oponent.accountDefenseValue+[DuelRewardLogicController countUpBuletsWithPlayerLevel:oponent.accountLevel]];
    oponentDefenseView.hidden = NO;
}

-(void)setOponentMoney:(int)money;
{
    int moneyExch  = playerAccount.money < 10 ? 1: money / 10.0;
// added for thousands separate   
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(moneyExch)]];
    lbGoldCount.text = formattedNumberString;
    
    CGRect frame=lbGoldCount.frame;

    lbGoldCount.font=[UIFont fontWithName: @"MyriadPro-Semibold" size:13];;
    CGSize size=[lbGoldCount fitSizeToText:lbGoldCount];
    frame.size.width=size.width;
    [lbGoldCount setFrame:frame];
    
    [lbGold dinamicAttachToView:lbGoldCount withDirection:DirectionToAnimateRight ];
}

-(void)setOponentImage;
{
    NSString *name = [[OGHelper sharedInstance ] getClearName:oponentAccount.accountID];
    NSString *path=[NSString stringWithFormat:@"%@/icon_%@.png",[[OGHelper sharedInstance] getSavePathForList],name];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){  
        UIImage *image=[UIImage loadImageFullPath:path];
        _ivOponent.image = image;
    }else {
        if ([oponentAccount.accountID rangeOfString:@"F"].location != NSNotFound) {
            iconDownloader = [[IconDownloader alloc] init];
            
            iconDownloader.namePlayer=name;
            iconDownloader.delegate = self;
            if ([oponentAccount.avatar isEqualToString:@""]) {
                NSString *urlOponent=[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",name];
                [iconDownloader setAvatarURL:urlOponent];
            }else {
                [iconDownloader setAvatarURL:oponentAccount.avatar];
            }
            [iconDownloader startDownloadSimpleIcon];
        }else {
            _ivOponent.image = [UIImage imageNamed:@"pv_photo_default.png"];
            _ivOponent.transform = CGAffineTransformIdentity;
            _ivOponent.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            
        }
    }   
}

-(void)startBotDuel
{
    ActiveDuelViewController *activeDuelViewController = [[ActiveDuelViewController alloc] initWithAccount:playerAccount oponentAccount:oponentAccount];
    [self.navigationController pushViewController:activeDuelViewController animated:YES];
    activeDuelViewController = nil;
    [self releaseComponents];
}

- (void)viewDidUnload {
    mainDuelView = nil;
    lbUserRank = nil;
    lbUserDuelsWin = nil;
    lbUserDuelsWinCount = nil;
    lbOpponentRank = nil;
    lbOpponentDuelsWin = nil;
    lbOpponentDuelsWinCount = nil;
    lbForTheMurder = nil;
    lbReward = nil;
    lbGoldCount = nil;
    lbGold = nil;
    lbPointsCount = nil;
    lbPoints = nil;
    [self setFbPlayerImage:nil];
    [self setFbOpponentImage:nil];
    [super viewDidUnload];
}

#pragma mark IconDownloaderDelegate
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    _ivOponent.image = iconDownloader.imageDownloaded;    
}
@end
