//
//  FinalViewController.m
//  Test
//
//  Created by Sobol on 23.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FinalViewController.h"
#import "GameCenterViewController.h"
#import "StartViewController.h"
#import "ProfileViewController.h"
#import "GCHelper.h"
#import "DuelRewardLogicController.h"
#import "AdvertisingAppearController.h"
#import "DuelProductWinViewController.h"
#import "DuelProductDownloaderController.h"

@interface FinalViewController ()
{
    BOOL tryButtonEnabled;
    BOOL isDuelWinWatched;
    BOOL userWon;

}
-(void)winScene;
-(void)loseScene;
-(void)lastScene;
-(void)showMoneyLable;
-(void)checkMaxWin:(int)moneyExch;
-(void)increaseLoseCount;
-(void)increaseWinCount;

@end

#define TAG_TEXT 1002

@implementation FinalViewController

@synthesize delegate;
@synthesize tryButton;

#pragma mark

-(id)initWithUserTime:(int)userTimePar andOponentTime:(int)oponentTime andGameCenterController:(id)delegateController andTeaching:(BOOL)teach andAccount:(AccountDataSource *)userAccount andOpAccount:(AccountDataSource *)opAccount
{
    self = [super initWithNibName:@"FinalViewController" bundle:[NSBundle mainBundle]];

    if (self){
// added 
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/cry.mp3", [[NSBundle mainBundle] resourcePath]]];
        follPlayerFinal= [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
// above
        teaching = teach;
        playerAccount = userAccount;
        oponentAccount = opAccount;
        userTime=userTimePar;
        
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];

        if (teaching) {
            firstRun = ![userDef boolForKey:@"FirstRunForFinal"];
        }else{
            firstRun = NO;
        }
        [userDef setBool:YES forKey:@"FirstRunForFinal"];
        [userDef synchronize];
        
        reachNewLevel = NO;
        lastDuel = NO;
        runAway=NO;
        tryButtonEnabled = YES;
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DUEL_VIEW_NOT_FIRST"];
        
        if (teaching&&(oponentAccount.bot)) {
            duelWithBotCheck=YES;
        }else{
            duelWithBotCheck=NO;
        }
        
        DLog(@"Time final %d  %d",userTime,oponentTime);
            
        transaction = [[CDTransaction alloc] init];
        transaction.trMoneyCh = [NSNumber numberWithInt:10];
        transaction.trDescription = [[NSString alloc] initWithFormat:@"Duel"];
        
        self.delegate = delegateController;
        
        DLog(@"U %d O %d", userTime, oponentTime);
        
        if ((userTime != 0)&& (userTime != 999999) && (userTime < oponentTime)&& (oponentTime != 999999)) {
            [follPlayerFinal setVolume:0.2];
            userWon = YES;
            
        }
        else
            if ((userTime == 0) && (oponentTime != 0) && (oponentTime != 999999)&& (userTime != 999999)) {
                userWon = NO;
              
            }
        
        if ((oponentTime != 0) && (oponentTime != 999999) && (userTime > oponentTime)&& (userTime != 999999)) {
            userWon = NO;              
        } 
        else
            if ((userTime != 0) && (userTime != 999999) && (oponentTime == 0)&& (oponentTime != 999999)) {
                [follPlayerFinal setVolume:0.2];
                userWon = YES;
            }
        
        falseLabel =  NSLocalizedString(@"False", @"");
        foll = NO;
        
        if ((userTime == 999999) && (oponentTime != 999999)) {
            userWon = YES;
        }
        if ((oponentTime == 999999) && (userTime != 999999)){ 
            [follPlayerFinal setVolume:0.2];
            userWon = NO;
        }
        if ((userTime == 999999) && (oponentTime == 999999))
        {
            userWon = YES;
        }
                
        [player setNumberOfLoops:999];
        
        [follPlayerFinal play];
        
    }
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) viewDidLoad {
    [tryButton setTitleByLabel:@"TRY"];
    UIColor *colorOfButtons=[UIColor colorWithRed:0.95 green:0.86 blue:0.68 alpha:1.0];
    [tryButton changeColorOfTitleByLabel:colorOfButtons];
    tryButton.enabled = tryButtonEnabled;
    
    [backButton setTitleByLabel:@"CANCEL_DUEL"];
    [backButton changeColorOfTitleByLabel:colorOfButtons ];
    
    if (playerAccount.accountName != nil)
        lblNamePlayer.text = playerAccount.accountName;
    else
        lblNamePlayer.text = @"YOU";
    [lblNamePlayer setFont: [UIFont fontWithName: @"MyriadPro-Semibold" size:20]];
    lblNameOponnent.text = oponentAccount.accountName;
    
    [lblNameOponnent setFont: [UIFont fontWithName: @"MyriadPro-Semibold" size:20]];
    
    if (userWon) [self winScene];
    else [self loseScene];
    
    [self lastScene];
    [player play];
    activityIndicatorView = [[ActivityIndicatorView alloc] init];
    
    CGRect frame=activityIndicatorView.frame;
    frame.origin=CGPointMake(0, 0);
    activityIndicatorView.frame=frame;
    
    [self.view addSubview:activityIndicatorView];
}

