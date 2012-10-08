//
//  BluetoothViewController.m
//  Test
//
//  Created by Sobol on 11.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BluetoothViewController.h"
#import "FinalViewController.h"
#define kTexasSessionID @"gktexas"

#if 0
#define kGKSessionErrorDomain GKSessionErrorDomain
#else
#define kGKSessionErrorDomain @"com.apple.gamekit.GKSessionErrorDomain"
#endif
/*
typedef enum {
	NETWORK_TIME,
    NETWORK_TIME_TRY,                // no packet
	NETWORK_START_DUEL,				// send position
	NETWORK_START_DUEL_TRUE,				// send fire
	NETWORK_START_DUEL_FALSE,				// send of entire state at regular intervals
    NETWORK_ACCEL_STATE,
    NETWORK_ACCEL_STATE_TRUE,
    NETWORK_SEND_SHOT_TIME,
    NETWORK_FOLL_START,
    NETWORK_FOLL_END,
    NETWORK_OPONTYPE_RESPONSE,
    NETWORK_OPONTYPE_RESPONSE_TRY,
    NETWORK_RUN_AWAY,
    NETWORK_RESPONSE,
    NETWORK_PING,
    NETWORK_PING_RESPONSE,
    NETWORK_DUEL_CANSEL
    
} packetCodes;
 */
#define SENDER_TAG 1
#define RESEIVER_TAG 2
#define kMaxTankPacketSize 256


@implementation BluetoothViewController
@synthesize gameSession, delegate, peerList, tableViewController,delegate2,delegateTable;

-(id)initWithAccount:(AccountDataSource *)userAccount andView:(id)view andStart:(BOOL)startView
{
    peerList = [[NSMutableArray alloc] init];
    parentVC = view;
    
    startViewGlob = startView;
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(175, 120, 120, 50)];
    [button setTitle:@"Seach device" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setFrame:CGRectMake(10, 10, 50, 50)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    playerAccount = userAccount;
    oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer:userAccount.player];
    
    //playerAccount.accountName = playerAccount.player.alias;
    
    UILabel *userTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, 100, 40)];
    if (playerAccount.userType == ANONIM)  userTypeLabel.text = [NSString stringWithFormat:@"%@ %@", @"Anonim", playerAccount.player.alias];
    if (playerAccount.userType == SHERIF)  userTypeLabel.text = [NSString stringWithFormat:@"%@ %@", @"Sherif", playerAccount.player.alias];
    if (playerAccount.userType == ROBBER)  userTypeLabel.text = [NSString stringWithFormat:@"%@ %@", @"Robber", playerAccount.player.alias];
    
    [self.view addSubview:userTypeLabel];
    
    
    
    start = NO;
    endDuel = NO;
    
    self.gameSession = nil;  
    
    carShotTime = 0.0;
    opShotTime = 0.0;
    accelState = NO;
    
    mutchNumber = 0;
    mutchNumberWin = 0;
    mutchNumberLose = 0;
    
    //if (startView) [self setupSession];
    
    tableViewController = [[TableViewController alloc] initWithSession:gameSession withPeer:peerList];
    self.delegateTable = tableViewController;
    tableViewController.delegate = self;
    
    // [self.navigationController pushViewController:tableViewController animated:YES];
    //[self.view addSubview:tableViewController.view];
    
    randomTime = arc4random() % 6;
    if (mutchNumber > 0) {
        button.enabled = NO;
        if (server) {
            gameInfo *gs = &gameStat;
            gs->randTime = randomTime;
            [self sendNetworkPacket:gameSession packetID:NETWORK_START_DUEL withData:gs ofLength:sizeof(gameInfo) reliable:NO];
        }
    }
    else {
        button.enabled = YES;
        server = YES;
        
    }
    
    accelState = NO;
    carShotTime = 0;
    opShotTime = 0;
    
    return self;
}

- (void) setupSession
{
	// GKSession will default to using the device name as the display name
    
    NSLog(@"setupSession");
	gameSession = [[GKSession alloc] initWithSessionID:kTexasSessionID displayName:nil sessionMode:GKSessionModePeer];
	gameSession.delegate = self; 
	[gameSession setDataReceiveHandler:self withContext:nil]; 
	gameSession.available = YES;
    sessionState = ConnectionStateDisconnected;
    
    
}


