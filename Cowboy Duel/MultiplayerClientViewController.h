//
//  MultiplayerClientViewController.h
//  Cowboy Duel 1
//
//  Created by Sergey Sobol on 05.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiplayerServerViewController.h"
//#import "BluetoothViewController.h"


//#define kMaxTankPacketSize 256

@class GameCenterViewController;
@interface MultiplayerClientViewController : UIViewController
{
    
    BOOL isRunClient;
    NSString *__strong isFounsServerName;
    
    void *dataGlobal;
    int packetIDGlobal;
    int lengthGlobal;
    char *hostname;
    int pingCount;
    
    GameCenterViewController *__unsafe_unretained gameCenterViewController;
    BOOL serverRecponse;
    BOOL neadSend;
    int lastReceivedPacket;

}

@property (unsafe_unretained, nonatomic) GameCenterViewController *gameCenterViewController;
@property (nonatomic) BOOL isRunClient;
@property (strong, nonatomic) NSString *isFounsServerName;

+(id)sharedInstance:(char *)serverName;

-(id)initWithServerName:(char *)serverName;
-(void)shutDownClient;
-(void)receivePacket;
-(void)sendDataData:(void *) data packetID:(int)packetID ofLength:(int)length;
-(void)sendResponse;
-(void)messageShow;


@end