-(void)viewWillAppear:(BOOL)animated
{    
    [activityIndicatorView hideView];
    if([LoginAnimatedViewController sharedInstance].isDemoPractice){
        [tryButton changeTitleByLabel:@"LOGIN"];
    }
    
    if (firstRun) {
        firstRun = NO; 
    }
}

-(void)viewDidAppear:(BOOL)animated
{   
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/FinalVC" forKey:@"page"]];
}

-(void)viewDidDisappear:(BOOL)animated
{
    viewLastSceneAnimation.hidden=NO;
    [player stop];
}

-(void)releaseComponents
{
    activityIndicatorView = nil;
    playerAccount = nil;
    oponentAccount = nil;
    falseLabel = nil;
    player = nil;
    follPlayerFinal = nil;
    transaction = nil;
    _pointForEachLevels = nil;
    _pontsForWin = nil;
    _pontsForLose = nil;
    backButton = nil;
    lblNamePlayer = nil;
    lblNameOponnent = nil;
    ivGoldCoin = nil;
    ivBlueLine = nil;
    ivCurrentRank = nil;
    ivNextRank = nil;
    lblGoldPlus = nil;
    viewLastSceneAnimation = nil;
    loserImg = nil;
    loserSpiritImg = nil;
    winnerImg1 = nil;
    winnerImg2 = nil;
    loserMoneyImg = nil;
    view = nil;
    lblGold = nil;
    gameStatusLable = nil;
    lblPoints = nil;
    goldPointBgView = nil;
    lblGoldTitle = nil;
    
    transaction = nil;
    
    backButton = nil;
    
    
    lblNamePlayer = nil;
    lblNameOponnent = nil;
    
    
    ivGoldCoin = nil;
    ivBlueLine = nil;
    ivCurrentRank = nil;
    ivNextRank = nil;
    lblGoldPlus = nil;
    
    viewLastSceneAnimation = nil;
    
    loserImg = nil;
    loserSpiritImg = nil;
    winnerImg1 = nil;
    winnerImg2 = nil;
    loserMoneyImg = nil;
    
    view = nil;
    
    lblGold = nil;
    gameStatusLable = nil;
    lblPoints = nil;
    goldPointBgView = nil;
    lblGoldTitle = nil;

}

#pragma mark -
#pragma mark IBActions