-(void)reloadTable
{
    tableViewController = [[TableViewController alloc] initWithSession:gameSession withPeer:peerList];
    NSLog(@"count %d", [peerList count]);
    self.delegateTable = tableViewController;
    tableViewController.delegate = self;
    
    pickerController = [[GKPeerPickerController alloc] init];
    pickerController.delegate = self;
    pickerController.connectionTypesMask = GKPeerPickerConnectionTypeNearby; 
    [pickerController show];
    if ([gameSession isAvailable])  NSLog(@"gameSession.available");
    gameSession.delegate = self;
    gameSession.available = YES;
    
}

#pragma mark - GKPeerPickerControllerDelegate

// Provide the session information including id and mode
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker
           sessionForConnectionType:(GKPeerPickerConnectionType)type {
    NSLog(@"Conection.......");
    gameSession = [[GKSession alloc] initWithSessionID:kTexasSessionID displayName:nil sessionMode:GKSessionModePeer];
	gameSession.delegate = self; 
	[gameSession setDataReceiveHandler:self withContext:nil]; 
	gameSession.available = YES;
    sessionState = ConnectionStateDisconnected;
    return self.gameSession;  
}

// Upon a successful connection, set up the data handler
- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession: (GKSession *) session {
    [picker dismiss];
    picker.delegate = nil;
//    [picker autorelease];
    
    //self.gameSession = session;
    //[self.gameSession setDataReceiveHandler:self withContext:nil]; 
    [self connect:peerID];
}

