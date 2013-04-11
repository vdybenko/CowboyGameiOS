//
//  Class.m
//  Test
//
//  Created by Taras on 26.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameCenterViewController.h"
#import "GCHelper.h"
#import "AdvertisingAppearController.h"
#import "FinalViewController.h"
#import "DuelStartViewController.h"
#import "SSConnection.h"
#import "ActiveDuelViewController.h"
#import "FinalViewDataSource.h"


#define SENDER_TAG 1
#define RESEIVER_TAG 2
#define kMaxTankPacketSize 512

@interface GameCenterViewController ()
@property (nonatomic, strong) SSConnection *connection;
@end

@implementation GameCenterViewController
@synthesize delegate, delegate2, duelStartViewController, parentVC, opponentEndMatch, userEndMatch,userCanceledMatch, typeGameWithMessage, connection;

static GameCenterViewController *gameCenterViewController;

+(id)sharedInstance:(AccountDataSource *)userAccount andParentVC:(id)view
{
    if (gameCenterViewController)
        return gameCenterViewController;
    else {
        gameCenterViewController = [[GameCenterViewController alloc] initWithAccount:userAccount andParentVC:view];
        return gameCenterViewController;
    }
    
    
}

-(id)initWithAccount:(AccountDataSource *)userAccount andParentVC:(id)view {
    
    if (self = [super init]) {
        parentVC = view;
        playerAccount = userAccount;
        oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer];
        self.connection = [SSConnection sharedInstance];
        self.connection.gameCenterViewController = self;
        runAway=NO;
        
        carShotTime = 0.0;
        opShotTime = 0.0;
        accelState = NO;
        userCanceledMatch = NO;
        
        mutchNumber = 0;
        mutchNumberWin = 0;
        mutchNumberLose = 0;

    }
        
    return self;
}



#pragma mark MultiplayerViewControllerDelegate
-(void)clientConnected
{
    DLog(@"client connected");
    //[NSThread detachNewThreadSelector:@selector(matchStarted) toTarget:self withObject:nil];
    //    [self matchStarted];
    [self performSelectorOnMainThread:@selector(matchStarted) withObject:nil waitUntilDone:YES];
    
    [self matchStartedSinxron];
}

- (void)matchStarted {
    DLog(@"matchStarted");
    
    carShotTime = 0.0;
    opShotTime = 0.0;
    
    mutchNumber = 0;
    mutchNumberWin = 0;
    mutchNumberLose = 0;
    
    start = NO;
    runAway=NO;
    
    accelState = YES;
    btnStartClick= NO;
    
    endDuel = NO;
    userEndMatch = NO;
    opponentEndMatch = NO;
    
    [self setDelegate2:duelStartViewController];
    duelStartViewController.delegate = self;
    
    [playerAccount.finalInfoTable removeAllObjects];
}

