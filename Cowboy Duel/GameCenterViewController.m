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

#define SENDER_TAG 1
#define RESEIVER_TAG 2
#define kMaxTankPacketSize 512

@implementation GameCenterViewController
@synthesize delegate, delegate2, duelStartViewController, multiplayerClientViewController, multiplayerServerViewController, parentVC, opponentEndMatch, userEndMatch,typeGameWithMessage, multiplayerViewController;

static GameCenterViewController *gameCenterViewController;

+(id)sharedInstance:(AccountDataSource *)userAccount andParentVC:(id)view
{
    if (gameCenterViewController) return gameCenterViewController;
    else {
        gameCenterViewController = [[GameCenterViewController alloc] initWithAccount:userAccount andParentVC:view];
        return gameCenterViewController;
    }
    
    
}

-(id)initWithAccount:(AccountDataSource *)userAccount andParentVC:(id)view {
   
    parentVC = view;    
    playerAccount = userAccount;    
    oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer];
    
    runAway=NO;
    
    carShotTime = 0.0;
    opShotTime = 0.0;
    accelState = NO;
    
    mutchNumber = 0;
    mutchNumberWin = 0;
    mutchNumberLose = 0;
    
    return self;
} 



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated]; 
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    accelState = NO;
    carShotTime = 0;
    opShotTime = 0;
    endDuel = NO;
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark MultiplayerViewControllerDelegate 
-(void)clientConnected
{
     NSLog(@"client connected");
    //[NSThread detachNewThreadSelector:@selector(matchStarted) toTarget:self withObject:nil];
//    [self matchStarted];
    [self performSelectorOnMainThread:@selector(matchStarted) withObject:nil waitUntilDone:YES];

    [self matchStartedSinxron];
}

