//
//  GCHelper.h
//  CatRace
//
//  Created by Ray Wenderlich on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

//#import "NetworkManager.h"
//#import "DuelDataSource.h"

#define GC_LEADEBOARD_MONEY @"com.webkate.cowboyduels.leaderboard.gold"

@class AccountDataSource;

@protocol GCHelperDelegate 
- (void)matchStarted;
- (void)matchStartedSinxron;
- (void)matchStartedSinxronPlayNow;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
- (void)matchEnded;
- (void)finishLaunching;
@end

@protocol GCAuthenticateDelegate 
- (void)setLocalPlayer:(GKLocalPlayer *)player;
@end

@interface GCHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate,GKLeaderboardViewControllerDelegate,GKAchievementViewControllerDelegate> {
    
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    NSArray *GC_ACH;

    AccountDataSource *__unsafe_unretained playerAccount;

    
    UIViewController *__unsafe_unretained presentingViewController;
    UIViewController *nextViewController;

    GKMatch *__unsafe_unretained match;
    BOOL matchStarted;
    BOOL botDuel;

//    id <GCHelperDelegate> delegate;
    NSMutableDictionary *__strong achievementsDictionary;
    GKAchievement *singleAchievement;
    
    int requestTime;
    
    BOOL aceptIvite;
    
    NSMutableData *receivedData;
//    BOOL invaitFriend;
} 

@property (assign, readonly) BOOL gameCenterAvailable;

@property (strong, readonly) NSArray *GC_ACH;
@property  (unsafe_unretained) UIViewController *presentingViewController;
@property  (unsafe_unretained) GKMatch *match;
@property  (strong) NSMutableDictionary *achievementsDictionary;
@property   (unsafe_unretained) GKLocalPlayer *GClocalPlayer;
@property (unsafe_unretained) id <GCHelperDelegate> delegate;
@property (unsafe_unretained) id <GCAuthenticateDelegate> delegate2;
@property (unsafe_unretained) AccountDataSource *playerAccount;


+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)acceptedInvite;
- (void)finishLaunching;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers ;
- (void)findProgrammaticMatch;
//- (void) sendDataStr:(NSString*) str;
//- (void) sendDataInt:(void *) arg packetID:(int)packetID;
- (void) sendDataData:(void *) data packetID:(int)packetID ofLength:(int)length;


- (void)reportScore:(int64_t)score forCategory:(NSString*)category;
- (void)reportScore:(GKScore *)scoreReporter;  
- (void)saveScoreToDevice:(GKScore *)score;  
- (void)retrieveScoresFromDevice;  
- (BOOL)showLeaderboard:(NSString*)category ;  
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;  

- (void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent;
- (void)reportAchievementIdentifier:(GKAchievement *)achievement;  
- (void)saveAchievementToDevice:(GKAchievement *)achievement;  
- (void)retrieveAchievementsFromDevice;  
- (BOOL)showAchievements;  
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController; 
- (void) loadAchievements;
- (void) resetAchievements;

- (GKAchievement*) getAchievementForIdentifier: (NSString*) identifier;

-(void)sendRequestWithTime:(int)time
                 andCancel:(BOOL)cancel;

@end