-(IBAction)backButtonClick:(id)sender
{
    if (lastDuel) {
        
        if(playerAccount.money<0)
            playerAccount.money=0;
        [playerAccount saveMoney];
        
        if (playerAccount.isTryingWeapon) {
            playerAccount.isTryingWeapon = NO;
            if ([LoginAnimatedViewController sharedInstance].isDemoPractice){
                
                [self.navigationController popToViewController:[LoginAnimatedViewController sharedInstance] animated:YES];
                [self releaseComponents];
            }
            else{
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
                [self releaseComponents];
            }
        }else{
            UINavigationController *nav = ((TestAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController;
            for (__weak UIViewController *viewController in nav.viewControllers) {
                if ([viewController isKindOfClass:[ActiveDuelViewController class]]) {
                    [((ActiveDuelViewController *)viewController) releaseComponents];
                }
            }
            [self releaseComponents];
            if ([LoginAnimatedViewController sharedInstance].isDemoPractice){
                
                [nav popToViewController:[nav.viewControllers objectAtIndex:2] animated:YES];
            }
            else{
                [nav popToViewController:[nav.viewControllers objectAtIndex:1] animated:YES];
                
            }
        }
//        if ([self.delegate isKindOfClass:[BluetoothViewController class]]) [self.delegate duelCancel];
        if ([self.delegate isKindOfClass:[GameCenterViewController class]]) {
            [self.delegate performSelector:@selector(matchCanseled)];
        }
         
    }else{
        if (!teaching||duelWithBotCheck) {     
            [self loseScene];
            [self lastScene];

            if ([delegate respondsToSelector:@selector(duelRunAway)])
                [delegate duelRunAway];
            
            runAway=YES;
            runAwayGood=NO;
                        
            [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:@"/FinalVC_run_away" forKey:@"page"]];
            
            
        }else{
            if ([LoginAnimatedViewController sharedInstance].isDemoPractice){
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
                [self releaseComponents];
            }
            else{
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
                [self releaseComponents];
            }
        }
    }
}

-(void)runAway
{
    DLog(@"Run away oponent");
    [self winScene];
    [self lastScene];
    runAway=YES;
    runAwayGood=YES;
}


-(IBAction)tryButtonClick:(id)sender
{
    if([LoginAnimatedViewController sharedInstance].isDemoPractice){
        if ([[StartViewController sharedInstance] connectedToWiFi]) {

            activityIndicatorView = [[ActivityIndicatorView alloc] init];
            
            CGRect frame=activityIndicatorView.frame;
            frame.origin=CGPointMake(0, 0);
            activityIndicatorView.frame=frame;
            
            [self.view addSubview:activityIndicatorView];
        }
        [[LoginAnimatedViewController sharedInstance] loginButtonClick:sender];
        return;
    }
    
    DLog(@"tryButtonClick");
    if(teaching)
    {
        [playerAccount.finalInfoTable removeAllObjects];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        if ([delegate respondsToSelector:@selector(matchStartedTry)]) 
        {
            [delegate matchStartedTry];
        }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/FinalVC_tryAgain" forKey:@"page"]];
}
#pragma  mark -
-(void)loseScene
{
    oldMoneyForAnimation = playerAccount.money;
    isDuelWinWatched = YES;
    lastDuel = YES;
    int moneyExch  = playerAccount.money < 10 ? 1: playerAccount.money / 10.0;
    int pointsForMatch=0;
    gameStatusLable.text = @"You lost";
    [gameStatusLable setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];
    
    [lblGold setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
    [lblGoldTitle setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];
    
    [lblGoldPlus setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
    lblGoldPlus.text = [NSString stringWithFormat:@"-%d",moneyExch];
    lblGoldPlus.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    lblGoldPlus.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    lblGold.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    lblGold.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    if (!teaching||(duelWithBotCheck)) {
        oponentAccount.money += moneyExch;
        
        if(playerAccount.money>=moneyExch){
            playerAccount.money -= moneyExch;
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:-moneyExch];
        }else{
            if (playerAccount.money > 0) {
                transaction.trType = [NSNumber numberWithInt:-1];
                transaction.trMoneyCh = [NSNumber numberWithInt:playerAccount.money];
            }
            playerAccount.money=0;
        }
        
        [self increaseLoseCount];

        DLog(@"Oponent Win - User money %d Oponent money %d", playerAccount.money, oponentAccount.money);
        
        pointsForMatch=[self getPointsForLose];        
    }
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Lose.mp3", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [player play];
    [player setNumberOfLoops:0];
    
    loserImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fv_new_corpse.png"]];
    CGRect frame = loserImg.frame;
    frame.origin.y = 60;
    frame.origin.x = 0;
    loserImg.frame = frame;
    
    [viewLastSceneAnimation addSubview:loserImg];
    
    loserSpiritImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fv_new_corpse_shadow.png"]];
    frame = loserSpiritImg.frame;
    frame.origin.y = 280;
    frame.origin.x = 0;
    loserSpiritImg.frame = frame;
    [viewLastSceneAnimation addSubview:loserSpiritImg];
    [loserSpiritImg setHidden:YES];
    
    loserMoneyImg = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"fv_new_money_dropped.png"]];
    frame = loserMoneyImg.frame;
    frame.origin.x = 20;
    frame.origin.y = ivGoldCoin.frame.origin.y + goldPointBgView.frame.origin.y;
    loserMoneyImg.frame = frame;
    [viewLastSceneAnimation addSubview:loserMoneyImg];
    [loserMoneyImg setHidden:YES];
    
    frame = lblGoldPlus.frame;
    frame.origin.y = 40;
    frame.origin.x = 0;
    lblGoldPlus.frame = frame;
    [viewLastSceneAnimation addSubview:lblGoldPlus];
    [lblGoldPlus setHidden:YES];   
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    [self animationWithLable:lblPoints andStartNumber:[AccountDataSource sharedInstance].accountPoints - pointsForMatch andEndNumber:[AccountDataSource sharedInstance].accountPoints];
    
}

-(void)winScene
{
    isDuelWinWatched = NO;
    lastDuel = YES;
    int moneyExch  = oponentAccount.money < 10 ? 1: oponentAccount.money / 10.0;
    int pointsForMatch=0;
    gameStatusLable.text = @"You win";
    [gameStatusLable setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];
    
   lblGoldPlus.text = [NSString stringWithFormat:@"+%d",moneyExch];
   
    [lblGold setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
    [lblGoldPlus setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
    [lblGoldTitle setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];
    
    lblGoldPlus.hidden = NO;
    lblGoldPlus.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    lblGoldPlus.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    lblGold.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    lblGold.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    oldMoneyForAnimation = playerAccount.money;
    if(!teaching||(duelWithBotCheck)){
// added for GC
        if (![GCHelper sharedInstance].GClocalPlayer.isAuthenticated) {
          [[GCHelper sharedInstance] authenticateLocalUser];
        }else{
            [[GCHelper sharedInstance] reportScore:playerAccount.money forCategory:GC_LEADEBOARD_MONEY];
        }

// above
        oldMoney=playerAccount.money;
        
        playerAccount.money += moneyExch;
        oponentAccount.money -= moneyExch;
        
        [self checkMaxWin:moneyExch];

        //transaction.trType = [NSNumber numberWithInt:moneyExch / abs(moneyExch)];                       //////////////////transactions
        transaction.trType = [NSNumber numberWithInt:1];
        transaction.trMoneyCh = [NSNumber numberWithInt:moneyExch];       

        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"dontShowFeedAtFirst"]) {
            [[StartViewController sharedInstance] setShowFeedAtFirst:YES];
        }
        DLog(@"You Win - User money %d Oponent money %d", playerAccount.money, oponentAccount.money);
        
        [playerAccount saveMoney];
        
        [self increaseWinCount];
        
       pointsForMatch=[self getPointsForWin];
    }            
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Win.mp3", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [player play];
    [player setNumberOfLoops:0];
    
    int iPhone5Delta = [UIScreen mainScreen].bounds.size.height - 480;
    int iPhone5DeltaX = [UIScreen mainScreen].bounds.size.width - 320;
    
    winnerImg1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fin_img_money.png"]];
    CGRect frame = winnerImg1.frame;
    frame.origin.y = 230  + iPhone5Delta;
    frame.origin.x = -150 + iPhone5DeltaX;
    winnerImg1.frame = frame;
    [viewLastSceneAnimation addSubview:winnerImg1];
    
    winnerImg2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fin_img_money2.png"]];
    frame = winnerImg2.frame;
    frame.origin.y = 340 + iPhone5Delta;
    frame.origin.x = 320 + iPhone5DeltaX;
    winnerImg2.frame = frame;
    [viewLastSceneAnimation addSubview:winnerImg2];

    frame = lblGoldPlus.frame;
    frame.origin.x -= 200;
    lblGoldPlus.frame = frame;
    [viewLastSceneAnimation addSubview:lblGoldPlus];
    
    [self animationWithLable:lblPoints andStartNumber:[AccountDataSource sharedInstance].accountPoints - pointsForMatch andEndNumber:[AccountDataSource sharedInstance].accountPoints];
}


-(void)lastScene
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DUEL_VIEW_NOT_FIRST"];
    
    lblGold.shadowColor = [UIColor whiteColor];
    lblGold.shadowOffset=CGSizeMake(1.0, 1.0);
    lblGold.innerShadowColor = [UIColor whiteColor];
    lblGold.innerShadowOffset=CGSizeMake(1.0, 1.0);
    lblGold.shadowBlur = 1.0;
    
    [goldPointBgView setDinamicHeightBackground];
    viewLastSceneAnimation.hidden=NO;
    
    [tryButton setHidden:NO];
    [backButton changeTitleByLabel:@"BACK"];
    
    [activityIndicatorView hideView];

    if (!teaching||(duelWithBotCheck)) {
        
        transaction.trOpponentID = [NSString stringWithString:(oponentAccount.accountID) ? [NSString stringWithString:oponentAccount.accountID]:@""];
        transaction.trLocalID = [NSNumber numberWithInt:[playerAccount increaseGlNumber]];
        [playerAccount.transactions addObject:transaction];
        
        CDTransaction *opponentTransaction = [CDTransaction new];
        [opponentTransaction setTrDescription:[NSString stringWithString:transaction.trDescription]];
        
        if ([transaction.trType intValue] == 1) [opponentTransaction setTrType:[NSNumber numberWithInt:-1]];
        else   [opponentTransaction setTrType:[NSNumber numberWithInt:1]];
        
        [opponentTransaction setTrMoneyCh:[NSNumber numberWithInt:-[transaction.trMoneyCh intValue]]];
        opponentTransaction.trOpponentID = [NSString stringWithString:(playerAccount.accountID) ? [NSString stringWithString:playerAccount.accountID]:@""];
        opponentTransaction.trLocalID = [NSNumber numberWithInt:-1];
        [oponentAccount.transactions addObject:opponentTransaction];
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSMutableArray *locationData = [[NSMutableArray alloc] init];
        [playerAccount saveTransaction];
        
        [def synchronize];
    
        [playerAccount saveMoney];
        
        [def synchronize];
        
        [playerAccount sendTransactions:playerAccount.transactions];
        if (oponentAccount.bot) [oponentAccount sendTransactions:oponentAccount.transactions];
        
        if (reachNewLevel) {
            [self showMessageOfNewLevel];
            reachNewLevel=NO;
        }

        if (userWon) {
            if ((oldMoney<500)&&(playerAccount.money>=500)&&(playerAccount.money<1000)) {
                NSString *moneyText=[NSString stringWithFormat:@"%d",playerAccount.money];
                [self showMessageOfMoreMoney:playerAccount.money withLabel:moneyText];
            }else {
                int thousandOld=oldMoney/1000;
                int thousandNew=playerAccount.money/1000;
                int thousandSecond=(playerAccount.money % 1000)/100;
                if (thousandNew>thousandOld) {
                    if (thousandSecond==0) {
                        [self showMessageOfMoreMoney:playerAccount.money withLabel:[NSString stringWithFormat:@"+%dK",thousandNew]];
                    }else {
                        [self showMessageOfMoreMoney:playerAccount.money withLabel:[NSString stringWithFormat:@"+%d.%dK",thousandNew,thousandSecond]];
                    }
                }
            }
            oldMoney=0;
        }
        
        [[StartViewController sharedInstance] modifierUser:playerAccount];
        if(oponentAccount.bot)
            [[StartViewController sharedInstance] modifierUser:oponentAccount];
    }
    
    if (playerAccount.accountLevel == kCountOfLevels){
        NSString *name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel];
        ivCurrentRank.image = [UIImage imageNamed:name];
    }
    else{
        NSString *name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel];
        ivCurrentRank.image = [UIImage imageNamed:name];
        name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel+1];
        ivNextRank.image = [UIImage imageNamed:name];
    }
    if (!userWon) {
        [self loseAnimation];
    }
    else {
        winnerImg1.hidden = NO;
        winnerImg2.hidden = NO;
        [self winAnimation];
    }
    [self.view bringSubviewToFront:activityIndicatorView];
    
    if ([LoginAnimatedViewController sharedInstance].isDemoPractice){
        [self performSelector:@selector(scaleView:) withObject:tryButton  afterDelay:1.5];
    }
}

