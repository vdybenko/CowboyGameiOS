//
//  SSConnection.h
//  TCPClient
//
//  Created by Sergey Sobol on 11.10.12.
//  Copyright (c) 2012 Sergey Sobol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameCenterViewController.h"


typedef enum {
    NETWORK_PING,
    NETWORK_POST_INFO,
    NETWORK_GET_LIST_ONLINE,
    NETWORK_SET_PAIR,
    NETWORK_LOST_CONNECTION,
	NETWORK_TIME,					// no packet 0
    NETWORK_TIME_TRY,               //1
	NETWORK_START_DUEL,				// send position 2
	NETWORK_START_DUEL_TRUE,				// send fire 3
   	NETWORK_START_DUEL_FALSE,				// send of entire state at regular intervals 4
    NETWORK_ACCEL_STATE,                    //5
    NETWORK_ACCEL_STATE_TRUE,               //6
    NETWORK_SEND_SHOT_TIME,                 //7
    NETWORK_FOLL_START,                     //8
    NETWORK_FOLL_END,                       //9
    NETWORK_OPONTYPE_RESPONSE,              //10
    NETWORK_OPONTYPE_RESPONSE_TRY,          //11
    NETWORK_RUN_AWAY,                       //12
    NETWORK_RESPONSE,                       //13
    NETWORK_DUEL_CANSEL                     //16
    
} packetCodes;


@protocol SSConnectionDelegate <NSObject>
- (void) getData:(NSData *)message andLength:(int)length;
- (void) lostConnection;
- (void) listOnlineResponse:(NSString *)jsonString;
@end

@interface SSConnection : NSObject <NSStreamDelegate>
- (void)networkCommunicationWithPort:(NSString *)port andIp:(NSString *)ip;
- (void) sendData:(void *) data packetID:(int)packetID ofLength:(int)length;
- (void)disconnect;
+ (id)sharedInstance;

@property (nonatomic) id <SSConnectionDelegate> delegate;
@property (nonatomic, strong) GameCenterViewController *gameCenterViewController;
@end
