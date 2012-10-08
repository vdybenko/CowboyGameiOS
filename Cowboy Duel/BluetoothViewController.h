//
//  BluetoothViewController.h
//  Test
//
//  Created by Sobol on 11.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "DuelViewController.h"
#import "TableViewController.h"
#import "AccountDataSource.h"
#import "DuelStartViewController.h"
#import "AdvertisingAppearController.h"


#define MAX_LENGTH 20
#define IMG_LENGTH 8


typedef enum {
    ConnectionStateDisconnected,
    ConnectionStateConnecting,
    ConnectionStateConnected
} ConnectionState;

@class FinalViewController;

@interface BluetoothViewController : UIViewController <GKSessionDelegate,GKPeerPickerControllerDelegate , UIAlertViewDelegate, DuelViewControllerDelegate> {
    UIButton *button; 
    UIButton *sendButton;
    UIButton *startButton;
    UIButton *backButton;
    UIViewController *parentVC;
    DuelStartViewController *duelStartViewController;

    TableViewController *tableViewController;

    AccountDataSource *playerAccount;
    AccountDataSource *oponentAccount;
    
    DuelViewController *duelViewController;
        
    // networking
	GKSession		*gameSession;
    NSString		*gamePeerId;
    int randomTime;
    UIAlertView *startAv;
    NSMutableArray *peerList;
    
    BOOL start;
    
    gameInfo gameStat;
    
    BOOL accelState;
    int carShotTime;
    int opShotTime;
    
    int moneyExchenge;
    
    int mutchNumber;
    int mutchNumberWin;
    int mutchNumberLose;
    
    BOOL server;
    BOOL startViewGlob;
    
    BOOL endDuel;

    ConnectionState sessionState;
    FinalViewController *finalViewController;
    GKPeerPickerController *pickerController;
    
}
@property(strong,nonatomic) GKSession	*gameSession;
@property (strong,nonatomic, readonly) NSMutableArray *peerList;
@property (strong,nonatomic) TableViewController *tableViewController;
@property(unsafe_unretained)id<DuelViewControllerDelegate> delegate;
@property(unsafe_unretained)id<DuelViewControllerDelegate> delegateTable;
@property(unsafe_unretained)id<DuelStartViewControllerDelegate> delegate2;


-(id)initWithAccount:(AccountDataSource *)userAccount
             andView:(id)view
            andStart:(BOOL)startView;
-(void)sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend;
-(void)startButtonClick;
- (void)invalidateSession:(GKSession *)session;
-(void)reloadTable;
-(NSMutableArray *)peerList;
//-(void)sessionRestart;
- (void) setupSession;


@end
