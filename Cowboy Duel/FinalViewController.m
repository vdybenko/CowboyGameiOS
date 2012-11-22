//
//  FinalViewController.m
//  Test
//
//  Created by Sobol on 23.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FinalViewController.h"
//#import "BluetoothViewController.h"
#import "TeachingViewController.h"
#import "GameCenterViewController.h"
#import "StartViewController.h"
#import "AdColonyViewController.h"
#import "ProfileViewController.h"
#import "GCHelper.h"
#import "DuelRewardLogicController.h"
#import "AdvertisingAppearController.h"

@interface FinalViewController ()
{
    BOOL tryButtonEnabled;
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
@synthesize tryButton, viewWin, lblWinEarned, lblWinGold, lblWinGoldCount, lblWinPoints, lblWinPointsCount;
@synthesize viewLose, lblLoseEarned, lblLoseLost, lblLoseGold, lblLoseGoldCount, lblLosePoints, lblLosePointsCount;
@synthesize statView;

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
        
        if (teaching&&(oponentAccount.accountName != NSLocalizedString(@"COMPUTER", @""))) {
            duelWithBotCheck=YES;
        }else{
            duelWithBotCheck=NO;
        }
        
        DLog(@"Time final %d  %d",userTime,oponentTime);
        stGA = [[NSString alloc] init];
        
        if([delegateController isKindOfClass:[TeachingViewController class]]){
            if (duelWithBotCheck) {
                stGA = @"/duel_BOT/";
            }else{
                stGA = @"/duel_teaching/";
            }
            teachingViewController = delegateController;
        }else if([delegateController isKindOfClass:[GameCenterViewController class]]){
            stGA = @"/duel_GS/";
        }  
        
        
        transaction = [[CDTransaction alloc] init];
        transaction.trMoneyCh = [NSNumber numberWithInt:10];
        
        
        transaction.trDescription = [[NSString alloc] initWithFormat:@"Duel"];
        
        duel = [[CDDuel alloc] init];
        duel.dOpponentId = [[NSString alloc] initWithFormat:@""];
      
        
        resoultDataSource = [[ResoultDataSource alloc] init];
        self.delegate = delegateController;
        
        DLog(@"U %d O %d", userTime, oponentTime);
        
        if ((userTime != 0)&& (userTime != 999999) && (userTime < oponentTime)&& (oponentTime != 999999)) {
            [delegate increaseMutchNumberWin];
            // added               
            [follPlayerFinal setVolume:0.2];
            // above               
            [delegate increaseMutchNumber];
            resoultDataSource.result = YES;
            
        }
        else
            if ((userTime == 0) && (oponentTime != 0) && (oponentTime != 999999)&& (userTime != 999999)) {
                [delegate increaseMutchNumberLose];
                [delegate increaseMutchNumber];
                resoultDataSource.result = NO;
              
            }
        
        if ((oponentTime != 0) && (oponentTime != 999999) && (userTime > oponentTime)&& (userTime != 999999)) {
            [delegate increaseMutchNumberLose];
            [delegate increaseMutchNumber];
            resoultDataSource.result = NO;              
        } 
        else
            if ((userTime != 0) && (userTime != 999999) && (oponentTime == 0)&& (oponentTime != 999999)) {
                [delegate increaseMutchNumberWin];
                // added               
                [follPlayerFinal setVolume:0.2];
                // above               
                [delegate increaseMutchNumber];
                resoultDataSource.result = YES;
            }
        
        resoultDataSource.foll = NO;
        resoultDataSource.deadHeat = NO;
        falseLabel =  NSLocalizedString(@"False", @"");
        foll = NO;
        
        if ((userTime == 999999) && (oponentTime != 999999)) {
            falseLabel = NSLocalizedString(@"False", @"") ;
            [delegate increaseMutchNumberLose];
            [delegate increaseMutchNumber];
            resoultDataSource.foll = YES;
            resoultDataSource.result = YES;
        }
        if ((oponentTime == 999999) && (userTime != 999999)){ 
            falseLabel =  NSLocalizedString(@"Falses", @"");
            [delegate increaseMutchNumberWin];
            // added               
            [follPlayerFinal setVolume:0.2];
            // above               
            [delegate increaseMutchNumber];
            resoultDataSource.foll = YES;
            resoultDataSource.result = NO;
            DLog(@"Oponent fouled");
        }
        if ((userTime == 999999) && (oponentTime == 999999))
        {
            //falseLabel =  NSLocalizedString(@"Bouth false", @"");
            resoultDataSource.deadHeat = YES;
            resoultDataSource.foll = YES;
            resoultDataSource.result = YES;
        }
        
