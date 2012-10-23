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
        follPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
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
            [follPlayer setVolume:0.2];
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
                [follPlayer setVolume:0.2];
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
            [follPlayer setVolume:0.2];
            // above               
            [delegate increaseMutchNumber];
            resoultDataSource.foll = YES;
            resoultDataSource.result = NO;
            DLog(@"Oponent fouled");
        }
        if ((userTime == 999999) && (oponentTime == 999999))
        {
            //falseLabel =  NSLocalizedString(@"Bouth false", @"");
            [follPlayer setVolume:0.2];
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
        
        [follPlayer play];
        
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
    frame.origin=CGPointMake(-80, 0);
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
    DLog(@"nextButtonClick");
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
    [lblPoints setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:25]];
    [lblGoldTitle setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];
    [lblPointsTitle setFont:[UIFont fontWithName: @"DecreeNarrow" size:15]];
    
    
    lblPoints.gradientStartColor = [UIColor colorWithRed:84.0/255.0 green:229.0/255.0 blue:255.0/255.0 alpha:1.0];
    lblPoints.gradientEndColor = [UIColor colorWithRed:0.0 green:155.0/255.0 blue:195.0/255.0 alpha:1.0];
    
    lblGold.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    lblGold.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@%@",stGA,@"final"] forKey:@"event"]];
//    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@%@",stGA,@"final"]];

    int oldMoney=playerAccount.money;
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
    [self animationWithLable:lblGold andStartNumber:oldMoney andEndNumber:[AccountDataSource sharedInstance].money];
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Lose.mp3", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [player play];
    [player setNumberOfLoops:0];
    
    loserImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fin_img_loser.png"]];
    CGRect frame = loserImg.frame;
    frame.origin.y = 60;
    frame.origin.x = 37;
    loserImg.frame = frame;
    [viewLastSceneAnimation addSubview:loserImg];
    
    loserSpiritImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fin_img_spirit.png"]];
    frame = loserSpiritImg.frame;
    frame.origin.y = 280;
    frame.origin.x = 17;
    loserSpiritImg.frame = frame;
    [viewLastSceneAnimation addSubview:loserSpiritImg];
    [loserSpiritImg setHidden:YES];
    
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
    
    [lblGold setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
    [lblPoints setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:25]];
    [lblGoldTitle setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];
    [lblPointsTitle setFont:[UIFont fontWithName: @"DecreeNarrow" size:15]];
    
    lblPoints.gradientStartColor = [UIColor colorWithRed:84.0/255.0 green:229.0/255.0 blue:255.0/255.0 alpha:1.0];
    lblPoints.gradientEndColor = [UIColor colorWithRed:0.0 green:155.0/255.0 blue:195.0/255.0 alpha:1.0];
    
    lblGold.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    lblGold.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
    [self animationWithLable:lblGold andStartNumber:[AccountDataSource sharedInstance].money andEndNumber:[AccountDataSource sharedInstance].money + moneyExch];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@%@",stGA,@"final"] forKey:@"event"]];
    if(!teaching||(duelWithBotCheck)){
// added for GC        
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
    
    winnerImg1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fin_img_money.png"]];
    CGRect frame = winnerImg1.frame;
    frame.origin.y = 210;
    frame.origin.x = -150;
    winnerImg1.frame = frame;
    [viewLastSceneAnimation addSubview:winnerImg1];
    
    winnerImg2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fin_img_money2.png"]];
    frame = winnerImg2.frame;
    frame.origin.y = 330;
    frame.origin.x = 320;
    winnerImg2.frame = frame;
    [viewLastSceneAnimation addSubview:winnerImg2];

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
    
    lblPoints.shadowColor = [UIColor whiteColor];
    lblPoints.shadowOffset=CGSizeMake(1.0, 1.0);
    lblPoints.innerShadowColor = [UIColor whiteColor];
    lblPoints.innerShadowOffset=CGSizeMake(1.0, 1.0);
    lblPoints.shadowBlur = 1.0;
    
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
        [playerAccount.transactions addObject:transaction];
        
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
        
        [[StartViewController sharedInstance] modifierUser];
    }
    
    if (fMutchNumberLose == 2) {
        [self loseAnimation];
    }
    else {
        winnerImg1.hidden = NO;
        winnerImg2.hidden = NO;
        [self winAnimation];
    }
    [self.view bringSubviewToFront:activityIndicatorView ];
    
    if (duelWithBotCheck) {
        int randomTime = (arc4random() % 1);
        if (randomTime==0) {
            [self performSelector:@selector(startBotDuelTryAgain) withObject:self afterDelay:5.0];
        }
    }
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
    DLog(@"sectionRows %d row %d",sectionRows,row);
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
    //winnerImg2.alpha = 0.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES]; 
	[UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
    [UIView setAnimationDuration:1.2f];
	[UIView setAnimationDelegate:self];
    CGRect frame = winnerImg1.frame;
    frame.origin.x += 200;
    winnerImg1.frame = frame;
    frame = winnerImg2.frame;
    frame.origin.x -= 230;
    winnerImg2.frame = frame;
    [UIView commitAnimations];
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
    loserImg.hidden = NO;

    [UIView animateWithDuration:1.2 delay:0.0
        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect frame = loserImg.frame;
        frame.origin.y += 230;
        loserImg.frame = frame;
        
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
                                              [UIView animateWithDuration:1.0 delay:0.0
                                                options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction animations:^{
                                                  CGRect frame = loserSpiritImg.frame;
                                                  frame.origin.y -= 50;
                                                  frame.origin.x -= 40;
                                                  loserSpiritImg.frame = frame;
                                                  loserSpiritImg.transform = CGAffineTransformMakeScale(0.8, 0.8);
                                                  loserSpiritImg.alpha = 0.3;
                                                  
                                              }
                                                               completion:^(BOOL completion){
                                                                   [UIView animateWithDuration:2.0 delay:0.0
                                                                    options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction animations:^{
                                                                       CGRect frame = loserSpiritImg.frame;
                                                                       frame.origin.y -= 100;
                                                                       frame.origin.x += 80;
                                                                       loserSpiritImg.frame = frame;
                                                                       loserSpiritImg.transform = CGAffineTransformMakeScale(0.7, 0.7);
                                                                       loserSpiritImg.alpha = 0.0;
                                                                       
                                                                   }
                                                                                    completion:^(BOOL completion){
                                                                                        
                                                                                    }];
                                                               }];
                                          }];
                          }];
    
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
    [super viewDidUnload];
}

-(void)animationWithLable:(UILabel *)lable andStartNumber:(int)startNumber andEndNumber:(int)endNumber
{
    dispatch_async(dispatch_queue_create([lable.text cStringUsingEncoding:NSUTF8StringEncoding], NULL), ^{
        float goldForGoldAnimation;
        if (endNumber - startNumber < 200) {
            goldForGoldAnimation = 1;
        }else {
            goldForGoldAnimation = (endNumber - startNumber)/200;
        }
        for (int i = startNumber; i <= endNumber; i += goldForGoldAnimation) {
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


-(void)showViewController:(UIViewController *)viewController
{
    [self presentModalViewController:viewController animated:YES];
}

@end