- (void)matchStartedSinxron {
    gameInfo *gsSend = &gameStat;
    randomTime = arc4random() % 6;
    gsSend->randomTime = randomTime;
    [playerAccount.accountName getCString:gsSend->oponentName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
    [playerAccount.accountID getCString:gsSend->oponentAuth maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
    gsSend->oponentMoney = playerAccount.money;
    gsSend->oponentLevel = playerAccount.accountLevel;
    gsSend->oponentWins = playerAccount.accountWins;
    gsSend->oponentAtack = playerAccount.accountWeapon.dDamage;
    gsSend->oponentDefense = playerAccount.accountDefenseValue;
    gsSend->barrelsCount = playerAccount.accountSceneConfig.barrelsCount;
    gsSend->cactusCount = playerAccount.accountSceneConfig.cactusCount;
    gsSend->horseCount = playerAccount.accountSceneConfig.horseCount;
    gsSend->menCount = playerAccount.accountSceneConfig.menCount;
    gsSend->womenCount = playerAccount.accountSceneConfig.womenCount;
    
    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_TIME ofLength:sizeof(gameInfo)];
    
}

-(void)startDuel
{
    isTryAgain = NO;
    carShotTime = 0.0;
    opShotTime = 0.0;
    if(!server){
        DLog(@"server");
        
        gameInfo *gsSend = &gameStat;
        [self.connection sendData:(void *)(gsSend) packetID:NETWORK_START_DUEL ofLength:sizeof(gameInfo)];
        
    }else{
        if (!btnStartClick) {
            btnStartClick = YES;
            
        }else{
            
            activeDuelViewController = [[ActiveDuelViewController alloc] initWithAccount:playerAccount oponentAccount:oponentAccount];
            [activeDuelViewController setDelegate:self];
            [self setDelegate:activeDuelViewController];
            
            gameInfo *gsSend = &gameStat;
            [self.connection sendData:(void *)(gsSend) packetID:NETWORK_START_DUEL_TRUE ofLength:sizeof(gameInfo)];
            
            [parentVC.navigationController pushViewController:activeDuelViewController animated:NO];
        }
    }
}

-(void)nextDuelStart
{
    isTryAgain = NO;
    endDuel = NO;
    accelState = NO;
    carShotTime = 0;
    opShotTime = 0;
    
    if (!btnStartClick) {
        DLog(@"nextDuelStart btnStartClick = No");
        
        
        gameInfo *gsSend = &gameStat;
        [self.connection sendData:(void *)(gsSend) packetID:NETWORK_START_DUEL ofLength:sizeof(gameInfo)];
        
        btnStartClick = YES;
    }else{
        DLog(@"nextDuelStart btnStartClick = Yes");
        activeDuelViewController = [[ActiveDuelViewController alloc] initWithAccount:playerAccount oponentAccount:oponentAccount];
        [activeDuelViewController setDelegate:self];
        [self setDelegate:activeDuelViewController];
        
        gameInfo *gsSend = &gameStat;
        [self.connection sendData:(void *)(gsSend) packetID:NETWORK_START_DUEL_TRUE ofLength:sizeof(gameInfo)];
        
        [parentVC.navigationController pushViewController:activeDuelViewController animated:NO];
    }
    //}
    
}
-(void)matchStartedTry
{
    DLog(@"matchStarted");
    carShotTime = 0.0;
    opShotTime = 0.0;
    
    mutchNumber = 0;
    mutchNumberWin = 0;
    mutchNumberLose = 0;
    
    
    start = NO;
    runAway=NO;
    
    accelState = YES;
    btnStartClick= NO;
    
    endDuel = NO;
    userEndMatch = NO;
    opponentEndMatch = NO;
    
    isTryAgain = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/GameCenterVC_try_again" forKey:@"page"]];
    
    
    [playerAccount.finalInfoTable removeAllObjects];
    
    gameInfo *gsSend = &gameStat;
    randomTime = arc4random() % 6;
    gsSend->randomTime = randomTime;
    [playerAccount.accountName getCString:gsSend->oponentName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
    gsSend->oponentMoney = playerAccount.money;
    gsSend->oponentLevel = playerAccount.accountLevel;
    gsSend->oponentWins = playerAccount.accountWins;
    gsSend->oponentAtack = playerAccount.accountWeapon.dDamage;
    gsSend->oponentDefense = playerAccount.accountDefenseValue;
    gsSend->barrelsCount = playerAccount.accountSceneConfig.barrelsCount;
    gsSend->cactusCount = playerAccount.accountSceneConfig.cactusCount;
    gsSend->horseCount = playerAccount.accountSceneConfig.horseCount;
    gsSend->menCount = playerAccount.accountSceneConfig.menCount;
    gsSend->womenCount = playerAccount.accountSceneConfig.womenCount;
    
    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_TIME_TRY ofLength:sizeof(gameInfo)];
    runAway=YES;
}

-(void)duelCancel
{
    runAway=NO;
    carShotTime = 0.0;
    opShotTime = 0.0;
    accelState = NO;
    
    mutchNumber = 0;
    mutchNumberWin = 0;
    mutchNumberLose = 0;
    
    gameInfo *gsSend = &gameStat;
    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_START_DUEL_FALSE ofLength:sizeof(gameInfo)];
    
    [self lostConnection];
}

-(void)duelRunAway
{
    
    carShotTime = 0.0;
    opShotTime = 0.0;
    accelState = NO;
    
    mutchNumber = 0;
    mutchNumberWin = 0;
    mutchNumberLose = 0;
    
    runAway=YES;
    
    gameInfo *gsSend = &gameStat;
    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_RUN_AWAY ofLength:sizeof(gameInfo)];
    
}