- (void)matchStarted {  
    NSLog(@"matchStarted");

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
    [playerAccount.accountName getCString:gsSend->accountName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
    gsSend->oponentMoney = playerAccount.money;
    gsSend->accountLevel = playerAccount.accountLevel;
    gsSend->oponentWins = playerAccount.accountWins;
    
    [multiplayerViewController sendDataData:gsSend packetID:NETWORK_TIME ofLength:sizeof(gameInfo)];
}


-(void)startDuel
{
    isTryAgain = NO;
    if(!server){
        NSLog(@"server");
        
        gameInfo *gsSend = &gameStat;
        
        [multiplayerViewController sendDataData:gsSend packetID:NETWORK_START_DUEL ofLength:sizeof(gameInfo)];
        
    }else{
        if (!btnStartClick) {
            btnStartClick = YES;
                                    
        }else{
            
            duelViewController = [[DuelViewController alloc] initWithTime:(5 + randomTime) Account:playerAccount oponentAccount:oponentAccount];
            [duelViewController setDelegate:self];
            [self setDelegate:duelViewController];
            
            gameInfo *gsSend = &gameStat;
            
            [multiplayerViewController sendDataData:gsSend packetID:NETWORK_START_DUEL_TRUE ofLength:sizeof(gameInfo)];
            
            [parentVC.navigationController pushViewController:duelViewController animated:NO];        }
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
            NSLog(@"nextDuelStart btnStartClick = No");
            
            
            gameInfo *gsSend = &gameStat;
            
            [multiplayerViewController sendDataData:gsSend packetID:NETWORK_START_DUEL ofLength:sizeof(gameInfo)];

            btnStartClick = YES;
        }else{
            NSLog(@"nextDuelStart btnStartClick = Yes");
            duelViewController = [[DuelViewController alloc] initWithTime:(5 + randomTime) Account:playerAccount oponentAccount:oponentAccount];
            [duelViewController setDelegate:self];
            [self setDelegate:duelViewController];
            
            gameInfo *gsSend = &gameStat;
            
            [multiplayerViewController sendDataData:gsSend packetID:NETWORK_START_DUEL_TRUE ofLength:sizeof(gameInfo)];
            
            [parentVC.navigationController pushViewController:duelViewController animated:NO];
        }
    //}
    
}
-(void)matchStartedTry
{    
    NSLog(@"matchStarted");
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
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/duel_GS(try_again)" forKey:@"event"]];
    
    
    [playerAccount.finalInfoTable removeAllObjects];
        
    gameInfo *gsSend = &gameStat;
    randomTime = arc4random() % 6;
    gsSend->randomTime = randomTime;
    [playerAccount.accountName getCString:gsSend->accountName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
    gsSend->oponentMoney = playerAccount.money;
    gsSend->accountLevel = playerAccount.accountLevel;
    gsSend->oponentWins = playerAccount.accountWins;
    
    [multiplayerViewController sendDataData:gsSend packetID:NETWORK_TIME_TRY ofLength:sizeof(gameInfo)];
    
    
    
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
    
    [multiplayerViewController sendDataData:gsSend packetID:NETWORK_START_DUEL_FALSE ofLength:sizeof(gameInfo)];
    
    [self lostConnection];
    multiplayerClientViewController.isRunClient = NO;
    //multiplayerServerViewController.isRunServer = NO;
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
    
    [multiplayerViewController sendDataData:gsSend packetID:NETWORK_RUN_AWAY ofLength:sizeof(gameInfo)];
    
}


- (void)matchEnded {    
    NSLog(@"Match ended"); 
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
        
        [multiplayerViewController sendDataData:gsSend packetID:NETWORK_START_DUEL_FALSE ofLength:sizeof(gameInfo)];
        
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
   NSLog(@"!sendShotTime %d %d", shotTime, opShotTime);
    
    if (endDuel) return;
    
    btnStartClick = NO;
    [multiplayerViewController sendDataData:gsSend packetID:NETWORK_SEND_SHOT_TIME ofLength:sizeof(gameInfo)];

    
    // case 1: 
    //fail me (when both failed || failed with opShotTime > 0)
    if( ((carShotTime < 0) && (opShotTime < 0) && (carShotTime < opShotTime)) || ( (carShotTime < 0)&&(opShotTime > 0)) )
    {  
        NSLog(@"sendShotTime final foll: %d %d", carShotTime, opShotTime);
        endDuel = YES;
        if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)]) 
            [delegate duelTimerEndFeedBack];
        
        finalViewController = [[FinalViewController alloc] initWithUserTime:999999 andOponentTime:0 andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        [parentVC.navigationController pushViewController:finalViewController animated:YES];
        [delegate shutDownTimer];
        return;
    } 
    // case 2: 
    //fail opponent (when both failed  || failed with carShotTime > 0)
    if ( ((carShotTime < 0) && (opShotTime < 0) && (carShotTime > opShotTime)) || ((carShotTime > 0)&&(opShotTime < 0)) )
    {
        NSLog(@"sendShotTime final oponent foll: %d %d", carShotTime, opShotTime);
        endDuel = YES;
        if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)]) 
            [delegate duelTimerEndFeedBack];
        
        finalViewController = [[FinalViewController alloc] initWithUserTime:0 andOponentTime:999999 andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        [parentVC.navigationController pushViewController:finalViewController animated:YES];
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
        
        finalViewController = [[FinalViewController alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        [parentVC.navigationController pushViewController:finalViewController animated:YES];
        [delegate shutDownTimer];
        return;
        
    } 
}




-(void)duelTimerEnd
{
    NSLog(@"Duel timer end %d %d", carShotTime, opShotTime);
    
    if ((carShotTime == 0)&&(opShotTime == 0)) {
        NSLog(@"Duel timer end %d %d true", carShotTime, opShotTime);
        
        finalViewController = [[FinalViewController alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        [parentVC.navigationController pushViewController:finalViewController animated:YES];
        [delegate shutDownTimer];
    }
    else {
        NSLog(@"Duel timer end %d %d false", carShotTime, opShotTime);
        
        
        finalViewController = [[FinalViewController alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        [parentVC.navigationController pushViewController:finalViewController animated:YES];
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

-(void)startServerWithName:(NSString *)serverName
{
    NSLog(@"startServerWithName");
    multiplayerServerViewController = [[MultiplayerServerViewController alloc] initWithServerName:serverName];
    multiplayerServerViewController.gameCenterViewController = self;
    multiplayerViewController = multiplayerServerViewController;
    
    //[multiplayerClientViewController shutDownClient];
    //[multiplayerClientViewController release];
    
}

-(void)stopServer
{
    [multiplayerServerViewController shutDownServer];
    //[multiplayerServerViewController release]; 
}



-(void)startClientWithName:(char *)serverName{

    typeGameWithMessage = NO;

    multiplayerClientViewController = [[MultiplayerClientViewController alloc] initWithServerName:serverName];
    multiplayerClientViewController.gameCenterViewController = self; 
    multiplayerViewController = multiplayerClientViewController;
    
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
        multiplayerServerViewController.neadRestart = YES;
        multiplayerServerViewController.isRunServer = NO;
    }
}

#pragma mark - 


-(void)matchCanseled
{
    NSLog(@"GameCenterViewController: matchCanseled");
    userEndMatch = YES;
        
    gameInfo *gsSend = &gameStat;
        
    [multiplayerViewController sendDataData:gsSend packetID:NETWORK_DUEL_CANSEL ofLength:sizeof(gameInfo)];
    
    if (opponentEndMatch) {
        //[self duelCancel];
        [self lostConnection];
        [AdvertisingAppearController advertisingCountIncrease];
    }
    
    //        appear advertising
    
}

-(void)lostConnection
{
    opponentEndMatch = NO;
    userEndMatch = YES;
    NSLog(@"GameCenterViewController: lost connection");
    multiplayerServerViewController.neadRestart = YES;
    multiplayerClientViewController.isRunClient = NO;
    multiplayerServerViewController.pingStart = NO;
    [multiplayerServerViewController shutDownServer];
    
    UIViewController  *tempVC = [self.parentVC.navigationController.viewControllers objectAtIndex:1] ;
    [self.parentVC.navigationController popToViewController:tempVC animated:YES];

}


#pragma mark DuelViewControllerDelegate Methods

-(void)setAccelStateTrue
{
    accelState = YES;
    NSLog(@"Send position");
    gameInfo *gs = &gameStat;
    [multiplayerViewController sendDataData:gs packetID:NETWORK_ACCEL_STATE ofLength:sizeof(gameInfo)];
    
}

- (void)receiveData:(NSData *)data
{
    NSLog(@"receiveData");
    unsigned char *incomingPacket = (unsigned char *)[data bytes];    
	int *pIntData = (int *)&incomingPacket[0];
    
	int packetID = pIntData[0];

    switch( packetID ) {
            
		case NETWORK_TIME:                               
        {
            NSLog(@"NETWORK_TIME");
            [multiplayerViewController sendResponse];
            
            gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
            oponentAccount.money = gsReceive->oponentMoney;
            oponentAccount.accountLevel = gsReceive->accountLevel;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gsReceive->accountName encoding:NSUTF8StringEncoding];
            randomTime = gsReceive->randomTime;
            oponentAccount.accountWins = gsReceive->oponentWins;
            if(!oponentAccount.accountName || [oponentAccount.accountName isEqualToString:@""]) {
                [self lostConnection];
                return;
            }
            [self performSelectorOnMainThread:@selector(matchStarted) withObject:nil waitUntilDone:YES];
            endDuel = NO;
            server = NO;
            

            //for test
            if (!duelStartViewController) {
                duelStartViewController = [[DuelStartViewController alloc]initWithAccount:playerAccount andOpAccount:oponentAccount  opopnentAvailable:YES andServerType:YES andTryAgain:NO];
                
                [self setDelegate2:duelStartViewController];
                duelStartViewController.delegate = self;
                [parentVC.navigationController pushViewController:duelStartViewController animated:YES];
            }
                        
            gameInfo *gsSend = &gameStat;
            [playerAccount.accountName getCString:gsSend->accountName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
            [playerAccount.accountID getCString:gsSend->oponentAuth maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
            gsSend->oponentMoney = playerAccount.money;
            gsSend->oponentLevel = playerAccount.accountLevel;
            gsSend->oponentWins = playerAccount.accountWins;
                        
            [multiplayerViewController sendDataData:gsSend packetID:NETWORK_OPONTYPE_RESPONSE ofLength:sizeof(gameInfo)];
                       
        }
			break;
        case NETWORK_TIME_TRY:                               
        {
            NSLog(@"NETWORK_TIME_TRY");
            [multiplayerViewController sendResponse];
            
            endDuel = NO;
            carShotTime = 0.0;
            opShotTime = 0.0;
            
            mutchNumber = 0;
            mutchNumberWin = 0;
            mutchNumberLose = 0;
            
            start = NO;   
            
            accelState = YES;
            btnStartClick= NO;
            server = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:@"/duel_GS(try_again)" forKey:@"event"]];
            //            [TestFlight passCheckpoint:@"/duel_GS_try_again"];
            
            
            if (isTryAgain && server) return;
            
            [playerAccount.finalInfoTable removeAllObjects];
            
            gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
            
            oponentAccount.money = gsReceive->oponentMoney;
            oponentAccount.accountLevel = gsReceive->accountLevel;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gsReceive->accountName encoding:NSUTF8StringEncoding];
            oponentAccount.accountWins = gsReceive->oponentWins;
            randomTime = gsReceive->randomTime;
            
            if (!duelStartViewController) duelStartViewController = [[DuelStartViewController alloc]initWithAccount:playerAccount andOpAccount:oponentAccount  opopnentAvailable:YES andServerType:YES andTryAgain:YES];
            
            [self setDelegate2:duelStartViewController];
            duelStartViewController.delegate = self;
            if ([duelStartViewController respondsToSelector:@selector(setOponent:Label1:Label1:)]){ 
                
                duelStartViewController.lbOpponentDuelsWinCount=[NSString stringWithFormat:@"%d",oponentAccount.accountWins];
                [duelStartViewController setOponentMoney:oponentAccount.money];
                [duelStartViewController._vWait setHidden:YES];
                duelStartViewController.tryAgain = YES;
                duelStartViewController.oponentAvailable  = YES;
                if ([parentVC.navigationController.viewControllers containsObject:duelStartViewController]) [parentVC.navigationController popToViewController:duelStartViewController animated:YES];
                else [parentVC.navigationController pushViewController:duelStartViewController animated:YES];
                //[parentVC.navigationController pushViewController:duelStartViewController animated:YES];
                [duelStartViewController setMessageTry];
            }  
            
            gameInfo *gsSend = &gameStat;
            [playerAccount.accountName getCString:gsSend->accountName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
            [playerAccount.accountID getCString:gsSend->oponentAuth maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
            gsSend->oponentMoney = playerAccount.money;
            gsSend->oponentLevel = playerAccount.accountLevel;
            gsSend->oponentWins = playerAccount.accountWins;
            
            [multiplayerViewController sendDataData:gsSend packetID:NETWORK_OPONTYPE_RESPONSE_TRY ofLength:sizeof(gameInfo)];
            
        }
			break;
		case NETWORK_START_DUEL:
        {
            NSLog(@"NETWORK_START_DUEL");
            [multiplayerViewController sendResponse];
            accelState = NO;
            carShotTime = 0;
            opShotTime = 0;
            
            if(!start){
                duelViewController = [[DuelViewController alloc] initWithTime:(5 + randomTime) Account:playerAccount oponentAccount:oponentAccount];
                [duelViewController setDelegate:self];
                [self setDelegate:duelViewController];
                if (btnStartClick) {
                    NSLog(@"NETWORK_START_DUEL btnStartClick Yes");
                    
                    gameInfo *gsSend = &gameStat;
                    [multiplayerViewController sendDataData:gsSend packetID:NETWORK_START_DUEL_TRUE ofLength:sizeof(gameInfo)];
                    
                    [parentVC.navigationController pushViewController:duelViewController animated:YES];
                }else{
                    btnStartClick = YES;
                    NSLog(@"NETWORK_START_DUEL btnStartClick No");
                }
            }
        }
			break;
            
		case NETWORK_START_DUEL_TRUE:
        {
            NSLog(@"NETWORK_START_DUEL_TRUE");
            [multiplayerViewController sendResponse];
                        
            //gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
            accelState = YES;
            if ([[parentVC.navigationController visibleViewController] isKindOfClass:[DuelViewController class]]) return;
            
            duelViewController = [[DuelViewController alloc] initWithTime:(5 + randomTime) Account:playerAccount oponentAccount:oponentAccount];
            [duelViewController setDelegate:self];
            [self setDelegate:duelViewController];
            
            [parentVC.navigationController pushViewController:duelViewController animated:YES];
        }
			break;
            
        case  NETWORK_START_DUEL_FALSE:
        {   
            [multiplayerViewController sendResponse];
            NSLog(@"NETWORK_START_DUEL_FALSE");
            if ([baseAlert isVisible]) [baseAlert dismissWithClickedButtonIndex:3 animated:YES];
            if ([delegate2 respondsToSelector:@selector(cancelDuel)]) 
                [delegate2 cancelDuel];
            [self lostConnection];
        }
			break;
            
        case  NETWORK_ACCEL_STATE:
        {
            NSLog(@"NETWORK_ACCEL_STATE ");
            [multiplayerViewController sendResponse];
            if ([delegate respondsToSelector:@selector(accelerometerSendPositionSecond)]) 
                if([delegate accelerometerSendPositionSecond] && accelState) {
                    gameInfo *gsSend = &gameStat;
                    
                    [multiplayerViewController sendDataData:gsSend packetID:NETWORK_ACCEL_STATE_TRUE ofLength:sizeof(gameInfo)];
                    
                    if ([delegate respondsToSelector:@selector(startDuel)]) 
                        [delegate startDuel];
                    accelState = NO;
                };
        }
			break;     
            
        case  NETWORK_ACCEL_STATE_TRUE:
        {
            [multiplayerViewController sendResponse];
            NSLog(@"NETWORK_ACCEL_STATE_TRUE ");
            
            if(accelState){
                if ([delegate respondsToSelector:@selector(startDuel)]) 
                    [delegate startDuel];
                accelState = NO;
            }
        }
			break; 
        case  NETWORK_SEND_SHOT_TIME:
        {
            [multiplayerViewController sendResponse];
            if (!endDuel) {
                gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
                opShotTime = gsReceive->oponentShotTime;
                NSLog(@"NETWORK_SEND_SHOT_TIME : %d, our : %d", opShotTime, carShotTime);

                
                // case 1:
                //no one failed
                if((carShotTime > 0)&&(opShotTime > 0))
                {
                    endDuel = YES;
                    if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
                        [delegate duelTimerEndFeedBack];
                    
                    finalViewController = [[FinalViewController alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
                    [parentVC.navigationController pushViewController:finalViewController animated:YES];
                    [delegate shutDownTimer];
                    return;
                }
                // case 2:
                //fail me (when both failed || just me)
                if( ((carShotTime < 0) && (opShotTime <= 0) && (carShotTime < opShotTime)) || ((carShotTime < 0) && (opShotTime > 0))){
                    NSLog(@"sendShotTime final foll: %d %d", carShotTime, opShotTime);
                    endDuel = YES;
                    if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
                        [delegate duelTimerEndFeedBack];
                    
                    finalViewController = [[FinalViewController alloc] initWithUserTime:999999 andOponentTime:0 andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
                    [parentVC.navigationController pushViewController:finalViewController animated:YES];
                    [delegate shutDownTimer];
                    return;
                }
                // case 3:
                //fail opponent (when both failed || just he)
                if (((carShotTime < 0) && (opShotTime < 0) && (carShotTime > opShotTime)) || ((carShotTime > 0) && (opShotTime < 0)) )
                {
                    NSLog(@"sendShotTime final oponent foll: %d %d", carShotTime, opShotTime);
                    endDuel = YES;
                    if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
                        [delegate duelTimerEndFeedBack];
                    
                    finalViewController = [[FinalViewController alloc] initWithUserTime:0 andOponentTime:999999 andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
                    [parentVC.navigationController pushViewController:finalViewController animated:YES];
                    [delegate shutDownTimer];
                }
                //case 4:
                //exclusive fail:
                if((carShotTime == 0)&&(opShotTime < 0))
                    {
                    endDuel = YES;
                   if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)])
                        [delegate duelTimerEndFeedBack];

                    finalViewController = [[FinalViewController alloc] initWithUserTime:0 andOponentTime:999999 andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
                    [parentVC.navigationController pushViewController:finalViewController animated:YES];
                    [delegate shutDownTimer];

                    gameInfo *gsSend = &gameStat;
                    gsSend->oponentShotTime = carShotTime;
                    [multiplayerViewController sendDataData:gsSend packetID:NETWORK_SEND_SHOT_TIME ofLength:sizeof(gameInfo)];
                }
                

                btnStartClick = NO;
            }
        }
			break;
            
            
        case  NETWORK_OPONTYPE_RESPONSE:
        {
            [multiplayerViewController sendResponse];
            NSLog(@"NETWORK_OPONTYPE_RESPONSE %@", delegate2);
            endDuel = NO;
            server = YES;
            gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
            
            oponentAccount.money = gsReceive->oponentMoney;
            oponentAccount.accountLevel = gsReceive->oponentLevel;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gsReceive->accountName encoding:NSUTF8StringEncoding];
            oponentAccount.accountWins = gsReceive->oponentWins;
            oponentAccount.accountID = [[NSString alloc] initWithCString:gsReceive->oponentAuth encoding:NSUTF8StringEncoding];

            [self setDelegate2:duelStartViewController];
            duelStartViewController.delegate = self;
            if ([duelStartViewController respondsToSelector:@selector(setOponent:Label1:Label1:)]){ 
                
                duelStartViewController.lbOpponentDuelsWinCount=[NSString stringWithFormat:@"%d",oponentAccount.accountWins];
                [duelStartViewController setOponentMoney:oponentAccount.money];
                [duelStartViewController startButtonClick];
                [duelStartViewController._vWait setHidden:YES];
                
//                NSString *stMessage=[[NSString alloc] initWithCString:gsReceive->messageToOponent encoding:NSUTF8StringEncoding];
//                if (![stMessage isEqualToString:@""]) {
//                    NSString *stMessageFull=[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"BotMText", nil),stMessage];
//                    [duelStartViewController setMessageToOponent:stMessageFull];
//                }
                
            }  

            
                        
//            if ([duelStartViewController respondsToSelector:@selector(setOponent:Label1:Label1:)]){ 
//                [duelStartViewController setOponent:oponentAccount.typeImage Label1:oponentAccount.accountName Label1:oponentAccount.money];
//                
//                NSString *stMessage=[message objectForKey:@"messageToOponent"];;
//                if (![stMessage isEqualToString:@""]) {
//                    NSString *stMessageFull=[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"BotMText", nil),stMessage];
//                    [duelStartViewController setMessageToOponent:stMessageFull];
//                }
//            }  
            
            
        }
            break;
        case  NETWORK_OPONTYPE_RESPONSE_TRY:
        {
            [multiplayerViewController sendResponse];
            NSLog(@"NETWORK_OPONTYPE_RESPONSE_TRY %@", delegate2);
            endDuel = NO;   
            server = YES;
            gameInfo *gsReceive = (gameInfo *)&incomingPacket[4];
            
            oponentAccount.money = gsReceive->oponentMoney;
            oponentAccount.accountLevel = gsReceive->oponentLevel;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gsReceive->accountName encoding:NSUTF8StringEncoding];
            oponentAccount.accountWins = gsReceive->oponentWins;
            oponentAccount.accountID = [[NSString alloc] initWithCString:gsReceive->oponentAuth encoding:NSUTF8StringEncoding];

            duelStartViewController.lbOpponentDuelsWinCount=[NSString stringWithFormat:@"%d",oponentAccount.accountWins];
            [duelStartViewController setOponentMoney:oponentAccount.money];
            
            duelStartViewController.tryAgain = YES;
            [self setDelegate2:duelStartViewController];
            duelStartViewController.oponentAvailable  = NO;
            duelStartViewController.delegate = self;
            if ([parentVC.navigationController.viewControllers containsObject:duelStartViewController]) [parentVC.navigationController popToViewController:duelStartViewController animated:YES];
            else [parentVC.navigationController pushViewController:duelStartViewController animated:YES];
            [duelStartViewController startButtonClick];
                
           // }
      
        }
            break;
            
        case  NETWORK_RUN_AWAY:
        {   
            [multiplayerViewController sendResponse];
            NSLog(@"NETWORK_RUN_AWAY");
            
            [finalViewController runAway];
        }
			break;
            
        case  NETWORK_DUEL_CANSEL:
        {   
            [multiplayerViewController sendResponse];
            NSLog(@"NETWORK_DUEL_CANSEL");
            if (userEndMatch) {
                [self lostConnection];
                [AdvertisingAppearController advertisingCountIncrease];
            }
            else opponentEndMatch = YES;
        }
			break;
            
            
		default:
			// error
			break;
            
    }

}


@end