#pragma mark Animations

-(void)scaleView:(UIView *)scaleView
{
    [UIView animateWithDuration:0.6 animations:^{
        scaleView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL complete) {
        [UIView animateWithDuration:0.6 animations:^{
            scaleView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }completion:^(BOOL complete){
        } ];
    }];
}

-(void)winAnimation
{
  int iPhone5Delta = [UIScreen mainScreen].bounds.size.height - 480;
    
  [lblGoldPlus setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
  
  CGRect deltaFrameI5 = lblGoldPlus.frame;
  deltaFrameI5.origin.y += iPhone5Delta;
  [lblGoldPlus setFrame:deltaFrameI5];
  
  lblGold.hidden = YES;
  lblGold.text = [NSString stringWithFormat:@"%d",playerAccount.money];
  
  [self coinCenter];
  lblGold.text = [NSString stringWithFormat:@"%d",oldMoneyForAnimation];
    
  CGRect goldCountCentered = lblGold.frame;
  goldCountCentered.origin.x = ivGoldCoin.frame.origin.x+ivGoldCoin.frame.size.width + 5;
  lblGold.frame = goldCountCentered;
  lblGold.hidden = NO;
  
  CGRect frame1 = winnerImg1.frame;
  frame1.origin.x += 200;
  CGRect frame = winnerImg2.frame;
  frame.origin.x -= 230;
  CGRect movePlus = lblGoldPlus.frame;
  movePlus.origin.x += 200;
  

  CGRect moveGoldToCoin = winnerImg2.frame;
  moveGoldToCoin.origin.x = ivGoldCoin.frame.origin.x + goldPointBgView.frame.origin.x - 50;
  moveGoldToCoin.origin.y = ivGoldCoin.frame.origin.y + goldPointBgView.frame.origin.y + iPhone5Delta;
  
  CGAffineTransform goldPlusZoomIn = CGAffineTransformScale(lblGoldPlus.transform, 1.5, 1.5);
  CGAffineTransform goldPlusZoomOut = CGAffineTransformScale(lblGoldPlus.transform, 1, 1);
  CGAffineTransform goldCoinZoomIn = CGAffineTransformScale(ivGoldCoin.transform, 2, 2);
  CGAffineTransform goldCoinZoomOut = CGAffineTransformScale(ivGoldCoin.transform, 1, 1);
  CGAffineTransform goldZoomIn = CGAffineTransformScale(winnerImg2.transform, 0.5, 0.5);
  
  NSArray *array=[DuelRewardLogicController getStaticPointsForEachLevels];
  
  if (playerAccount.accountLevel < kCountOfLevelsMinimal || playerAccount.accountLevel > kCountOfLevels ){
    [playerAccount setAccountLevel:kCountOfLevels];
  }
  
  NSInteger num = playerAccount.accountLevel;
    int  moneyForNextLevel=(playerAccount.accountLevel != kCountOfLevels)? [[array objectAtIndex:num] intValue]:playerAccount.accountPoints+1000;
  
  int moneyForPrewLevel;
  if (playerAccount.accountLevel==kCountOfLevelsMinimal) {
    moneyForPrewLevel = 0;
  }else
      if (playerAccount.accountLevel == kCountOfLevels) {
          moneyForPrewLevel = playerAccount.accountPoints;
      }
    else
  {
    moneyForPrewLevel=[[array objectAtIndex:(playerAccount.accountLevel-1)] intValue];
  }
  
  
  int curentPoints=(playerAccount.accountPoints-moneyForPrewLevel);
  int maxPoints=(moneyForNextLevel-moneyForPrewLevel);
  CGRect temp = ivBlueLine.frame;
  temp.size.width = 0;
  ivBlueLine.frame = temp;
  
  [UIView animateWithDuration:0.7
                        delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     winnerImg1.frame = frame1;
                     winnerImg2.frame = frame;
                     lblGoldPlus.frame = movePlus;
                   } completion:^(BOOL finished) {
                     [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                                      animations:^{
                                        lblGoldPlus.transform = goldPlusZoomIn;
                                      } completion:^(BOOL finished) {
                                        [UIView animateWithDuration:0.5 animations:^{
                                          lblGoldPlus.transform = goldPlusZoomOut;
                                          
                                        } completion:^(BOOL finished) {
                                          [UIView animateWithDuration:0.7 animations:^{
                                            ivGoldCoin.transform = goldCoinZoomIn;
                                            winnerImg2.frame = moveGoldToCoin;

                                          } completion:^(BOOL finished) {
                                            [UIView animateWithDuration:0.5 animations:^{
                                              ivGoldCoin.transform = goldCoinZoomOut;
                                              winnerImg2.transform = goldZoomIn;
                                              [winnerImg2 setAlpha:0.0];
                                            } completion:^(BOOL finished) {
                                              [self animationWithLable:lblGold andStartNumber:oldMoneyForAnimation andEndNumber:playerAccount.money];
                                              [self changePointsLine:curentPoints maxValue:maxPoints animated:YES];
                                              
                                            }];
                                          }];
          
                                        }];
                                        

                                     }];
                     
                   }];
}

