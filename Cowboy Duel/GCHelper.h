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

@interface GCHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate,GKLeaderboardViewControllerDelegate,GKAchievementViewControllerDelegate> 
@property (assign, readonly) BOOL gameCenterAvailable;

@property (strong, readonly) NSArray *GC_ACH;
@property  (strong) UIViewController *presentingViewController;
@property  (strong) GKMatch *match;
@property  (strong) NSMutableDictionary *achievementsDictionary;
@property   (unsafe_unretained) GKLocalPlayer *GClocalPlayer;
@property (strong) id <GCHelperDelegate> delegate;
@property (strong) id <GCAuthenticateDelegate> delegate2;
@property (strong) AccountDataSource *playerAccount;

+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)acceptedInvite;
- (void)finishLaunching;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers ;
- (void)findProgrammaticMatch;
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