- (void)matchEnded {
    DLog(@"Match ended");
    [parentVC.navigationController popToViewController:[parentVC.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)btnClickStart
{
    [self startDuel];
}

-(void)finishLaunching
{
    if ([[parentVC.navigationController visibleViewController] isKindOfClass:[DuelStartViewController class]]){
        gameInfo *gsSend = &gameStat;
        [self.connection sendData:(void *)(gsSend) packetID:NETWORK_START_DUEL_FALSE ofLength:sizeof(gameInfo)];
    }else{
        [[gameCenter match]disconnect];}
    
}

#pragma mark DuelViewControllerDelegate Methods

-(void)setAccelStateFalse
{
    accelState = NO;
}

-(void)sendShotTime:(int)shotTime
{
    if(shotTime==0) shotTime = -1;
    carShotTime = shotTime;
    gameInfo *gsSend = &gameStat;
    gsSend->oponentShotTime = shotTime;
    
    // we send time of shoot
    DLog(@"!sendShotTime %d %d", shotTime, opShotTime);
    
    if (endDuel) return;
    
    btnStartClick = NO;
    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_SEND_SHOT_TIME ofLength:sizeof(gameInfo)];
    
    
    if( (carShotTime != 0) && (opShotTime == carShotTime))
    {
        DLog(@"sendShotTime final foll: %d %d", carShotTime, opShotTime);
        endDuel = YES;
        if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
            [delegate duelTimerEndFeedBack];
        
        finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:999999 andOponentTime:999999 andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        if ([delegate respondsToSelector:@selector(showFinalView:)]) {
            [delegate performSelector:@selector(showFinalView:) withObject:finalViewDataSource];
        }
        [delegate shutDownTimer];
        return;
    }
    
    // case 1:
    //fail me (when both failed || failed with opShotTime > 0)
    if( ((carShotTime < 0) && (opShotTime < 0) && (carShotTime < opShotTime)) || ( (carShotTime < 0)&&(opShotTime > 0)) )
    {
        DLog(@"sendShotTime final foll: %d %d", carShotTime, opShotTime);
        endDuel = YES;
        if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
            [delegate duelTimerEndFeedBack];
        
        finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:999999 andOponentTime:0 andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        if ([delegate respondsToSelector:@selector(showFinalView:)]) {
            [delegate performSelector:@selector(showFinalView:) withObject:finalViewDataSource];
        }
        [delegate shutDownTimer];
        return;
    }
    // case 2:
    //fail opponent (when both failed  || failed with carShotTime > 0)
    if ( ((carShotTime < 0) && (opShotTime < 0) && (carShotTime > opShotTime)) || ((carShotTime > 0)&&(opShotTime < 0)) )
    {
        DLog(@"sendShotTime final oponent foll: %d %d", carShotTime, opShotTime);
        endDuel = YES;
        if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
            [delegate duelTimerEndFeedBack];
        
        finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:0 andOponentTime:999999 andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        if ([delegate respondsToSelector:@selector(showFinalView:)]) {
            [delegate performSelector:@selector(showFinalView:) withObject:finalViewDataSource];
        }
        [delegate shutDownTimer];
        return;
    }
    // case 3:
    //no one failed
    if((carShotTime > 0)&&(opShotTime > 0))
    {
        endDuel = YES;
        
        if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
            [delegate duelTimerEndFeedBack];
        
        finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        if ([delegate respondsToSelector:@selector(showFinalView:)]) {
            [delegate performSelector:@selector(showFinalView:) withObject:finalViewDataSource];
        }
        [delegate shutDownTimer];
        return;
        
    }
}




-(void)duelTimerEnd
{
    DLog(@"Duel timer end %d %d", carShotTime, opShotTime);
    
    if ((carShotTime == 0)&&(opShotTime == 0)) {
        DLog(@"Duel timer end %d %d true", carShotTime, opShotTime);
        
        finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        if ([delegate respondsToSelector:@selector(showFinalView:)]) {
            [delegate performSelector:@selector(showFinalView:) withObject:finalViewDataSource];
        }
        [delegate shutDownTimer];
    }
    else {
        DLog(@"Duel timer end %d %d false", carShotTime, opShotTime);
        
        
        finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        if ([delegate respondsToSelector:@selector(showFinalView:)]) {
            [delegate performSelector:@selector(showFinalView:) withObject:finalViewDataSource];
        }
        [delegate shutDownTimer];
    }
    btnStartClick = NO;
}

-(void)increaseMutchNumberLose
{
    mutchNumberLose++;
}
-(void)increaseMutchNumber
{
    mutchNumber++;
}
-(void)increaseMutchNumberWin
{
    mutchNumberWin++;
}

-(int)fMutchNumberLose
{
    return mutchNumberLose;
}
-(int)fMutchNumber
{
    return mutchNumber;
}
-(int)fMutchNumberWin
{
    return mutchNumberWin;
}


-(void)startClientWithName:(char *)serverName{
    
    typeGameWithMessage = NO;
    
    //old multiplayerClientViewController = [[MultiplayerClientViewController alloc] initWithServerName:serverName];
    //old multiplayerClientViewController.gameCenterViewController = self;
    //old multiplayerViewController = multiplayerClientViewController;
    
}

-(void)startClientWithName:(char *)serverName AndMessage:(NSString*)pMes;
{
    _messageToOpponent=pMes;
    [self startClientWithName:serverName];
    typeGameWithMessage=YES;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        //old multiplayerServerViewController.neadRestart = YES;
        //old  multiplayerServerViewController.isRunServer = NO;
    }
}

#pragma mark