- (void) peerPickerControllerDidCancel:
(GKPeerPickerController *)picker {
    //[picker dismiss];
    picker.delegate = nil; 
//    [picker autorelease];
    
    if (gamePeerId != NULL) [gameSession cancelConnectToPeer:gamePeerId];
    [gameSession disconnectFromAllPeers];
    sessionState = ConnectionStateDisconnected;
    gameSession.available = YES;
    gamePeerId = nil;
    
    [parentVC.navigationController popToViewController:[parentVC.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



-(void)backButtonClick
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSLog(@"backButtonClick");
}

-(void)startButtonClick
{
    NSLog(@"StartButton click");
    endDuel = NO;
    gameInfo *gs = &gameStat;
    
    gs->oponentMoney = playerAccount.money;
    gs->shotTime = playerAccount.accountLevel;
    [playerAccount.accountName getCString:gs->oponentName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
    [playerAccount.typeImage getCString:gs->oponentImage maxLength:IMG_LENGTH encoding:NSUTF8StringEncoding];
    
    [self sendNetworkPacket:gameSession packetID:NETWORK_START_DUEL withData:gs ofLength:sizeof(gameInfo) reliable:NO];
    
    
}

-(void)matchStartedTry
{    
    NSLog(@"matchStarted");
    endDuel = NO;
    carShotTime = 0.0;
    opShotTime = 0.0;
    
    mutchNumber = 0;
    mutchNumberWin = 0;
    mutchNumberLose = 0;
    
    if (gamePeerId != NULL)
    {
        randomTime = arc4random() % 6;
        start = NO;   
        //    runAway=NO;
        
        gameInfo *gs = &gameStat;
        gs->randTime = randomTime;
        
        accelState = YES;
        //    btnStartClick= NO;
        
        duelStartViewController = [[DuelStartViewController alloc]initWithAccount:playerAccount andOpAccount:oponentAccount opopnentAvailable:YES andServerType:NO andTryAgain:NO];
        [self setDelegate2:duelStartViewController];
        duelStartViewController.delegate = self;
        server=NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/duel_BT(try_again)" forKey:@"event"]];
        //    [TestFlight passCheckpoint:@"/duel_try_again"];
        
        
        [playerAccount.finalInfoTable removeAllObjects];
        
        
        //    gs->randTime = randomTime;
        gs = &gameStat;
        gs->oponentMoney = playerAccount.money;
        [playerAccount.accountName getCString:gs->oponentName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
        //                [@"Lenin" getCString:gs->oponentName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
        
        [playerAccount.typeImage getCString:gs->oponentImage maxLength:IMG_LENGTH encoding:NSUTF8StringEncoding];
        NSLog(@"time %d",randomTime);
        
        [self sendNetworkPacket:gameSession packetID:NETWORK_TIME_TRY withData:gs ofLength:sizeof(gameInfo) reliable:NO];
        server=YES;
        //    runAway=YES;
    }else{
        [parentVC.navigationController popToViewController:[parentVC.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
}


-(NSMutableArray *)peerList
{
    return peerList;  
}
- (void)dealloc { 
	
	
	// cleanup the session
    
	[self invalidateSession:self.gameSession];
	
	
}



// Called from GameLobbyController if the user accepts the invitation alertView
-(BOOL) didAcceptInvitation
{
    [parentVC.navigationController dismissModalViewControllerAnimated:YES];
    endDuel = NO;
    NSError *error = nil;
    NSLog(@"%@",gamePeerId);
    if (![gameSession acceptConnectionFromPeer:gamePeerId error:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }
    return YES;
    
}

// Called from GameLobbyController if the user declines the invitation alertView
-(void) didDeclineInvitation
{
    NSLog(@"Decline");
    endDuel = NO;
    [self duelCancel];
    // Deny the peer.
    if (sessionState != ConnectionStateDisconnected) {
        [gameSession denyConnectionFromPeer:gamePeerId];
        gamePeerId = nil;
        sessionState = ConnectionStateDisconnected;
    }
    // Go back to the lobby if the game screen is open.
    //    [gameDelegate willDisconnect:self];
}

#pragma mark -
#pragma mark Session Related Methods

//
// invalidate session
//
- (void)invalidateSession:(GKSession *)session {
	if(session != nil) {
		[session disconnectFromAllPeers]; 
		session.available = NO; 
		[session setDataReceiveHandler: nil withContext: NULL]; 
		session.delegate = nil; 
	}
}

-(void)btnClickStart
{
    [self startButtonClick];
}


-(void)duelCancel
{
    //    // invalidate and release game session if one is around.
    //    carShotTime = 0.0;
    //    opShotTime = 0.0;
    //    accelState = NO;
    //    
    //    mutchNumber = 0;
    //    mutchNumberWin = 0;
    //    mutchNumberLose = 0;
    //    NSLog(@"Duel cansel with peer %@", gamePeerId);
    //    
    //    runAway=NO;
    carShotTime = 0.0;
    opShotTime = 0.0;
    accelState = NO;
    
    mutchNumber = 0;
    mutchNumberWin = 0;
    mutchNumberLose = 0;
    
    gameInfo *gs = &gameStat;
    //    [gameCenter sendDataData:gs packetID:NETWORK_START_DUEL_FALSE ofLength:sizeof(gameInfo)];    
    if (gamePeerId != NULL) 
    {
        [self sendNetworkPacket:gameSession packetID:NETWORK_START_DUEL_FALSE withData:gs ofLength:sizeof(gameInfo) reliable:NO];
        [gameSession cancelConnectToPeer:gamePeerId];
        [gameSession disconnectFromAllPeers];
        sessionState = ConnectionStateDisconnected;
        gameSession.available = YES;
        gamePeerId = nil;
    }
    
    //        appear advertising
    [AdvertisingAppearController advertisingCountIncrease];
}

#pragma mark Data Send/Receive Methods

/*
 * Getting a data packet. This is the data receive handler method expected by the GKSession. 
 * We set ourselves as the receive data handler in the -peerPickerController:didConnectPeer:toSession: method.
 */
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context { 
    //	static int lastPacketTime = -1;
	unsigned char *incomingPacket = (unsigned char *)[data bytes];
    
	int *pIntData = (int *)&incomingPacket[0];
    
    NSString *str = [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"time", @""),randomTime];
	//
	// developer  check the network time and make sure packers are in order
	//
    
    [startButton setEnabled:YES];
    
    
    //	int packetTime = pIntData[0];
	int packetID = pIntData[1];
    
    NSLog(@"paket id %d",packetID);
    NSLog(@"gamePeerId %@", gamePeerId);
	
    switch( packetID ) {
		case NETWORK_TIME:
        {
            
            gameInfo *gs = (gameInfo *)&incomingPacket[8];
            randomTime = gs->randTime;
            NSLog(@"NETWORK_TIME %d",randomTime);
            
            oponentAccount.money = gs->oponentMoney;
            oponentAccount.accountLevel = gs->shotTime;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gs->oponentName encoding:NSUTF8StringEncoding];
            oponentAccount.typeImage = [[NSString alloc] initWithCString:gs->oponentImage encoding:NSUTF8StringEncoding];
            
            gameInfo *gs2 = &gameStat;
            
            gs2->oponentMoney = playerAccount.money;
            [playerAccount.accountName getCString:gs2->oponentName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
            
            [playerAccount.typeImage getCString:gs2->oponentImage maxLength:IMG_LENGTH encoding:NSUTF8StringEncoding];
            
            [self sendNetworkPacket:gameSession packetID:NETWORK_OPONTYPE_RESPONSE withData:gs2 ofLength:sizeof(gameInfo) reliable:NO];
            
            
            if (startViewGlob) {
                
                duelStartViewController = [[DuelStartViewController alloc]initWithAccount:playerAccount andOpAccount:oponentAccount opopnentAvailable:NO andServerType:NO andTryAgain:NO];
                
                NSLog(@"BT setOponent NETWORK_TIME");
                
                [self setDelegate2:duelStartViewController];
                [delegate2 setOponent:oponentAccount.typeImage Label1:oponentAccount.accountName Label1:oponentAccount.money];
                [   parentVC.navigationController pushViewController:duelStartViewController animated:YES];
            }
            
        }
			break;
        case NETWORK_TIME_TRY:                               
        {
            
            NSLog(@"matchStarted");
            endDuel = NO;
            carShotTime = 0.0;
            opShotTime = 0.0;
            
            mutchNumber = 0;
            mutchNumberWin = 0;
            mutchNumberLose = 0;
            
            randomTime = arc4random() % 6;
            start = NO;   
            
            gameInfo *gs = &gameStat;
            gs->randTime = randomTime;
            
            accelState = YES;
            //            btnStartClick= NO;
            
            duelStartViewController = [[DuelStartViewController alloc]initWithAccount:playerAccount andOpAccount:oponentAccount  opopnentAvailable:YES
                                                                        andServerType:NO andTryAgain:NO];
            [self setDelegate2:duelStartViewController];
            duelStartViewController.delegate = self;
            server=NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:@"/duel_BT(try_again)" forKey:@"event"]];
            //            [TestFlight passCheckpoint:@"/duel_try_again"];
            
            
            [playerAccount.finalInfoTable removeAllObjects];
            
            NSLog(@"NETWORK_TIME_TRY");
            gs = (gameInfo *)&incomingPacket[8];
            
            oponentAccount.money = gs->oponentMoney;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gs->oponentName encoding:NSUTF8StringEncoding];
            oponentAccount.typeImage = [[NSString alloc] initWithCString:gs->oponentImage encoding:NSUTF8StringEncoding];
            
            if ([delegate2 respondsToSelector:@selector(setOponent:Label1:Label1:)]){ 
                NSLog(@"delegate2");
                [delegate2 setOponent:oponentAccount.typeImage Label1:oponentAccount.accountName Label1:oponentAccount.money];
                [parentVC.navigationController pushViewController:duelStartViewController animated:YES];
                [duelStartViewController setMessageTry];
            }            
            
            gameInfo *gs2 = &gameStat;
            gs2->oponentMoney = playerAccount.money; 
            NSLog(@"accountName %@",playerAccount.accountName);
            [playerAccount.accountName getCString:gs2->oponentName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
            
            [playerAccount.typeImage getCString:gs2->oponentImage maxLength:IMG_LENGTH encoding:NSUTF8StringEncoding];
            
            [self sendNetworkPacket:gameSession packetID:NETWORK_OPONTYPE_RESPONSE_TRY withData:gs2 ofLength:sizeof(gameInfo) reliable:NO];
        }
			break;
            
		case NETWORK_START_DUEL:
        {
            NSLog(@"NETWORK_START_DUEL");
            endDuel = NO;
            accelState = NO;
            carShotTime = 0;
            opShotTime = 0;
            gameInfo *gs = (gameInfo *)&incomingPacket[8];
            randomTime = gs->randTime;
            oponentAccount.money = gs->oponentMoney;
            oponentAccount.accountLevel = gs->shotTime;

            NSString *textForMessage=[NSString stringWithFormat:@"%d",playerAccount.accountLevel];

            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"accountLevel" message:textForMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil, nil];
            [alert show];
            
            oponentAccount.accountName = [[NSString alloc] initWithCString:gs->oponentName encoding:NSUTF8StringEncoding];
            oponentAccount.typeImage = [[NSString alloc] initWithCString:gs->oponentImage encoding:NSUTF8StringEncoding];
            
            if(!start){
                NSLog(@"in if NETWORK_START_DUEL");
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Start duel" message:str delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                av.tag = RESEIVER_TAG;
                
                accelState = YES;
                gameInfo *gs = &gameStat;
                
                gs->oponentMoney = playerAccount.money;
                [playerAccount.accountName getCString:gs->oponentName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
                [playerAccount.typeImage getCString:gs->oponentImage maxLength:IMG_LENGTH encoding:NSUTF8StringEncoding];
                NSLog(@"in if NETWORK_START_DUEL2 %@",gameSession);
                [self sendNetworkPacket:gameSession packetID:NETWORK_START_DUEL_TRUE withData:gs ofLength:sizeof(gameInfo) reliable:NO];
                NSLog(@"in if NETWORK_START_DUEL3");
                duelViewController = [[DuelViewController alloc] initWithTime:(5 + randomTime) Account:playerAccount];
                [duelViewController setDelegate:self];
                [self setDelegate:duelViewController];
                
                [parentVC.navigationController pushViewController:duelViewController animated:NO];
                //[av show];
            }
        }
			break;
		case NETWORK_START_DUEL_TRUE:
        {
            gameInfo *gs = (gameInfo *)&incomingPacket[8];
            //            oponentAccount = gs->account;
            oponentAccount.money = gs->oponentMoney;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gs->oponentName encoding:NSUTF8StringEncoding];
            oponentAccount.typeImage = [[NSString alloc] initWithCString:gs->oponentImage encoding:NSUTF8StringEncoding];
            
            
            [startAv dismissWithClickedButtonIndex:0 animated:YES];
            
            NSLog(@"time %d",randomTime);
            duelViewController = [[DuelViewController alloc] initWithTime:(5 + randomTime) Account:playerAccount];
            [duelViewController setDelegate:self];
            [self setDelegate:duelViewController];
            
            accelState = YES;
            [parentVC.navigationController pushViewController:duelViewController animated:NO];
        }
			break;
		case  NETWORK_START_DUEL_FALSE:
        {
            [startAv dismissWithClickedButtonIndex:0 animated:YES];
            NSLog(@"NETWORK_START_DUEL_FALSE");
            if ([delegate2 respondsToSelector:@selector(cancelDuel)]) 
                [delegate2 cancelDuel];
            if (gamePeerId != NULL) [gameSession cancelConnectToPeer:gamePeerId];
            [gameSession disconnectFromAllPeers];
            sessionState = ConnectionStateDisconnected;
            gameSession.available = YES;
            gamePeerId = nil;
            
            
        }
			break;
        case  NETWORK_ACCEL_STATE:
        {
            if ([delegate respondsToSelector:@selector(accelerometerSendPositionSecond)]) 
                if([delegate accelerometerSendPositionSecond]) {
                    gameInfo *gs = &gameStat;
                    [self sendNetworkPacket:gameSession packetID:NETWORK_ACCEL_STATE_TRUE withData:gs ofLength:sizeof(gameInfo) reliable:NO];
                    if ([delegate respondsToSelector:@selector(startDuel)]) 
                        [delegate startDuel];
                    accelState = NO;
                };
        }
			break;    
            
        case  NETWORK_ACCEL_STATE_TRUE:
        {
            if(accelState){
                if ([delegate respondsToSelector:@selector(startDuel)]) 
                    [delegate startDuel];
                accelState = NO;
            }
        }
			break; 
            
        case  NETWORK_SEND_SHOT_TIME:
        {
            NSLog(@"NETWORK_SEND_SHOT_TIME");
            if (!endDuel) {
                NSLog(@"Oponent shot");
                
                gameInfo *gs = (gameInfo *)&incomingPacket[8];
                
                NSString *str = [[NSString alloc] initWithFormat:@"%@ %d.%d",NSLocalizedString(@"Oponent shot Time =", @""), gs->shotTime / 1000, gs->shotTime % 1000];
                NSLog(@"%@  %d",str,carShotTime);
                
                opShotTime = gs->shotTime;
                if((carShotTime !=0)&&(opShotTime!=0)&& (!endDuel)){
                    NSLog(@"init 1");
                    endDuel = YES;
                    if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)]) 
                        [delegate duelTimerEndFeedBack];
                    
                    
                    finalViewController = [[FinalViewController alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
                    [parentVC.navigationController pushViewController:finalViewController animated:YES];
                }
                
                if((opShotTime == 999999.0)&& (!endDuel)){
                    NSLog(@"init 2");
                    if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)]) 
                        [delegate duelTimerEndFeedBack];
                    
                    
                    finalViewController = [[FinalViewController alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
                    [parentVC.navigationController pushViewController:finalViewController animated:YES];
                    endDuel = YES;
                }
            }
            
            
        }
			break;
            
        case  NETWORK_FOLL_START:
        {
            
            
            if ([delegate respondsToSelector:@selector(partnerFoll)]) 
                [delegate partnerFoll];
            //accelState = YES;
        }
            break;
            
        case  NETWORK_FOLL_END:
        {
            NSLog(@"get Paket foll end");
            if ([delegate respondsToSelector:@selector(startDuel)]) 
                [delegate startDuel];
            //accelState = NO;
        }
            
			break;
        case  NETWORK_OPONTYPE_RESPONSE:
        {
            
            gameInfo *gs = (gameInfo *)&incomingPacket[8];
            //            oponentAccount = gs->account;
            oponentAccount.money = gs->oponentMoney;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gs->oponentName encoding:NSUTF8StringEncoding];
            oponentAccount.typeImage = [[NSString alloc] initWithCString:gs->oponentImage encoding:NSUTF8StringEncoding];
            
            NSLog(@"BT setOponent NETWORK_OPONTYPE_RESPONSE");
            
            if ([delegate2 respondsToSelector:  @selector(setOponent:Label1:Label1:)])
                [delegate2 setOponent:oponentAccount.typeImage Label1:oponentAccount.accountName Label1:oponentAccount.money];
        }
            break;
        case  NETWORK_OPONTYPE_RESPONSE_TRY:
        {
            NSLog(@"NETWORK_OPONTYPE_RESPONSE_TRY");
                        
            gameInfo *gs = (gameInfo *)&incomingPacket[8];
            //            oponentAccount = gs->account;
            oponentAccount.money = gs->oponentMoney;
            oponentAccount.accountName = [[NSString alloc] initWithCString:gs->oponentName encoding:NSUTF8StringEncoding];
            oponentAccount.typeImage = [[NSString alloc] initWithCString:gs->oponentImage encoding:NSUTF8StringEncoding];
            
            if ([delegate2 respondsToSelector:@selector(setOponent:Label1:Label1:)]){ 
                [delegate2 setOponent:oponentAccount.typeImage Label1:oponentAccount.accountName Label1:oponentAccount.money];
                [parentVC.navigationController pushViewController:duelStartViewController animated:YES];
            }
             
        }
            break;
            
        case  NETWORK_RUN_AWAY:
        {   
            NSLog(@"NETWORK_RUN_AWAY");
            [finalViewController runAway];
        }
			break;
            
        default:
			// error
			break;
	}
    
}

- (void)sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend {
	// the packet we'll send is resued
    // NSLog(@"send paket");
    
	static unsigned char networkPacket[kMaxTankPacketSize];
	const unsigned int packetHeaderSize = 2 * sizeof(int); // we have two "ints" for our header
	
	if(length < (kMaxTankPacketSize - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
		int *pIntData = (int *)&networkPacket[0];
		// header info
		pIntData[0] = 1;
		pIntData[1] = packetID;
		
        
        // copy data in after the header
		memcpy( &networkPacket[packetHeaderSize], data, length ); 
		
		NSData *packet = [NSData dataWithBytes: networkPacket length: (length+8)];
        NSLog(@"send paket1 %@", gamePeerId);
		if(howtosend == YES) { 
			[self.gameSession sendData:packet toPeers:[NSArray arrayWithObject:gamePeerId] withDataMode:GKSendDataReliable error:nil];
		} else {
			[self.gameSession sendData:packet toPeers:[NSArray arrayWithObject:gamePeerId] withDataMode:GKSendDataUnreliable error:nil];
		}
	}
    // NSLog(@"send paket2"); 
}


#pragma mark GKSessionDelegate Methods

-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    if (sessionState == ConnectionStateDisconnected) {
        NSLog(@"Session receive");
        server = NO;
        gamePeerId = [peerID copy];
        sessionState = ConnectionStateConnected;
        [delegateTable didReceiveInvitation:gameSession fromPeer:[gameSession displayNameForPeer:peerID]]; 
    }
    else
        [gameSession denyConnectionFromPeer:peerID];
}

// Unable to connect to a session with the peer, due to rejection or exiting the app
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
    if (sessionState != ConnectionStateDisconnected) {
        // Make self available for a new connection.
        gamePeerId = nil;
        gameSession.available = YES;
        sessionState = ConnectionStateDisconnected;
    }
}