-(void)prepeareForWinScene;
{
    tryButtonEnabled = NO;
    userWon = YES;
}

-(void)prepeareForLoseScene{
    tryButtonEnabled = NO;
    userWon = NO;
}

-(void)loseAnimation
{
    int iPhone5Delta = [UIScreen mainScreen].bounds.size.height - 480;
    int iPhone5DeltaX = [UIScreen mainScreen].bounds.size.width - 320;
    
  loserImg.hidden = NO;
//  if (teaching && !(duelWithBotCheck))oldMoneyForAnimation = [AccountDataSource sharedInstance].money;
  lblGold.text = [NSString stringWithFormat:@"%d",oldMoneyForAnimation];
  
  CGRect frameL = loserMoneyImg.frame;
  frameL.origin.x = 20;
  frameL.origin.y = ivGoldCoin.frame.origin.y + goldPointBgView.frame.origin.y;
  loserMoneyImg.frame = frameL;
  loserMoneyImg.hidden = YES;
  
  CGAffineTransform goldPlusZoomOut = CGAffineTransformScale(lblGoldPlus.transform, 1.5, 1.5);
  CGAffineTransform goldPlusZoomIn = CGAffineTransformScale(lblGoldPlus.transform, 1, 1);

  CGAffineTransform goldDroppedZoomIn = CGAffineTransformScale(loserMoneyImg.transform, 0.1, 0.1);
  CGAffineTransform goldDroppedZoomOut = CGAffineTransformScale(loserMoneyImg.transform, 1.0, 1.0);
  
  CGAffineTransform goldMove = CGAffineTransformTranslate(goldDroppedZoomOut, +100, +195 + iPhone5Delta);
  lblGoldPlus.hidden = NO;

  CGRect temp = ivBlueLine.frame;
  temp.size.width = 0;
  ivBlueLine.frame = temp;
  
  CGRect frame = loserImg.frame;
  frame.origin.x = -200 + iPhone5DeltaX;
  frame.origin.y += 230 + iPhone5Delta;
  loserImg.frame = frame;
  
  CGRect moveLoserToScreen = frame;
  moveLoserToScreen.origin.x = 0;
  
  frame = lblGoldPlus.frame;
  frame.origin.x = 320;
  frame.origin.y = loserImg.frame.origin.y;
  lblGoldPlus.frame = frame;
  CGRect moveMinusToScreen = lblGoldPlus.frame;
  moveMinusToScreen.origin.x = 0;
  
  CGRect moneyDropBup = loserMoneyImg.frame;
  moneyDropBup.origin.x = ivGoldCoin.frame.origin.x - loserMoneyImg.frame.size.width/2;// + goldPointBgView.frame.origin.x;
  moneyDropBup.origin.y = ivGoldCoin.frame.origin.y + goldPointBgView.frame.origin.y;
  loserMoneyImg.frame = moneyDropBup;
  loserMoneyImg.transform = goldDroppedZoomIn;
  
  [lblGoldPlus setHidden:NO];
  
  [self coinCenter];
  
  lblGold.hidden = YES;
  CGRect goldCountCentered = lblGold.frame;
  goldCountCentered.origin.x = ivGoldCoin.frame.origin.x+ivGoldCoin.frame.size.width + 5;
  lblGold.frame = goldCountCentered;
  lblGold.hidden = NO;
  
  [UIView animateWithDuration:1.2 delay:0.0
    options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction animations:^{
      loserImg.frame = moveLoserToScreen;
      lblGoldPlus.frame = moveMinusToScreen;
    }
    completion:^(BOOL completion){
      [loserSpiritImg setHidden:NO];
      
      [UIView animateWithDuration:0.5 delay:0.0
          options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction animations:^{
           CGRect frame = loserSpiritImg.frame;
           frame.origin.y -= 25;
           frame.origin.x += 20;
           loserSpiritImg.frame = frame;
           loserSpiritImg.transform = CGAffineTransformMakeScale(0.9, 0.9);
           loserSpiritImg.alpha = 0.6;
           
         }
         completion:^(BOOL completion){
            [UIView animateWithDuration:0.5 delay:0.0
                                options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction animations:^{
                                  CGRect frame = loserSpiritImg.frame;
                                  frame.origin.y -= 50;
                                  frame.origin.x -= 40;
                                  loserSpiritImg.frame = frame;
                                  loserSpiritImg.transform = CGAffineTransformMakeScale(0.8, 0.8);
                                  loserSpiritImg.alpha = 0.3;
                                  
            }
               completion:^(BOOL completion){
                 [UIView animateWithDuration:0.5 delay:0.0
                                     options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction animations:^{
                                       CGRect frame = loserSpiritImg.frame;
                                       frame.origin.y -= 100;
                                       frame.origin.x += 80;
                                       loserSpiritImg.frame = frame;
                                       loserSpiritImg.transform = CGAffineTransformMakeScale(0.7, 0.7);
                                       loserSpiritImg.alpha = 0.0;
                                       lblGoldPlus.transform = goldPlusZoomOut;
                                       
                  }
                  completion:^(BOOL completion){
                    loserMoneyImg.hidden = NO;
                    [UIView animateWithDuration:1.0 animations:^{
                      loserMoneyImg.transform = goldMove;
                      lblGoldPlus.transform = goldPlusZoomIn;
                      CGRect frame = lblGoldPlus.frame;
                      frame.origin.y -= 50;
                      lblGoldPlus.frame = frame;
                      [lblGoldPlus setAlpha:0.0];
                      [self animationWithLable:lblGold andStartNumber:oldMoneyForAnimation andEndNumber:[AccountDataSource sharedInstance].money];
                    } completion:^(BOOL finished) {
  
                    }];
                  }];
             }];
          }];
    }];
  //Blue line animation:
  NSArray *array=[DuelRewardLogicController getStaticPointsForEachLevels];
  if (playerAccount.accountLevel < kCountOfLevelsMinimal || playerAccount.accountLevel > kCountOfLevels ){
    [playerAccount setAccountLevel:kCountOfLevels];
  }
  NSInteger num = playerAccount.accountLevel;
  int  moneyForNextLevel=(playerAccount.accountLevel != kCountOfLevels) ? [[array objectAtIndex:num] intValue]:playerAccount.accountPoints+1000;
  int moneyForPrewLevel;
  if (playerAccount.accountLevel==kCountOfLevelsMinimal) {
    moneyForPrewLevel = 0;
  }else
      if (playerAccount.accountLevel == kCountOfLevels) {
          moneyForPrewLevel = playerAccount.accountPoints;
      }
      else{
        moneyForPrewLevel=[[array objectAtIndex:(playerAccount.accountLevel-1)] intValue];
      }
  int curentPoints=(playerAccount.accountPoints-moneyForPrewLevel);
  int maxPoints=(moneyForNextLevel-moneyForPrewLevel);
  [self changePointsLine:curentPoints maxValue:maxPoints animated:NO];
}

