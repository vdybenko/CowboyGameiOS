//
//  Class.h
//  Test
//
//  Created by Taras on 26.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GCHelper.h"
#import "ActiveDuelViewController.h"

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
    int barrelsCount;
    int cactusCount;
    int horseCount;
    int menCount;
    int womenCount;
    int damageCount;
//    Visual view parts
    int partCap;
    int partHead;
    int partShirt;
    int partJaket;
    int partPants;
    int partBoots;
    int partGun;
    int partSuit;
} gameInfo;

@class StartViewController;
@class FinalViewController;
@class DuelStartViewController;
@class FinalViewDataSource;

@interface GameCenterViewController : UIViewController< UIAlertViewDelegate, GCHelperDelegate, ActiveDuelViewControllerDelegate, DuelStartViewControllerDelegate,MemoryManagement>
{
    ActiveDuelViewController *activeDuelViewController;
    DuelStartViewController *duelStartViewController;
    FinalViewController *finalViewController;
    AccountDataSource *playerAccount;
    AccountDataSource *oponentAccount;
    FinalViewDataSource *finalViewDataSource;
    StartViewController *startViewController;
    
    UIAlertView *baseAlert;
    
    id multiplayerViewController;
    
    GCHelper *gameCenter;
    UIViewController *__weak parentVC;
    
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
@property(strong,nonatomic)id<ActiveDuelViewControllerDelegate> delegate;
@property(strong,nonatomic)id<DuelStartViewControllerDelegate> delegate2;
@property(strong,nonatomic)DuelStartViewController *duelStartViewController;
@property( weak, readwrite) UIViewController *parentVC;
@property(nonatomic) BOOL opponentEndMatch;
@property(nonatomic) BOOL userEndMatch;
@property(nonatomic) BOOL typeGameWithMessage;
@property(nonatomic) BOOL userCanceledMatch;


+(id)sharedInstance:(AccountDataSource *)userAccount andParentVC:(id)view;

-(id)initWithAccount:(AccountDataSource *)userAccount andParentVC:(id)view;
-(void)startDuel;
- (void)clientConnected;
-(void)receiveData:(NSData *)data;
-(void)startClientWithName:(char *)serverName;
-(void)startClientWithName:(char *)serverName AndMessage:(NSString*)pMes;
-(void)matchStartedSinxron;
-(void)matchStarted;
-(void)lostConnection;
-(void)userCancelMatch;
-(void)matchCanseled;
-(void)startClientWithHost:(NSString *)host;


@end