        fMutchNumberWin = [delegate fMutchNumberWin];
        DLog(@"win %d",fMutchNumberWin);
        fMutchNumberLose = [delegate fMutchNumberLose];
        resoultDataSource.mutchNumber = [delegate fMutchNumber];
        resoultDataSource.deltaTime = userTime;
        resoultDataSource.UserTime= userTime;  
        
        [playerAccount.finalInfoTable addObject:resoultDataSource];
        
        if((resoultDataSource.mutchNumber!=3)&&(resoultDataSource.mutchNumber!=0)) {
            NSString *resultOfMutch;
            if (resoultDataSource.result) {
                
                if(!resoultDataSource.foll){
                    resultOfMutch=@"Win";
                }else{
                    resultOfMutch=@"Fouled_User";
                }
            }
            else {
                if(!resoultDataSource.foll){
                    resultOfMutch=@"Lost";
                }else{
                    resultOfMutch=@"Fouled_Oponent";
                }
                
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                                object:self
                                                              userInfo:
             [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@match_%d(%@)",stGA,resoultDataSource.mutchNumber,resultOfMutch] forKey:@"event"]];
            
        }
        
        [player setNumberOfLoops:999];
        
        [follPlayerFinal play];
        
        if (!lastDuel) {
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Back2.mp3", [[NSBundle mainBundle] resourcePath]]];
            NSError *error;
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            [player play];
            [player stop];
        }
    }
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) viewDidLoad {
     
    [lblResulDescription setFont: [UIFont fontWithName: @"DecreeNarrow" size:30]];
       
    [tryButton setTitleByLabel:@"TRY"];
    UIColor *colorOfButtons=[UIColor colorWithRed:0.95 green:0.86 blue:0.68 alpha:1.0];
    [tryButton changeColorOfTitleByLabel:colorOfButtons];
    tryButton.enabled = tryButtonEnabled;
    
    [nextButton setTitleByLabel:@"NEXTR"];
    if (lastDuel)
        nextButton.hidden = YES;
    else
        nextButton.hidden = NO;
    [nextButton changeColorOfTitleByLabel:colorOfButtons];
    
    [backButton setTitleByLabel:@"CANCEL_DUEL"];
    [backButton changeColorOfTitleByLabel:colorOfButtons ];
    
    resultTable.delegate = self;
    resultTable.dataSource = self;
    
    if (playerAccount.accountName != nil) lblNamePlayer.text = playerAccount.accountName;
    else lblNamePlayer.text = @"YOU";
    [lblNamePlayer setFont: [UIFont fontWithName: @"MyriadPro-Semibold" size:20]];
    lblNameOponnent.text = oponentAccount.accountName;
    
    [lblNameOponnent setFont: [UIFont fontWithName: @"MyriadPro-Semibold" size:20]];
    
    if (fMutchNumberWin == 2) {
        [self winScene];
    }
    if (fMutchNumberLose == 2) {
        [self loseScene];
    }

    if (lastDuel) {
        [self lastScene];
        [player play];
    }
    else {
        viewLastSceneAnimation.hidden=YES;
    }
    activityIndicatorView = [[ActivityIndicatorView alloc] init];
    
    CGRect frame=activityIndicatorView.frame;
    frame.origin=CGPointMake(0, 0);
    activityIndicatorView.frame=frame;
    
    [self.view addSubview:activityIndicatorView];
}

-(void)viewWillAppear:(BOOL)animated
{    
    [activityIndicatorView hideView];
    
    if (firstRun) {
        firstRun = NO; 
    }
    else {
        [hudView setHidden:YES];
    }
    
    [statView setDinamicHeightBackground];
}

-(void)viewDidAppear:(BOOL)animated
{   
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    viewLastSceneAnimation.hidden=NO;
    [player stop];
}
#pragma mark -

-(IBAction)backButtonClick:(id)sender
{
    if (lastDuel) {
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        if (([userDef integerForKey:@"FirstRunForPractice"] != 1)&&([userDef integerForKey:@"FirstRunForPractice"] != 2)) {
            [userDef setInteger:1 forKey:@"FirstRunForPractice"];
            [userDef synchronize];
        }
        
        if(playerAccount.money<0) playerAccount.money=0;
        [playerAccount saveMoney];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
//        if ([self.delegate isKindOfClass:[BluetoothViewController class]]) [self.delegate duelCancel];
        if ([self.delegate isKindOfClass:[GameCenterViewController class]]) {
            [self.delegate performSelector:@selector(matchCanseled)];
            
        }
        
    }else{
        if (!teaching||duelWithBotCheck) {     
            fMutchNumberLose = 2;
            [self loseScene];
            [self lastScene];

            if ([delegate respondsToSelector:@selector(duelRunAway)])
                [delegate duelRunAway];
            
            runAway=YES;
            runAwayGood=NO;
            resoultDataSource = [[ResoultDataSource alloc] init];
            [playerAccount.finalInfoTable addObject:resoultDataSource];
            [resultTable reloadData];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@%@",stGA,@"run_away"] forKey:@"event"]];
            
            
        }else{
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
        }
    }
}

-(void)runAway
{
    DLog(@"Run away oponent");
    fMutchNumberLose = 3;
    [self winScene];
    [self lastScene];
    runAway=YES;
    runAwayGood=YES;
    resoultDataSource = [[ResoultDataSource alloc] init];
    [playerAccount.finalInfoTable addObject:resoultDataSource];
    [resultTable reloadData];
}

-(IBAction)nextButtonClick:(id)sender
{
    [activityIndicatorView showView];
    if(teaching)
    {
        if ((fMutchNumberWin != 2)&&(fMutchNumberLose != 2)) 
            [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(nextDuelStart)])
        {
            [delegate nextDuelStart];
        }
    }
}