// we've gotten a state change in the session
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state { 
    
    NSLog(@"ID =  %@, %d, main peer %@", peerID, [peerList count], gameSession.peerID);
    
    
    
    switch (state) { 
		case GKPeerStateAvailable:
            // A peer became available by starting app, exiting settings, or ending a call.
            NSLog(@"available");
 			
			break;
		case GKPeerStateUnavailable:
            // Peer unavailable due to joining a call, leaving app, or entering settings.
            NSLog(@"Unavailable");
            
			break;
		case GKPeerStateConnected:
            // Connection was accepted, set up the voice chat.
            NSLog(@"conected");
            gameSession.available = NO;
            if (server) {
                NSLog(@"sinhronisation");
                sessionState = ConnectionStateConnected;
                gameInfo *gs = &gameStat;
                gs->randTime = randomTime;
                gs->oponentMoney = playerAccount.money;
                [playerAccount.accountName getCString:gs->oponentName maxLength:MAX_LENGTH encoding:NSUTF8StringEncoding];
                
                [playerAccount.typeImage getCString:gs->oponentImage maxLength:IMG_LENGTH encoding:NSUTF8StringEncoding];
                gs->shotTime = playerAccount.accountLevel;
                [self sendNetworkPacket:gameSession packetID:NETWORK_TIME withData:gs ofLength:sizeof(gameInfo) reliable:NO];
                
            }
            // Compare the IDs to decide which device will invite the other to a voice chat.
            break;				
		case GKPeerStateDisconnected:
            // The call ended either manually or due to failure somewhere.
            NSLog(@"disconected");
            sessionState = ConnectionStateDisconnected;
            
           	break;
        case GKPeerStateConnecting:
            NSLog(@"Connecting");
            // Peer is attempting to connect to the session.
            break;
		default:
			break;
	}
    
    //self.gameSession = [session retain];   
} 

