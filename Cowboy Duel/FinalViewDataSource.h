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

#import "DuelStartViewController.h"

@interface FinalViewDataSource : NSObject
{
    CDTransaction *transaction;
    CDDuel *duel;

    NSArray *pointForEachLevels;
    NSArray *pontsForWin;
    NSArray *pontsForLose;
    
//    BOOL teaching;
    BOOL duelWithBotCheck;

    int userTime;
    
    AccountDataSource* playerAccount;
    AccountDataSource* oponentAccount;
}
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
@property (nonatomic) BOOL isDuelWinWatched;


-(id)initWithUserTime:(int)userTimePar
       andOponentTime:(int)oponentTime
          andTeaching:(BOOL)teach
           andAccount:(AccountDataSource *)userAccount
         andOpAccount:(AccountDataSource *)opAccount;

+(NSArray *)getStaticPointsForEachLevels;

-(void)prepeareForWinScene;
-(void)prepeareForLoseScene;

@end