-(void)matchCanseled
{
    DLog(@"GameCenterViewController: matchCanseled");
    userEndMatch = YES;
    
    gameInfo *gsSend = &gameStat;
    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_DUEL_CANSEL ofLength:sizeof(gameInfo)];
    
    
    if (opponentEndMatch) {
        //[self duelCancel];
        [self lostConnection];
        [AdvertisingAppearController advertisingCountIncrease];
    }
    
    //        appear advertising
    
}

-(void)lostConnection
{
    DLog(@"GameCenterViewController: lost connection");
    opponentEndMatch = NO;
    userEndMatch = YES;
    
    [self.connection sendData:@"" packetID:NETWORK_DISCONNECT_PAIR ofLength:sizeof(@"")];
    
    if ([self.parentVC.navigationController.visibleViewController isKindOfClass:([ActiveDuelViewController class])]) {
        finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        if (userCanceledMatch) {
            [finalViewDataSource prepeareForLoseScene];
        }else{
            [finalViewDataSource prepeareForWinScene];
        }
        mutchNumber = 3;
        finalViewDataSource.tryButtonEnabled = NO;

        if ([delegate respondsToSelector:@selector(showFinalView:)]) {
            [delegate performSelector:@selector(showFinalView:) withObject:finalViewDataSource];
        }
        [delegate shutDownTimer];
    }else if ([self.parentVC.navigationController.visibleViewController isKindOfClass:([FinalViewController class])]){
        if (mutchNumber==3) {
            finalViewController =(FinalViewController*) self.parentVC.navigationController.visibleViewController;
            finalViewController.tryButton.enabled = NO;
        }else{
            finalViewController = [[FinalViewController alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andGameCenterController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
            [finalViewController prepeareForWinScene];
            mutchNumber = 3;
            [parentVC.navigationController pushViewController:finalViewController animated:YES];
            [delegate shutDownTimer];
        }
    }else if ([self.parentVC.navigationController.visibleViewController isKindOfClass:([DuelStartViewController class])]){
        UIViewController *tempVC = [self.parentVC.navigationController.viewControllers objectAtIndex:1] ;
        [self.parentVC.navigationController popToViewController:tempVC animated:YES];
    }
    
    userCanceledMatch = NO;
}

-(BOOL)isLostConectionSend;
{
    if ((!opponentEndMatch)&&(userEndMatch)) {
        return YES;
    }else{
        return NO;
    }
}

-(void)userCancelMatch;
{
    [self matchCanseled];
    userCanceledMatch = YES;
    [self lostConnection];
}

#pragma mark DuelViewControllerDelegate Methods

-(void)setAccelStateTrue
{
    accelState = YES;
    DLog(@"Send position");
    gameInfo *gs = &gameStat;
    [self.connection sendData:(void *)(gs) packetID:NETWORK_ACCEL_STATE ofLength:sizeof(gameInfo)];
}

- (void)receiveData:(NSData *)data
{
    unsigned char *incomingPacket = (unsigned char *)[data bytes];
	int *pIntData = (int *)&incomingPacket[0];
    
	int packetID = pIntData[0];
    
    switch( packetID ) {
            
        case NETWORK_TIME:
        {
            DLog(@"NETWORK_TIME");
            
            gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
            oponentAccount.money = gsReceive->oponentMoney;
            oponentAccount.accountLevel = gsReceive->oponentLevel;
            oponentAccount.accountWins = gsReceive->oponentWins;
            oponentAccount.accountWeapon.dDamage = gsReceive->oponentAtack;
            oponentAccount.accountDefenseValue = gsReceive->oponentDefense;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gsReceive->oponentName encoding:NSUTF8StringEncoding];
            oponentAccount.accountID = [[NSString alloc] initWithCString:gsReceive->oponentAuth encoding:NSUTF8StringEncoding];
            
            GameSceneConfig *gameSceneConfig = [[GameSceneConfig alloc] init];
            gameSceneConfig.barrelsCount = gsReceive->barrelsCount;
            gameSceneConfig.cactusCount = gsReceive->cactusCount;
            gameSceneConfig.horseCount = gsReceive->horseCount;
            gameSceneConfig.menCount = gsReceive->menCount;
            gameSceneConfig.womenCount = gsReceive->womenCount;
            
            [oponentAccount setAccountSceneConfig:gameSceneConfig];
            
            randomTime = gsReceive->randomTime;
            if(!oponentAccount.accountName || [oponentAccount.accountName isEqualToString:@""]) {
                [self lostConnection];
                return;
            }
            [self performSelectorOnMainThread:@selector(matchStarted) withObject:nil waitUntilDone:YES];
            endDuel = NO;
            server = NO;
            
            //for test
            if (!duelStartViewController) {
                duelStartViewController = [[DuelStartViewController alloc] initWithAccount:playerAccount andOpAccount:oponentAccount  opopnentAvailable:YES andServerType:YES andTryAgain:NO];
                
                [self setDelegate2:duelStartViewController];
                duelStartViewController.delegate = self;
                [parentVC.navigationController pushViewController:duelStartViewController animated:YES];
            }else{
                [duelStartViewController setAttackAndDefenseOfOponent:oponentAccount];
            }
            
            gameInfo *gsSend = &gameStat;
            [playerAccount.accountName getCString:gsSend->oponentName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
            [playerAccount.accountID getCString:gsSend->oponentAuth maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
            gsSend->oponentMoney = playerAccount.money;
            gsSend->oponentLevel = playerAccount.accountLevel;
            gsSend->oponentWins = playerAccount.accountWins;
            gsSend->oponentAtack = playerAccount.accountWeapon.dDamage;
            gsSend->oponentDefense = playerAccount.accountDefenseValue;
            gsSend->barrelsCount = playerAccount.accountSceneConfig.barrelsCount;
            gsSend->cactusCount = playerAccount.accountSceneConfig.cactusCount;
            gsSend->horseCount = playerAccount.accountSceneConfig.horseCount;
            gsSend->menCount = playerAccount.accountSceneConfig.menCount;
            gsSend->womenCount = playerAccount.accountSceneConfig.womenCount;
            
            [self.connection sendData:(void *)(gsSend) packetID:NETWORK_OPONTYPE_RESPONSE ofLength:sizeof(gameInfo)];
        }
			break;
        case NETWORK_TIME_TRY:
        {
            DLog(@"NETWORK_TIME_TRY");
            
            endDuel = NO;
            carShotTime = 0.0;
            opShotTime = 0.0;
            
            mutchNumber = 0;
            mutchNumberWin = 0;
            mutchNumberLose = 0;
            
            start = NO;
            server = NO;
            accelState = YES;
            btnStartClick= NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:@"/GameCenterVC_try_again" forKey:@"page"]];
                        
            if (isTryAgain && server) return;
            
            [playerAccount.finalInfoTable removeAllObjects];
            
            gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
            
            oponentAccount.money = gsReceive->oponentMoney;
            oponentAccount.accountLevel = gsReceive->oponentLevel;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gsReceive->oponentName encoding:NSUTF8StringEncoding];
            oponentAccount.accountWins = gsReceive->oponentWins;
            oponentAccount.accountWeapon.dDamage = gsReceive->oponentAtack;
            oponentAccount.accountDefenseValue = gsReceive->oponentDefense;
            randomTime = gsReceive->randomTime;
            
            GameSceneConfig *gameSceneConfig = [[GameSceneConfig alloc] init];
            gameSceneConfig.barrelsCount = gsReceive->barrelsCount;
            gameSceneConfig.cactusCount = gsReceive->cactusCount;
            gameSceneConfig.horseCount = gsReceive->horseCount;
            gameSceneConfig.menCount = gsReceive->menCount;
            gameSceneConfig.womenCount = gsReceive->womenCount;
            
            [oponentAccount setAccountSceneConfig:gameSceneConfig];

            
            if (!duelStartViewController){
                duelStartViewController = [[DuelStartViewController alloc]initWithAccount:playerAccount andOpAccount:oponentAccount  opopnentAvailable:YES andServerType:YES andTryAgain:YES];
            }else{
                [duelStartViewController setAttackAndDefenseOfOponent:oponentAccount];
            }
            
            [self setDelegate2:duelStartViewController];
            duelStartViewController.delegate = self;
            if ([duelStartViewController respondsToSelector:@selector(setOponent:Label1:Label1:)]){
                
                duelStartViewController.lbOpponentDuelsWinCount=[NSString stringWithFormat:@"%d",oponentAccount.accountWins];
                [duelStartViewController setOponentMoney:oponentAccount.money];
                [duelStartViewController._vWait setHidden:YES];
                duelStartViewController.tryAgain = YES;
                duelStartViewController.oponentAvailable  = YES;
                if ([parentVC.navigationController.viewControllers containsObject:duelStartViewController])
                    [parentVC.navigationController popToViewController:duelStartViewController animated:YES];
                else{
                    [parentVC.navigationController pushViewController:duelStartViewController animated:YES];
                }
                [duelStartViewController setMessageTry];
            }
            
            gameInfo *gsSend = &gameStat;
            [playerAccount.accountName getCString:gsSend->oponentName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
            [playerAccount.accountID getCString:gsSend->oponentAuth maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
            gsSend->oponentMoney = playerAccount.money;
            gsSend->oponentLevel = playerAccount.accountLevel;
            gsSend->oponentWins = playerAccount.accountWins;
            gsSend->oponentAtack = playerAccount.accountWeapon.dDamage;
            gsSend->oponentDefense = playerAccount.accountDefenseValue;
            gsSend->barrelsCount = playerAccount.accountSceneConfig.barrelsCount;
            gsSend->cactusCount = playerAccount.accountSceneConfig.cactusCount;
            gsSend->horseCount = playerAccount.accountSceneConfig.horseCount;
            gsSend->menCount = playerAccount.accountSceneConfig.menCount;
            gsSend->womenCount = playerAccount.accountSceneConfig.womenCount;
            [self.connection sendData:(void *)(gsSend) packetID:NETWORK_OPONTYPE_RESPONSE_TRY ofLength:sizeof(gameInfo)];
            
        }
			break;
		case NETWORK_START_DUEL:
        {
            DLog(@"NETWORK_START_DUEL");
            accelState = NO;
            carShotTime = 0;
            opShotTime = 0;
            
            BOOL isLostConnectionSend = [self isLostConectionSend];
            if((!start)&&(!isLostConnectionSend)){
                activeDuelViewController = [[ActiveDuelViewController alloc] initWithAccount:playerAccount oponentAccount:oponentAccount];
                [activeDuelViewController setDelegate:self];
                [self setDelegate:activeDuelViewController];
                if (btnStartClick) {
                    DLog(@"NETWORK_START_DUEL btnStartClick Yes");
                    
                    gameInfo *gsSend = &gameStat;
                    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_START_DUEL_TRUE ofLength:sizeof(gameInfo)];
                    
                    [parentVC.navigationController pushViewController:activeDuelViewController animated:YES];
                }else{
                    btnStartClick = YES;
                    DLog(@"NETWORK_START_DUEL btnStartClick No");
                }
                if ([delegate2 respondsToSelector:@selector(stopWaitTimer)]) {
                    [delegate2 performSelector:@selector(stopWaitTimer)];
                }
            }
        }
			break;
            
		case NETWORK_START_DUEL_TRUE:
        {
            DLog(@"NETWORK_START_DUEL_TRUE");
            
            //gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
            accelState = YES;
            if ([[parentVC.navigationController visibleViewController] isKindOfClass:[ActiveDuelViewController class]]) return;
            
            activeDuelViewController = [[ActiveDuelViewController alloc] initWithAccount:playerAccount oponentAccount:oponentAccount];
            [activeDuelViewController setDelegate:self];
            [self setDelegate:activeDuelViewController];
            
            [parentVC.navigationController pushViewController:activeDuelViewController animated:YES];
            
            if ([delegate2 respondsToSelector:@selector(stopWaitTimer)]) {
                [delegate2 performSelector:@selector(stopWaitTimer)];
            }
        }
			break;
            
        case  NETWORK_START_DUEL_FALSE:
        {
            DLog(@"NETWORK_START_DUEL_FALSE");
            if ([baseAlert isVisible]) [baseAlert dismissWithClickedButtonIndex:3 animated:YES];
            if ([delegate2 respondsToSelector:@selector(cancelDuel)])
                [delegate2 cancelDuel];
            [self lostConnection];
        }
			break;
            
        case  NETWORK_ACCEL_STATE:
        {
            DLog(@"NETWORK_ACCEL_STATE ");
            if ([delegate respondsToSelector:@selector(accelerometerSendPositionSecond)])
                if([delegate accelerometerSendPositionSecond]) {
                    gameInfo *gsSend = &gameStat;
                    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_ACCEL_STATE_TRUE ofLength:sizeof(gameInfo)];
                    
                    activeDuelViewController = (ActiveDuelViewController *)delegate;
                    if ([activeDuelViewController respondsToSelector:@selector(startDuel)])
                        [activeDuelViewController  performSelector:@selector(startDuel) withObject:nil afterDelay:0.5];
                };
        }
			break;
            
        case  NETWORK_ACCEL_STATE_TRUE:
        {
            DLog(@"NETWORK_ACCEL_STATE_TRUE ");
            activeDuelViewController = (ActiveDuelViewController *)delegate;
            if([delegate accelerometerSendPositionSecond]){
                if ([activeDuelViewController respondsToSelector:@selector(startDuel)])
                    [activeDuelViewController  performSelector:@selector(startDuel) withObject:nil afterDelay:0.5];
                //accelState = NO;
            }
        }
			break;
            
        case  NETWORK_FOLL_START:
        {
            DLog(@"NETWORK_FOLL_START ");
            if ([delegate respondsToSelector:@selector(oponnentFollStart)]) {
                [delegate oponnentFollStart];
            }
            
        }
			break;
            
        case  NETWORK_FOLL_END:
        {
            DLog(@"NETWORK_FOLL_END ");
            if ([delegate respondsToSelector:@selector(oponnentFollEnd)]) {
                [delegate oponnentFollEnd];
            }
            
        }
			break;
            
        case  NETWORK_SEND_SHOT_TIME:
        {
            if (!endDuel)
            {
                gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
                opShotTime = gsReceive->oponentShotTime;
                DLog(@"NETWORK_SEND_SHOT_TIME : %d, our : %d", opShotTime, carShotTime);
                activeDuelViewController = (ActiveDuelViewController *)delegate;
                [activeDuelViewController userLost];
                if( (carShotTime != 0) && (opShotTime == carShotTime))
                {
                    endDuel = YES;
                    if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
                        [delegate duelTimerEndFeedBack];
                    
                    finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:999999 andOponentTime:999999 andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
                    if ([delegate respondsToSelector:@selector(showFinalView:)]) {
                        [delegate performSelector:@selector(showFinalView:) withObject:finalViewDataSource];
                    }
                    [delegate shutDownTimer];
                    return;
                }
                // case 1:
                //no one failed
                if((carShotTime > 0)&&(opShotTime > 0))
                {
                    endDuel = YES;
                    if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
                        [delegate duelTimerEndFeedBack];
                    
                    finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:999999 andOponentTime:999999 andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
                    if ([delegate respondsToSelector:@selector(showFinalView:)]) {
                        [delegate performSelector:@selector(showFinalView:) withObject:finalViewDataSource];
                    }
                    [delegate shutDownTimer];
                    return;
                }
                // case 2:
                //fail me (when both failed || just me)
                if( ((carShotTime < 0) && (opShotTime <= 0) && (carShotTime < opShotTime)) || ((carShotTime < 0) && (opShotTime > 0))){
                    DLog(@"sendShotTime final foll: %d %d", carShotTime, opShotTime);
                    endDuel = YES;
                    if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
                        [delegate duelTimerEndFeedBack];
                    
                    finalViewDataSource =  [[FinalViewDataSource alloc] initWithUserTime:999999 andOponentTime:0 andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
                    if ([delegate respondsToSelector:@selector(showFinalView:)]) {
                        [delegate performSelector:@selector(showFinalView:) withObject:finalViewDataSource];
                    }
                    
                    [delegate shutDownTimer];
                    return;
                }
                // case 3:
                //fail opponent (when both failed || just he)
                if (((carShotTime < 0) && (opShotTime < 0) && (carShotTime > opShotTime)) || ((carShotTime > 0) && (opShotTime < 0)) )
                {
                    DLog(@"sendShotTime final oponent foll: %d %d", carShotTime, opShotTime);
                    endDuel = YES;
                    if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
                        [delegate duelTimerEndFeedBack];
                    
                    finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:0 andOponentTime:999999 andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
                    if ([delegate respondsToSelector:@selector(showFinalView:)]) {
                        [delegate performSelector:@selector(showFinalView:) withObject:finalViewDataSource];
                    }

                    [delegate shutDownTimer];
                }
                //case 4:
                //exclusive fail:
                if((carShotTime == 0)&&(opShotTime < 0))
                {
                    endDuel = YES;
                    if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
                        [delegate duelTimerEndFeedBack];
                    
                    finalViewDataSource = [[FinalViewDataSource alloc] initWithUserTime:0 andOponentTime:999999 andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
                    if ([delegate respondsToSelector:@selector(showFinalView:)]) {
                        [delegate performSelector:@selector(showFinalView:) withObject:finalViewDataSource];
                    }

                    [delegate shutDownTimer];
                    
                    gameInfo *gsSend = &gameStat;
                    gsSend->oponentShotTime = carShotTime;
                    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_SEND_SHOT_TIME ofLength:sizeof(gameInfo)];
                    
                }
                
                btnStartClick = NO;
            }
        }
			break;
            
            
        case  NETWORK_OPONTYPE_RESPONSE:
        {
            DLog(@"NETWORK_OPONTYPE_RESPONSE %@", delegate2);
            endDuel = NO;
            server = YES;
            gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
            
            oponentAccount.money = gsReceive->oponentMoney;
            oponentAccount.accountLevel = gsReceive->oponentLevel;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gsReceive->oponentName encoding:NSUTF8StringEncoding];
            oponentAccount.accountWins = gsReceive->oponentWins;
            oponentAccount.accountWeapon.dDamage = gsReceive->oponentAtack;
            oponentAccount.accountDefenseValue = gsReceive->oponentDefense;
            oponentAccount.accountID = [[NSString alloc] initWithCString:gsReceive->oponentAuth encoding:NSUTF8StringEncoding];
            
            GameSceneConfig *gameSceneConfig = [[GameSceneConfig alloc] init];
            gameSceneConfig.barrelsCount = gsReceive->barrelsCount;
            gameSceneConfig.cactusCount = gsReceive->cactusCount;
            gameSceneConfig.horseCount = gsReceive->horseCount;
            gameSceneConfig.menCount = gsReceive->menCount;
            gameSceneConfig.womenCount = gsReceive->womenCount;
            
            [oponentAccount setAccountSceneConfig:gameSceneConfig];

            
            [self setDelegate2:duelStartViewController];
            duelStartViewController.delegate = self;
            if ([duelStartViewController respondsToSelector:@selector(setOponent:Label1:Label1:)]){
                
                duelStartViewController.lbOpponentDuelsWinCount=[NSString stringWithFormat:@"%d",oponentAccount.accountWins];
                [duelStartViewController setOponentMoney:oponentAccount.money];
                [duelStartViewController startButtonClick];
                [duelStartViewController._vWait setHidden:YES];
                [duelStartViewController setAttackAndDefenseOfOponent:oponentAccount];
            }
            
        }
            break;
        case  NETWORK_OPONTYPE_RESPONSE_TRY:
        {
            DLog(@"NETWORK_OPONTYPE_RESPONSE_TRY %@", delegate2);
            endDuel = NO;
            server = YES;
            gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
            
            oponentAccount.money = gsReceive->oponentMoney;
            oponentAccount.accountLevel = gsReceive->oponentLevel;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gsReceive->oponentName encoding:NSUTF8StringEncoding];
            oponentAccount.accountWins = gsReceive->oponentWins;
            oponentAccount.accountWeapon.dDamage = gsReceive->oponentAtack;
            oponentAccount.accountDefenseValue = gsReceive->oponentDefense;
            oponentAccount.accountID = [[NSString alloc] initWithCString:gsReceive->oponentAuth encoding:NSUTF8StringEncoding];
            
            GameSceneConfig *gameSceneConfig = [[GameSceneConfig alloc] init];
            gameSceneConfig.barrelsCount = gsReceive->barrelsCount;
            gameSceneConfig.cactusCount = gsReceive->cactusCount;
            gameSceneConfig.horseCount = gsReceive->horseCount;
            gameSceneConfig.menCount = gsReceive->menCount;
            gameSceneConfig.womenCount = gsReceive->womenCount;
            
            [oponentAccount setAccountSceneConfig:gameSceneConfig];

            
            duelStartViewController.lbOpponentDuelsWinCount=[NSString stringWithFormat:@"%d",oponentAccount.accountWins];
            [duelStartViewController setOponentMoney:oponentAccount.money];
            [duelStartViewController setAttackAndDefenseOfOponent:oponentAccount];
            
            duelStartViewController.tryAgain = YES;
            [self setDelegate2:duelStartViewController];
            duelStartViewController.oponentAvailable  = NO;
            duelStartViewController.delegate = self;
            if ([parentVC.navigationController.viewControllers containsObject:duelStartViewController])
                [parentVC.navigationController popToViewController:duelStartViewController animated:YES];
            else
                [parentVC.navigationController pushViewController:duelStartViewController animated:YES];
            [duelStartViewController startButtonClick];
        }
            break;
            
        case  NETWORK_RUN_AWAY:
        {
            DLog(@"NETWORK_RUN_AWAY");
            
            [finalViewController runAway];
        }
			break;
            
        case  NETWORK_DUEL_CANSEL:
        {
            DLog(@"NETWORK_DUEL_CANSEL");
            if (userEndMatch) {
                [self lostConnection];
                [AdvertisingAppearController advertisingCountIncrease];
            }
            else opponentEndMatch = YES;
        }
			break;
            
        case  NETWORK_SHOT:
        {
            DLog(@"NETWORK_SHOT");
            gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
            [self.delegate opponentShotWithDamage:gsReceive->damageCount];
        }
			break;
            
        case  NETWORK_SHOT_SELF:
        {
            DLog(@"NETWORK_SHOT");
            [self.delegate shotToOponentWithDamage:NSNotFound];
        }
			break;
            
		default:
			// error
			break;
    }
}

-(void)sendShotWithDamage:(int)damage;
{
    gameInfo *gsSend = &gameStat;
    gsSend->damageCount = damage;
    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_SHOT ofLength:sizeof(gameInfo)];
}

-(void)sendShotSelf
{
    gameInfo *gsSend = &gameStat;
    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_SHOT_SELF ofLength:sizeof(gameInfo)];
}

-(void)follStart
{
    gameInfo *gsSend = &gameStat;
    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_FOLL_START ofLength:sizeof(gameInfo)];
}

-(void)follEnd
{
    gameInfo *gsSend = &gameStat;
    [self.connection sendData:(void *)(gsSend) packetID:NETWORK_FOLL_END ofLength:sizeof(gameInfo)];
}

-(void)loadViewController:(UIViewController *)viewController
{
    [parentVC.navigationController pushViewController:viewController animated:YES];
}

@end