-(void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"Fail");
    if ([[error domain] isEqual:kGKSessionErrorDomain] && ([error code] == GKSessionCannotEnableError))
    {
        // Bluetooth disabled, prompt the user to turn it on
        NSLog(@"Bluetoth disabled");
    }
}

#pragma mark DuelViewControllerDelegate Methods
-(void)accelerometerSendPosition
{
    if(accelState){
        NSLog(@"Send position");
        gameInfo *gs = &gameStat;
        [self sendNetworkPacket:gameSession packetID:NETWORK_ACCEL_STATE withData:gs ofLength:sizeof(gameInfo) reliable:NO];
    }
}
-(void)sendShotTime:(int)shotTime
{
    NSLog(@"get Time");
    gameInfo *gs = &gameStat;
    gs->shotTime = shotTime;
    carShotTime = shotTime;
    if((carShotTime !=0)&&(opShotTime!=0)&& (!endDuel)){
        endDuel = YES;
        if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)]) 
            [delegate duelTimerEndFeedBack];
        NSLog(@"init 3");
        finalViewController = [[FinalViewController alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        [parentVC.navigationController pushViewController:finalViewController animated:YES]; 
    }
    
    if((carShotTime == 999999.0)&& (!endDuel)){
        
        if ([delegate respondsToSelector:@selector(duelTimerEndFeedBack)]) 
            [delegate duelTimerEndFeedBack];
        NSLog(@"init 4");
        finalViewController = [[FinalViewController alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        [parentVC.navigationController pushViewController:finalViewController animated:YES]; 
        endDuel = YES;
    }
    [self sendNetworkPacket:gameSession packetID:NETWORK_SEND_SHOT_TIME withData:gs ofLength:sizeof(gameInfo) reliable:NO];
    
    
    
    
}

-(void)follStart
{
    //accelState = YES;
    gameInfo *gs = &gameStat;
    [self sendNetworkPacket:gameSession packetID:NETWORK_FOLL_START withData:gs ofLength:sizeof(gameInfo) reliable:NO];
}

-(void)follEnd
{
    accelState = YES;
    gameInfo *gs = &gameStat;
    NSLog(@"send foll end");
    [self sendNetworkPacket:gameSession packetID:NETWORK_FOLL_END withData:gs ofLength:sizeof(gameInfo) reliable:NO];
}

-(void)duelTimerEnd
{
    NSLog(@"Duel timer end %d %d", carShotTime, opShotTime);
    
    if ((carShotTime == 0)&&(opShotTime == 0)) {
        NSLog(@"Duel timer end %d %d true", carShotTime, opShotTime);
        
        finalViewController = [[FinalViewController alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        [parentVC.navigationController pushViewController:finalViewController animated:YES];
    }
    else {
        NSLog(@"Duel timer end %d %d false", carShotTime, opShotTime);
        
        
        finalViewController = [[FinalViewController alloc] initWithUserTime:carShotTime andOponentTime:opShotTime andController:self andTeaching:NO andAccount:playerAccount andOpAccount:oponentAccount];
        [parentVC.navigationController pushViewController:finalViewController animated:YES];
    }
}

-(void)nextDuelStart
{
    accelState = NO;
    carShotTime = 0;
    opShotTime = 0;
    endDuel = NO;
    if (server) {
        randomTime = arc4random() % 6;
        gameInfo *gs = &gameStat;
        gs->randTime = randomTime;
        [self sendNetworkPacket:gameSession packetID:NETWORK_START_DUEL withData:gs ofLength:sizeof(gameInfo) reliable:NO];
        startAv = [[UIAlertView alloc] initWithTitle:@"Start duel" message:@"Start duel" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        startAv.tag = SENDER_TAG;
        //[startAv show];
    }
}


-(void)increaseMutchNumberLose
{
    mutchNumberLose++;   
}
-(void)increaseMutchNumber
{
    mutchNumber++;
    NSLog(@"Match number %d", mutchNumber);
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

-(void)duelRunAway
{
    
    carShotTime = 0.0;
    opShotTime = 0.0;
    accelState = NO;
    
    mutchNumber = 0;
    mutchNumberWin = 0;
    mutchNumberLose = 0;
    
    gameInfo *gs = &gameStat;
    [self sendNetworkPacket:gameSession packetID:NETWORK_RUN_AWAY withData:gs ofLength:sizeof(gameInfo) reliable:NO];
    
}


-(void)connect:(NSString *)currentPeer
{
    gamePeerId = [currentPeer copy];
    NSLog(@"%@",currentPeer);
    server = YES;
    //[gameSession connectToPeer:currentPeer withTimeout:10.0];
    sessionState = ConnectionStateConnecting;
}

@end
