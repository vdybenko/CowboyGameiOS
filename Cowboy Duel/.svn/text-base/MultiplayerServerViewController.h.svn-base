//
//  MultiplayerServerViewController.h
//  Cowboy Duel 1
//
//  Created by Sergey Sobol on 03.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "BluetoothViewController.h"
#include "qr2.h"
#include "natneg.h"


#define INBUF_LEN 256
#define kMaxTankPacketSize 512


typedef enum {
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
    NETWORK_PING,                           //14
    NETWORK_PING_RESPONSE,                  //15
    NETWORK_DUEL_CANSEL                     //16
    
} packetCodes;


@class GameCenterViewController;

@interface MultiplayerServerViewController : UIViewController<UIAlertViewDelegate>
{
    BOOL isRunServer;
    BOOL neadSend;
    
    void *dataGlobal;
    int packetIDGlobal;
    int lengthGlobal;
    
    int lastPingTime;
    
    
    __strong GameCenterViewController * gameCenterViewController;
    
    BOOL neadRestart;
    NSTimer *pingTimer;
    BOOL pingStart;
    int lastReceivedPacket;
    NSString *serverNameGlobal;

}

@property (strong, nonatomic) GameCenterViewController *gameCenterViewController;
@property (nonatomic) BOOL isRunServer;
@property (nonatomic) BOOL neadRestart;
@property (nonatomic) BOOL pingStart;
@property (nonatomic) NSString *serverNameGlobal;


+(id)sharedInstance:(NSString *)serverName;

-(id)initWithServerName:(NSString *)serverName;
-(void)createServer;
-(void)shutDownServer;
-(void)receivePacket;
-(void) sendDataData:(void *) data packetID:(int)packetID ofLength:(int)length;
-(void)sendResponse;




void serverkey_callback(int keyid, qr2_buffer_t outbuf, void *userdata);
void playerkey_callback(int keyid, int index, qr2_buffer_t outbuf, void *userdata);
void teamkey_callback(int keyid, int index, qr2_buffer_t outbuf, void *userdata);
void keylist_callback(qr2_key_type keytype, qr2_keybuffer_t keybuffer, void *userdata);
int  count_callback(qr2_key_type keytype, void *userdata);
void adderror_callback(qr2_error_t error, gsi_char *errmsg, void *userdata);
void nn_callback(int cookie, void *userdata);
void cm_callback(gsi_char *data, int len, void *userdata);
void cc_callback(SOCKET gamesocket, struct sockaddr_in *remoteaddr, void *userdata);
void hr_callback(void *userdata);
void DoGameStuff(gsi_time totalTime);
int tryread(SOCKET s);


@end