-(void)coinCenter
{
    ivGoldCoin.hidden = YES;
    CGRect coinCentered = ivGoldCoin.frame;
    coinCentered.origin.x = goldPointBgView.frame.size.width/2 - ivGoldCoin.frame.size.width - 10*lblGold.text.length;
    if (coinCentered.origin.x > 0)
    ivGoldCoin.frame = coinCentered;
    else
    {
        coinCentered.origin.x = 0;
        ivGoldCoin.frame = coinCentered;
    }
    ivGoldCoin.hidden = NO;
}
#pragma mark - check Level, Points change and other saved features

-(NSInteger)getPointsForWin;
{
    NSInteger oldL=playerAccount.accountPoints;
    int winPonits=[DuelRewardLogicController getPointsForWinWithOponentLevel:oponentAccount.accountLevel];
    playerAccount.accountPoints+=winPonits;
    [playerAccount saveAccountPoints];

    [self compareNewLevel:playerAccount.accountPoints withOldLevel:oldL];
    
    return winPonits;
}

-(NSInteger)getPointsForLose;
{
    NSInteger oldL=playerAccount.accountPoints;
    int losePonits=[DuelRewardLogicController getPointsForLoseWithOponentLevel:oponentAccount.accountLevel];
    playerAccount.accountPoints+=losePonits;
    [playerAccount saveAccountPoints];
    
    [self compareNewLevel:playerAccount.accountPoints withOldLevel:oldL];
    
    return losePonits;
}