-(IBAction)tryButtonClick:(id)sender
{
    DLog(@"tryButtonClick");
    [activityIndicatorView showView];
    if(teaching)
    {
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        if (([userDef integerForKey:@"FirstRunForPractice"] != 1)&&([userDef integerForKey:@"FirstRunForPractice"] != 2)) {
            [userDef setInteger:1 forKey:@"FirstRunForPractice"];
            [userDef synchronize];
        }

        [playerAccount.finalInfoTable removeAllObjects];
        teachingViewController.mutchNumber = 0;
        teachingViewController.mutchNumberWin = 0;
        teachingViewController.mutchNumberLose = 0;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        if ([delegate respondsToSelector:@selector(matchStartedTry)]) 
        {
            [delegate matchStartedTry];
        }
}
#pragma  mark -
-(void)loseScene
{
    lastDuel = YES;
    int moneyExch  = playerAccount.money < 10 ? 1: playerAccount.money / 10.0;
    int pointsForMatch=0;
    gameStatusLable.text = @"You lost";
    [gameStatusLable setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];

    lblWinGold.text = [NSString stringWithFormat:@"%@%d", @"$", moneyExch];
    
    [lblGold setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
    [lblGoldTitle setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];
    
    [lblGoldPlus setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
    lblGoldPlus.text = [NSString stringWithFormat:@"-%d",moneyExch];
    lblGoldPlus.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    lblGoldPlus.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    lblGold.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    lblGold.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@%@",stGA,@"final"] forKey:@"event"]];
//    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@%@",stGA,@"final"]];

    int oldMoney=playerAccount.money;
    oldMoneyForAnimation = playerAccount.money;
    if (!teaching||(duelWithBotCheck)) {
        oponentAccount.money += moneyExch;
        
        int difference=playerAccount.money-moneyExch;
        
        if(difference>0){
            playerAccount.money -= moneyExch;
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:-moneyExch];
        }else{
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:-playerAccount.money];
            playerAccount.money=0;
        }
        
        for (int i=0; i<[playerAccount.finalInfoTable count]; i++) {
            resoultDataSource = [playerAccount.finalInfoTable objectAtIndex:i];
            if(i==0){
                minUserTime=resoultDataSource.UserTime;
            }else{
                if (minUserTime>resoultDataSource.UserTime) {
                    minUserTime=resoultDataSource.UserTime;
                }
            }
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

    [lblLoseEarned setFont: [UIFont fontWithName: @"MyriadPro-Semibold" size:13]];
    [lblLoseLost setFont: [UIFont fontWithName: @"MyriadPro-Semibold" size:13]];
    [lblLoseGold setFont: [UIFont fontWithName: @"MyriadPro-Semibold" size:13]];
    [lblLoseGoldCount setFont: [UIFont fontWithName: @"MyriadPro-Semibold" size:13]];
    [lblLosePoints setFont: [UIFont fontWithName: @"MyriadPro-Semibold" size:13]];
    [lblLosePointsCount setFont: [UIFont fontWithName: @"MyriadPro-Semibold" size:13]];

    lblLoseEarned.text=NSLocalizedString(@"YouEarned", @"");
    lblLoseLost.text=NSLocalizedString(@"YouLost", @"");
    lblLoseGold.text=NSLocalizedString(@"Gold", @"");
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:( playerAccount.money)]];
    lblLoseGoldCount.text=[NSString stringWithFormat:@"%@",formattedNumberString];
    
    lblLosePointsCount.text=[NSString stringWithFormat:@"%d",pointsForMatch];   
    
    if ([lblLosePointsCount isEqual:@"1"]) {
        lblLosePoints.text=NSLocalizedString(@"Point", @"");
    } else {
        lblLosePoints.text=NSLocalizedString(@"Points", @"");
    }
    [self animationWithLable:lblPoints andStartNumber:[AccountDataSource sharedInstance].accountPoints - pointsForMatch andEndNumber:[AccountDataSource sharedInstance].accountPoints];
    
}

-(void)winScene
{
    lastDuel = YES;
    int moneyExch  = oponentAccount.money < 10 ? 1: oponentAccount.money / 10.0;
    int pointsForMatch=0;
    gameStatusLable.text = @"You win";
    [gameStatusLable setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];
    
    lblWinGold.text = [NSString stringWithFormat:@"%@%d", @"$", moneyExch];
   lblGoldPlus.text = [NSString stringWithFormat:@"+%d",moneyExch];
   
    [lblGold setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
    [lblGoldPlus setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
    [lblGoldTitle setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];
    
    lblGoldPlus.hidden = NO;
    lblGoldPlus.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    lblGoldPlus.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    lblGold.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    lblGold.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@%@",stGA,@"final"] forKey:@"event"]];
    oldMoneyForAnimation = playerAccount.money;
    if(!teaching||(duelWithBotCheck)){
// added for GC
        if (![GCHelper sharedInstance].GClocalPlayer.isAuthenticated) {
          [[GCHelper sharedInstance] authenticateLocalUser];
        }

        [[GCHelper sharedInstance] reportScore:moneyExch forCategory:GC_LEADEBOARD_MONEY];
// above
        oldMoney=playerAccount.money;
        
        playerAccount.money += moneyExch;
        oponentAccount.money -= moneyExch;
        
        [self checkMaxWin:moneyExch];

        //transaction.trType = [NSNumber numberWithInt:moneyExch / abs(moneyExch)];                       //////////////////transactions
        transaction.trType = [NSNumber numberWithInt:1];
        transaction.trMoneyCh = [NSNumber numberWithInt:moneyExch];
        
        [[GCHelper sharedInstance] reportScore:playerAccount.money forCategory:GC_LEADEBOARD_MONEY];

        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"dontShowFeedAtFirst"]) {
            [[StartViewController sharedInstance] setShowFeedAtFirst:YES];
        }
        DLog(@"You Win - User money %d Oponent money %d", playerAccount.money, oponentAccount.money);
        
        [playerAccount saveMoney];
        
        
        for (int i=0; i<[playerAccount.finalInfoTable count]; i++) {
            resoultDataSource = [playerAccount.finalInfoTable objectAtIndex:i];
            if(i==0){
                minUserTime=resoultDataSource.UserTime;
            }else{
                if (minUserTime>resoultDataSource.UserTime) {
                    minUserTime=resoultDataSource.UserTime;
                }
            }
        }

        [self increaseWinCount];
        
       pointsForMatch=[self getPointsForWin];
    }            
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Win.mp3", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [player play];
    [player setNumberOfLoops:0];
    
    int iPhone5Delta = [UIScreen mainScreen].bounds.size.height - 480;
    
    winnerImg1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fin_img_money.png"]];
    CGRect frame = winnerImg1.frame;
    frame.origin.y = 230  + iPhone5Delta;
    frame.origin.x = -150;
    winnerImg1.frame = frame;
    [viewLastSceneAnimation addSubview:winnerImg1];
    
    winnerImg2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fin_img_money2.png"]];
    frame = winnerImg2.frame;
    frame.origin.y = 340 + iPhone5Delta;
    frame.origin.x = 320;
    winnerImg2.frame = frame;
    [viewLastSceneAnimation addSubview:winnerImg2];

    frame = lblGoldPlus.frame;
    frame.origin.x -= 200;
    lblGoldPlus.frame = frame;
    [viewLastSceneAnimation addSubview:lblGoldPlus];

    UIFont *labelsFont = [UIFont fontWithName: @"MyriadPro-Semibold" size:13];
    [lblWinEarned setFont:labelsFont];
    [lblWinGold setFont:labelsFont];
    [lblWinGoldCount setFont:labelsFont];
    [lblWinPoints setFont:labelsFont];
    [lblWinPointsCount setFont:labelsFont];

    lblWinEarned.text=NSLocalizedString(@"YouEarned", @"");
    lblWinGold.text=NSLocalizedString(@"Gold", @"");
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:( playerAccount.money)]];   
    lblWinGoldCount.text=[NSString stringWithFormat:@"%@",formattedNumberString];
    
    lblWinPointsCount.text=[NSString stringWithFormat:@"%d",pointsForMatch];
    
    if ([lblWinPointsCount isEqual:@"1"]) {
        lblWinPoints.text=NSLocalizedString(@"Point", @"");
    } else {
        lblWinPoints.text=NSLocalizedString(@"Points", @"");
    }
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
    
    [statView setHidden:YES];
    [goldPointBgView setDinamicHeightBackground];
    viewLastSceneAnimation.hidden=NO;
    
    [nextButton setHidden:YES];
    [tryButton setHidden:NO];
    [backButton changeTitleByLabel:@"BACK"];
    
    [activityIndicatorView hideView];

    if (!teaching||(duelWithBotCheck)) {
        
        int local = [playerAccount.glNumber intValue];
        local++;
        DLog(@"number %d", local);
        playerAccount.glNumber = [NSNumber numberWithInt:local];
        //            transaction.trNumber = [NSNumber numberWithInt:local];
        transaction.trOpponentID = [NSString stringWithString:oponentAccount.accountID];
        [playerAccount.transactions addObject:transaction];
        
        CDTransaction *opponentTransaction = [CDTransaction new];
        [opponentTransaction setTrDescription:[NSString stringWithString:transaction.trDescription]];
        
        if ([transaction.trType intValue] == 1) [opponentTransaction setTrType:[NSNumber numberWithInt:-1]];
        else   [opponentTransaction setTrType:[NSNumber numberWithInt:1]];
        
        [opponentTransaction setTrMoneyCh:[NSNumber numberWithInt:-[transaction.trMoneyCh intValue]]];
        opponentTransaction.trOpponentID = [NSString stringWithString:playerAccount.accountID];
        [oponentAccount.transactions addObject:opponentTransaction];
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *locationData = [[NSMutableArray alloc] init];
        for( CDTransaction *loc in playerAccount.transactions)
        {
            [locationData addObject: [NSKeyedArchiver archivedDataWithRootObject:loc]];
        }
        [def setObject:locationData forKey:@"transactions"];
        
        DLog(@"Transactions count = %d", [playerAccount.transactions count]);
        [def synchronize];
        
        if (oponentAccount.accountID != nil) duel.dOpponentId = [NSString stringWithString:oponentAccount.accountID];  /////////////////////////////// save duels
        else duel.dOpponentId = @"Anonymous";
        duel.dRateFire = [NSNumber  numberWithInt: userTime];
        duel.dDate = [playerAccount dateFormat];
        duel.dGps = [NSNumber numberWithInt: -1];
        
        DLog(@"%@ %@ %@ %@", duel.dOpponentId, duel.dRateFire, duel.dDate, duel.dGps);
        
        [playerAccount.duels addObject:duel];
        
        
        NSMutableArray *locationDataDuel = [[NSMutableArray alloc] init];
        for( CDDuel *loc in playerAccount.duels)
        {
            [locationData addObject: [NSKeyedArchiver archivedDataWithRootObject:loc]];
        }
        [def setObject:locationDataDuel forKey:@"duels"];
        
        [playerAccount saveMoney];
        
        [def synchronize];
        
        [playerAccount sendTransactions:playerAccount.transactions];
        if (oponentAccount.bot) [oponentAccount sendTransactions:oponentAccount.transactions];
        if([playerAccount.duels count] > 10) 
            [playerAccount sendDuels:playerAccount.duels];
        
        if (reachNewLevel) {
            [self showMessageOfNewLevel];
            reachNewLevel=NO;
        }

        if (fMutchNumberLose != 2) {
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
        if(oponentAccount.bot) [[StartViewController sharedInstance] modifierUser:oponentAccount];
    }
    
    if (playerAccount.accountLevel == 10){
        NSString *name = [NSString stringWithFormat:@"fv_img_%drank.png", playerAccount.accountLevel];
        ivCurrentRank.image = [UIImage imageNamed:name];
    }
    else{
        NSString *name = [NSString stringWithFormat:@"fv_img_%drank.png", playerAccount.accountLevel];
        ivCurrentRank.image = [UIImage imageNamed:name];
        name = [NSString stringWithFormat:@"fv_img_%drank.png", playerAccount.accountLevel+1];
        ivNextRank.image = [UIImage imageNamed:name];
    }
    if (fMutchNumberLose == 2) {
        [self loseAnimation];
    }
    else {
        winnerImg1.hidden = NO;
        winnerImg2.hidden = NO;
        [self winAnimation];
    }
    [self.view bringSubviewToFront:activityIndicatorView];
    
//    if (duelWithBotCheck) {
//        int randomTime = (arc4random() % 1);
//        if (randomTime==0) {
//            [self performSelector:@selector(startBotDuelTryAgain) withObject:self afterDelay:5.0];
//        }
//    }
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	return 1; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [playerAccount.finalInfoTable count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    NSString *cellType = @"Default";
    
    ResoultDataSource *rDataSource = [[ResoultDataSource alloc] init];
    rDataSource = [playerAccount.finalInfoTable objectAtIndex:indexPath.row];
    
    UILabel *customText;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:style reuseIdentifier:cellType];
        [cell.textLabel setFont: [UIFont fontWithName: @"DecreeNarrow" size:21]];
        [cell.textLabel setTextColor:[[UIColor alloc] initWithRed:0.378 green:0.265 blue:0.184 alpha:1]];
        
        customText=[[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width-100, 8, 100,20)];
        [customText setBackgroundColor:[UIColor clearColor]];
        [customText setFont: [UIFont fontWithName: @"DecreeNarrow" size:21]];
        [customText setTextColor:[[UIColor alloc] initWithRed:0.378 green:0.265 blue:0.184 alpha:1]];
        [customText setTextAlignment:UITextAlignmentRight];
        [customText setTag:TAG_TEXT];
        [customText setNumberOfLines:1];
        [cell.contentView addSubview:customText];   

    }else {
        customText=(UILabel*)[cell viewWithTag:TAG_TEXT];
    }
    
    if (fMutchNumberLose == 2) {
        lblResulDescription.text=NSLocalizedString(@"lose", @"");
    }
    else if (fMutchNumberWin == 2){
        lblResulDescription.text=NSLocalizedString(@"win", @"");
    } else
    lblResulDescription.text=[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"Round", @""),[playerAccount.finalInfoTable count]];
    
    if (rDataSource.result) {
        
        if(!rDataSource.foll){
            cell.imageView.image = [UIImage imageNamed:@"fin_img_table_win_new.png"];
            cell.textLabel.text = [NSString stringWithFormat:@"%d.%d", abs(rDataSource.deltaTime / 1000), abs(rDataSource.deltaTime % 1000)];
            
            NSString *text=NSLocalizedString(@"win", @"");
            customText.text=[text uppercaseString];
        }else{
            if (!rDataSource.deadHeat) {
                cell.imageView.image = [UIImage imageNamed:@"fin_img_table_lose_new.png"];
                cell.textLabel.text = NSLocalizedString(@"False", @"");
                
                NSString *text=NSLocalizedString(@"You lost", @"");
                customText.text=[text uppercaseString];
            }
            else {
                cell.imageView.image = [UIImage imageNamed:@"fin_img_table_lose_new.png"];
                cell.textLabel.text = NSLocalizedString(@"Bouth false", @"");

            }
            

        }
    }
    if (!rDataSource.result) {
        if(!rDataSource.foll){
            cell.imageView.image = [UIImage imageNamed:@"fin_img_table_lose_new.png"];
            cell.textLabel.text = [NSString stringWithFormat:@"%d.%d", abs(rDataSource.deltaTime / 1000), abs(rDataSource.deltaTime % 1000)];
            
            NSString *text=NSLocalizedString(@"You lost", @"");
            customText.text=[text uppercaseString];
        }else{
            cell.imageView.image = [UIImage imageNamed:@"fin_img_table_win_new.png"];
            cell.textLabel.text = NSLocalizedString(@"Falses", @"");
            
            NSString *text=NSLocalizedString(@"win", @"");
            customText.text=[text uppercaseString];
        }
        
    }
    [cell.textLabel.text uppercaseString];
    
    NSInteger sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
	NSInteger row = [indexPath row];
    if (runAway && (row == (sectionRows-1))){
        if (runAwayGood) {
            cell.imageView.image = [UIImage imageNamed:@"fin_img_table_win_new.png"];
            cell.textLabel.text = NSLocalizedString(@"TB_RUN_AWAY_GOOD", @"");
          
            NSString *text=NSLocalizedString(@"win", @"");
            customText.text=[text uppercaseString];

        }else{
            cell.imageView.image = [UIImage imageNamed:@"fin_img_table_lose_new.png"];
            cell.textLabel.text = NSLocalizedString(@"TB_RUN_AWAY", @"");
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36; // your dynamic height...
}

#pragma mark -

-(void)winAnimation
{
    
    
  [lblGoldPlus setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
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
  int iPhone5Delta = [UIScreen mainScreen].bounds.size.height - 480;
  CGRect moveGoldToCoin = winnerImg2.frame;
  moveGoldToCoin.origin.x = ivGoldCoin.frame.origin.x + goldPointBgView.frame.origin.x - 50;
  moveGoldToCoin.origin.y = ivGoldCoin.frame.origin.y + goldPointBgView.frame.origin.y + iPhone5Delta;
  
  CGAffineTransform goldPlusZoomIn = CGAffineTransformScale(lblGoldPlus.transform, 1.5, 1.5);
  CGAffineTransform goldPlusZoomOut = CGAffineTransformScale(lblGoldPlus.transform, 1, 1);
  CGAffineTransform goldCoinZoomIn = CGAffineTransformScale(ivGoldCoin.transform, 2, 2);
  CGAffineTransform goldCoinZoomOut = CGAffineTransformScale(ivGoldCoin.transform, 1, 1);
  CGAffineTransform goldZoomIn = CGAffineTransformScale(winnerImg2.transform, 0.5, 0.5);
  
  NSArray *array=[DuelRewardLogicController getStaticPointsForEachLevels];
  
  if (playerAccount.accountLevel < 0 || playerAccount.accountLevel > 10 ){
    [playerAccount setAccountLevel:10];
  }
  
  NSInteger num = playerAccount.accountLevel;
    int  moneyForNextLevel=(playerAccount.accountLevel != 10)? [[array objectAtIndex:num] intValue]:playerAccount.accountPoints+1000;
  
  int moneyForPrewLevel;
  if (playerAccount.accountLevel==0) {
    moneyForPrewLevel = 0;
  }else
      if (playerAccount.accountLevel == 10) {
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
    fMutchNumberWin = 2;
}

-(void)prepeareForLoseScene{
    tryButtonEnabled = NO;
    fMutchNumberLose = 2;
}

-(void)loseAnimation
{
    int iPhone5Delta = [UIScreen mainScreen].bounds.size.height - 480;
    
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
  frame.origin.x = -200;
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
  if (playerAccount.accountLevel < 0 || playerAccount.accountLevel > 10 ){
    [playerAccount setAccountLevel:10];
  }
  NSInteger num = playerAccount.accountLevel;
  int  moneyForNextLevel=(playerAccount.accountLevel != 10)? [[array objectAtIndex:num] intValue]:playerAccount.accountPoints+1000;
  int moneyForPrewLevel;
  if (playerAccount.accountLevel==0) {
    moneyForPrewLevel = 0;
  }else
      if (playerAccount.accountLevel == 10) {
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
            
            playerAccount.accountLevel=playerNewLevel;
            [playerAccount saveAccountLevel];
            
            reachNewLevel=YES;
          // added for GC
            if (![GCHelper sharedInstance].GClocalPlayer.isAuthenticated) {
              [[GCHelper sharedInstance] authenticateLocalUser];
            }
          // above
            [[GCHelper sharedInstance] reportAchievementIdentifier:[[GCHelper sharedInstance].GC_ACH objectAtIndex:playerAccount.accountLevel] percentComplete:100.0f];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark -

-(void)showMessageOfNewLevel
{
    lvlCongratulationViewController=[[LevelCongratViewController alloc] initForNewLevelPlayerAccount:playerAccount andController:self tryButtonEnable:tryButton.enabled];
    [self performSelector:@selector(showViewController:) withObject:lvlCongratulationViewController afterDelay:4.5];
}

-(void)showMessageOfMoreMoney:(NSInteger)money withLabel:(NSString *)labelForCongratulation
{
    moneyCongratulationViewController  = [[MoneyCongratViewController alloc] initForAchivmentPlayerAccount:playerAccount withLabel:labelForCongratulation andController:self tryButtonEnable:tryButton.enabled];
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
    [playerAccount accountWins];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -

-(void)startBotDuelTryAgain
{
    DLog(@"Eshe Raz");
    [playerAccount.finalInfoTable removeAllObjects];
    DuelStartViewController  *tempVC=(DuelStartViewController*)[self.navigationController.viewControllers objectAtIndex:2] ;
    [tempVC setMessageTry];
    [tempVC setUserMoney:playerAccount.money];
    [tempVC setOponentMoney:oponentAccount.money];
    [self.navigationController popToViewController:tempVC animated:YES];
}


- (void)viewDidUnload {
    statView = nil;
    lblWinEarned = nil;
    lblWinGold = nil;
    lblWinGoldCount = nil;
    lblWinPoints = nil;
    lblWinPointsCount = nil;
    viewLose = nil;
    lblLoseEarned = nil;
    lblLoseGold = nil;
    lblLoseGoldCount = nil;
    lblLosePoints = nil;
    lblLosePointsCount = nil;
    lblLoseLost = nil;
    lbBack = nil;
    lbTryAgain = nil;
    lbNextRound = nil;
    lblGold = nil;
    gameStatusLable = nil;
    lblPoints = nil;
    lblGoldTitle = nil;
    lblPointsTitle = nil;
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
  if (endNumber - startNumber < 200) {
    goldForGoldAnimation = 1;
  }else {
    goldForGoldAnimation = (endNumber - startNumber)/200;
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
  int firstWidthOfLine=130;
  float changeWidth=(points*firstWidthOfLine)/maxValue;
  
  temp.size.width = changeWidth;
  
  if (animated) {
      [UIView animateWithDuration:1.4 animations:^{
        ivBlueLine.frame = temp;
      }];
  }else {
    ivBlueLine.frame = temp;
  }
}

-(void)showViewController:(UIViewController *)viewController
{
    [self presentModalViewController:viewController animated:YES];
}

@end
