//
//  Class.h
//  Test
//
//  Created by Taras on 26.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DuelViewController.h"
#import "GCHelper.h"


#define MAX_LENGTH 50
#define IMG_LENGTH 8
typedef struct {
    int oponentMoney;
    char oponentName[MAX_LENGTH];
    int oponentWins;
    char oponentAuth[MAX_LENGTH];
    int oponentLevel;
    int randomTime;
    int oponentShotTime;
    int oponentAtack;
    int oponentDefense;
} gameInfo;
@class StartViewController;
@class FinalViewController;
@class DuelStartViewController;

@interface GameCenterViewController : UIViewController< UIAlertViewDelegate, DuelViewControllerDelegate, DuelStartViewControllerDelegate, GCHelperDelegate>
{
    DuelViewController *duelViewController;
    DuelStartViewController *duelStartViewController;
    FinalViewController *finalViewController;
    AccountDataSource *playerAccount;
    AccountDataSource *oponentAccount;

    StartViewController *startViewController;

    UIAlertView *baseAlert;
    
    id multiplayerViewController;
    
    GCHelper *gameCenter;
    UIViewController *__unsafe_unretained parentVC;

    int randomTime;
    int myTime;
    UIAlertView *startAv;
    
    BOOL start;
    BOOL btnStartClick;
    BOOL runAway;
    
    BOOL typeGameWithMessage;   
    NSString *_messageToOpponent;
    
    gameInfo gameStat;
    
    BOOL accelState;
    int carShotTime;
    int opShotTime;
    
    int moneyExchenge;
    
    int mutchNumber;
    int mutchNumberWin;
    int mutchNumberLose;
    
    BOOL server;
    
    BOOL endDuel;
    BOOL opponentEndMatch;
    BOOL userEndMatch;
    BOOL isTryAgain;
}
@property(strong)id<DuelViewControllerDelegate> delegate;
@property(strong)id<DuelStartViewControllerDelegate> delegate2;
@property(strong,nonatomic)DuelStartViewController *duelStartViewController;
@property( unsafe_unretained, readwrite) UIViewController *parentVC;
@property(nonatomic) BOOL opponentEndMatch;
@property(nonatomic) BOOL userEndMatch;
@property(nonatomic) BOOL typeGameWithMessage;
@property(nonatomic) BOOL userCanceledMatch;


+(id)sharedInstance:(AccountDataSource *)userAccount andParentVC:(id)view;

-(id)initWithAccount:(AccountDataSource *)userAccount andParentVC:(id)view;
-(void)startDuel;
- (void)clientConnected;
-(void)receiveData:(NSData *)data;
-(void)startServerWithName:(NSString *)serverName;
-(void)stopServer;
-(void)startClientWithName:(char *)serverName;
-(void)startClientWithName:(char *)serverName AndMessage:(NSString*)pMes;
-(void)matchStartedSinxron;
-(void)matchStarted;
-(void)lostConnection;
-(void)userCancelNutch;
-(void)matchCanseled;
-(void)startClientWithHost:(NSString *)host;


@end