-(void)compareNewLevel:(NSInteger)newL withOldLevel:(NSInteger) oldL;
{
    _pointForEachLevels=[DuelRewardLogicController getStaticPointsForEachLevels];

    for ( NSNumber *pointMoney in _pointForEachLevels) {
        if (([pointMoney intValue]<=newL)&&([pointMoney intValue]>oldL)) {
            int playerNewLevel=[_pointForEachLevels indexOfObject:pointMoney]+1;
            if (playerNewLevel < kCountOfLevelsMinimal || playerNewLevel > kCountOfLevels ){
                playerNewLevel = kCountOfLevels;
            }
            NSLog(@"playerNewLevel %d pointMoney %d",playerNewLevel,[pointMoney intValue]);
            playerAccount.accountLevel=playerNewLevel;
            [playerAccount saveAccountLevel];
            
            reachNewLevel=YES;
          // added for GC
            if (![GCHelper sharedInstance].GClocalPlayer.isAuthenticated) {
              [[GCHelper sharedInstance] authenticateLocalUser];
            }else{
                [[GCHelper sharedInstance] reportAchievementIdentifier:[[GCHelper sharedInstance].GC_ACH objectAtIndex:playerAccount.accountLevel] percentComplete:100.0f];
            }
          // above
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark -

-(void)showMessageOfNewLevel
{
    LevelCongratViewController *lvlCongratulationViewController=[[LevelCongratViewController alloc] initForNewLevelPlayerAccount:playerAccount andController:self tryButtonEnable:tryButton.enabled];
    [self performSelector:@selector(showViewController:) withObject:lvlCongratulationViewController afterDelay:4.5];
}

-(void)showMessageOfMoreMoney:(NSInteger)money withLabel:(NSString *)labelForCongratulation
{
    MoneyCongratViewController *moneyCongratulationViewController  = [[MoneyCongratViewController alloc] initForAchivmentPlayerAccount:playerAccount withLabel:labelForCongratulation andController:self tryButtonEnable:tryButton.enabled];
    [self performSelector:@selector(showViewController:) withObject:moneyCongratulationViewController afterDelay:4.5];
}

#pragma mark -

-(void)checkMaxWin:(int)moneyExch;
{
    if (playerAccount.accountBigestWin==0){
        playerAccount.accountBigestWin=moneyExch;
    }
    else
    {
        if (moneyExch>playerAccount.accountBigestWin) {
            playerAccount.accountBigestWin=moneyExch;
        }
    }
    [playerAccount saveAccountBigestWin];
}

-(void)increaseLoseCount;
{
    if (playerAccount.accountDraws==0){
        playerAccount.accountDraws=1;
    }
    else
    {
        playerAccount.accountDraws++;
    }
    [playerAccount saveAccountDraws];
}

-(void)increaseWinCount;

{
    if ( playerAccount.accountWins==0){
        playerAccount.accountWins=1;
    }
    else
    {
         playerAccount.accountWins++;
    }
    [playerAccount saveAccountWins];
//    [playerAccount accountWins];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -

-(void)startBotDuelTryAgain
{
    [playerAccount.finalInfoTable removeAllObjects];
    DuelStartViewController  *tempVC=(DuelStartViewController*)[self.navigationController.viewControllers objectAtIndex:2] ;
    [tempVC setMessageTry];
    [tempVC setUserMoney:playerAccount.money];
    [tempVC setOponentMoney:oponentAccount.money];
    [self.navigationController popToViewController:tempVC animated:YES];
}


- (void)viewDidUnload {
    lblGold = nil;
    gameStatusLable = nil;
    lblPoints = nil;
    lblGoldTitle = nil;
    ivGoldCoin = nil;
    ivBlueLine = nil;
    ivCurrentRank = nil;
    ivNextRank = nil;
    lblGoldPlus = nil;

    [super viewDidUnload];
}

-(void)animationWithLable:(UILabel *)lable andStartNumber:(int)startNumber andEndNumber:(int)endNumber
{
    float goldForGoldAnimation;
    if (abs(endNumber - startNumber) < 110) {
        goldForGoldAnimation = 1;
    }else {
        goldForGoldAnimation = abs(endNumber - startNumber)/110;
    }
    if (startNumber<endNumber)
        dispatch_async(dispatch_queue_create([lable.text cStringUsingEncoding:NSUTF8StringEncoding], NULL), ^{
            {
                for (int i = startNumber; i <= endNumber; i += goldForGoldAnimation) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        lable.text = [NSString stringWithFormat:@"%d", i];
                    });
                    
                    [NSThread sleepForTimeInterval:0.02];
                    
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    lable.text = [NSString stringWithFormat:@"%d", endNumber];
                });
                
            }
        });
    else
        dispatch_async(dispatch_queue_create([lable.text cStringUsingEncoding:NSUTF8StringEncoding], NULL), ^{
            for (int i = startNumber; i >= endNumber; i -= goldForGoldAnimation) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    lable.text = [NSString stringWithFormat:@"%d", i];
                });
                
                [NSThread sleepForTimeInterval:0.02];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                lable.text = [NSString stringWithFormat:@"%d", endNumber];
            });
        });
}

-(void)changePointsLine:(int)points maxValue:(int) maxValue animated:(BOOL)animated;
{
  CGRect backup = ivBlueLine.frame;
  CGRect temp = backup;
  temp.size.width = 0;
  ivBlueLine.frame = temp;
  
  if (points <= 0) points = 0;
  int firstWidthOfLine=lblPoints.frame.size.width;
  float changeWidth=(points*firstWidthOfLine)/maxValue;
  
  temp.size.width = changeWidth;
  
  if (animated) {
      [UIView animateWithDuration:1.4 animations:^{
        ivBlueLine.frame = temp;
      }];
  } else {
    ivBlueLine.frame = temp;
  }
}

-(void)showViewController:(UIViewController *)viewController
{
    [self presentModalViewController:viewController animated:YES];
    viewController = nil;
}

@end
