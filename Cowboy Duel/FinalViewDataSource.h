//
//  FinalViewDataSource.h
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 09.04.13.
//
//

#import <Foundation/Foundation.h>
#import "CDTransaction.h"
#import "CDDuel.h"
#import "AccountDataSource.h"

#import "ValidationUtils.h"
#import "SBJSON.h"
#import "JSON.h"

#import "LevelCongratViewController.h"
#import "MoneyCongratViewController.h"
#import "DuelStartViewController.h"

@interface FinalViewDataSource : NSObject
{
    CDTransaction *transaction;
    CDDuel *duel;

    NSArray *pointForEachLevels;
    NSArray *pontsForWin;
    NSArray *pontsForLose;
    
//    BOOL teaching;
    BOOL firstRun;
    BOOL duelWithBotCheck;
    BOOL lastDuel;
    BOOL runAway;
    BOOL runAwayGood;

    int minUserTime;
    int userTime;
    
//    int moneyExch;
//    int pointsForMatch;
    
    AccountDataSource* playerAccount;
    AccountDataSource* oponentAccount;
    
}
@property(weak)id<ActiveDuelViewControllerDelegate> delegate;

@property (nonatomic) AccountDataSource* playerAccount;
@property (nonatomic) AccountDataSource* oponentAccount;

@property (nonatomic) int moneyExch;
@property (nonatomic) int pointsForMatch;
@property (nonatomic) int oldMoney;
@property (nonatomic) int oldPoints;

@property (nonatomic) BOOL reachNewLevel;
@property (nonatomic) BOOL userWon;
@property (nonatomic) BOOL tryButtonEnabled;
@property (nonatomic) BOOL teaching;

-(id)initWithUserTime:(int)userTimePar
       andOponentTime:(int)oponentTime
        andGameCenterController:(id)delegateController
          andTeaching:(BOOL)teach
           andAccount:(AccountDataSource *)userAccount
         andOpAccount:(AccountDataSource *)opAccount;

+(NSArray *)getStaticPointsForEachLevels;

-(void)prepeareForWinScene;
-(void)prepeareForLoseScene;

@end
