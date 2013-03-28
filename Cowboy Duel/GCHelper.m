//
//  GCHelper.m
//  CatRace
//
//  Created by Ray Wenderlich on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GCHelper.h"
#import "GameCenterViewController.h"
#import "AccountDataSource.h"
#import "Utils.h"

@interface GCHelper()
{
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    NSArray *GC_ACH;
    
    AccountDataSource * playerAccount;
    
    UIViewController *presentingViewController;
    UIViewController *nextViewController;
    
    GKMatch * match;
    BOOL matchStarted;
    BOOL botDuel;
    
    NSMutableDictionary * achievementsDictionary;
    GKAchievement *singleAchievement;
    
    int requestTime;
    
    BOOL aceptIvite;
} 

@end

@implementation GCHelper
@synthesize gameCenterAvailable;
@synthesize presentingViewController;
@synthesize match;
@synthesize delegate;
@synthesize GClocalPlayer;
@synthesize playerAccount;
@synthesize achievementsDictionary;
@synthesize delegate2;
@synthesize GC_ACH;


//--------------------------------------------------------  
// Static functions/variables  
//--------------------------------------------------------  

static NSString *getGameCenterSavePath()  
{  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    return [NSString stringWithFormat:@"%@/GameCenterSave.txt",[paths objectAtIndex:0]];  
}  

static NSString *scoresArchiveKey = @"Scores";  

static NSString *achievementsArchiveKey = @"Achievements";  

//--------------------------------------------------------  
// Authentication  
//--------------------------------------------------------  
#pragma mark Initialization

static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
	// check for presence of GKLocalPlayer API
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
	// check if the device is running iOS 4.1 or later
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer 
                                           options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}

- (id)init {
    self = [super init];
    if (self) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = 
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self 
                   selector:@selector(authenticationChanged) 
                       name:GKPlayerAuthenticationDidChangeNotificationName 
                     object:nil];
        }
        
        GC_ACH=[[NSArray alloc] initWithObjects:
                @"grp.com.bidon.cowboychalenge.achievement.1", //Junior
                @"grp.com.bidon.cowboychalenge.achievement.2",
                @"grp.com.bidon.cowboychalenge.achievement.3",
                @"grp.com.bidon.cowboychalenge.achievement.4",
                @"grp.com.bidon.cowboychalenge.achievement.5",
                @"grp.com.bidon.cowboychalenge.achievement.6",
                @"grp.com.bidon.cowboychalenge.achievement.7",
                nil];
        
        achievementsDictionary = [[NSMutableDictionary alloc] init];
        GClocalPlayer=[GKLocalPlayer localPlayer];
    }
    
    return self;
}

#pragma mark Internal functions

- (void)authenticationChanged {
    if (GClocalPlayer.isAuthenticated && !userAuthenticated) {
        DLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
        if (delegate2)
            [delegate2 setLocalPlayer:GClocalPlayer];
    } else if (!GClocalPlayer.isAuthenticated && userAuthenticated) {
        DLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
}

#pragma mark User functions

- (void)authenticateLocalUser { 
    
    if (!gameCenterAvailable) return;
    
    DLog(@"Authenticating local user...");
    if (GClocalPlayer.authenticated == NO) {     
        [GClocalPlayer authenticateWithCompletionHandler:^(NSError *error) {
            // If there is an error, do not assume local player is not authenticated.
            if (GClocalPlayer.isAuthenticated) {
                userAuthenticated = YES;
                [self authenticationChanged];
            } else {
                userAuthenticated = NO;
            }
        }];
    } else {
        DLog(@"Already authenticated!");
        [self acceptedInvite];
    }
}

-(void)acceptedInvite{
    DLog(@"acceptedInvite...");
    [presentingViewController dismissModalViewControllerAnimated:YES];  
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
        self.delegate=NULL;
        if (acceptedInvite) {
            
            // Individual invite (from inside the game)
            
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite];
            
            mmvc.matchmakerDelegate = self;
            //            [presentingViewController.navigationController popToRootViewControllerAnimated:YES];
            
            [presentingViewController presentModalViewController:mmvc animated:YES];
            
            DLog(@"invite acceptedInvite");
        } else if (playersToInvite) {
            
            // In Apple's documentation, it's not clear when this option is used.
            // In theory, this should be called when a game is initiated from the
            // GameCenter app itself, however as of iOS 4.2.1 this is not apparently
            // possible.
            
            GKMatchRequest *request = [[GKMatchRequest alloc] init];
            request.minPlayers = 2;
            request.maxPlayers = 2;
            request.playersToInvite = playersToInvite;
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
            mmvc.matchmakerDelegate = self;
            
            [presentingViewController presentModalViewController:mmvc animated:YES];
            
            DLog(@"invite playersToInvite");
        }
    };
    DLog(@"acceptedInvite end");
}

//--------------------------------------------------------  
// Leaderboard  
//--------------------------------------------------------  

#pragma mark Leaderboard

- (void)reportScore:(int64_t)score forCategory:(NSString*)category  
{  
    if(!userAuthenticated)  
        return;
    
    
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            // handle the reporting error
            DLog(@"report false %@ ",error);
//            [self saveScoreToDevice:scoreReporter];  
        }else{
            DLog(@"report good ");
        }
    }];
    
    
}  

- (void)reportScore:(GKScore *)scoreReporter  
{  
    if(!gameCenterAvailable)  
        return;  
    
    if(scoreReporter){  
        [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {   
            if (error != nil){  
                // handle the reporting error  
//                [self saveScoreToDevice:scoreReporter];  
                //                DLog(@"report false %@ ",error);
                
            }  
        }];   
    }  
}  

- (void)saveScoreToDevice:(GKScore *)score  
{  
    NSString *savePath = getGameCenterSavePath();  
    
    // If scores already exist, append the new score.  
    NSMutableArray *scores = [[NSMutableArray alloc] init];  
    NSMutableDictionary *dict;  
    if([[NSFileManager defaultManager] fileExistsAtPath:savePath]){  
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:savePath];  
        
        NSData *data = [dict objectForKey:scoresArchiveKey];  
        if(data) {  
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];  
            scores = [unarchiver decodeObjectForKey:scoresArchiveKey];  
            [unarchiver finishDecoding];  
            [dict removeObjectForKey:scoresArchiveKey]; // remove it so we can add it back again later  
        }  
    }else{  
        dict = [[NSMutableDictionary alloc] init];  
    }  
    
    [scores addObject:score];  
    
    // The score has been added, now save the file again  
    NSMutableData *data = [NSMutableData data];   
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];  
    [archiver encodeObject:scores forKey:scoresArchiveKey];  
    [archiver finishEncoding];  
    [dict setObject:data forKey:scoresArchiveKey];  
    [dict writeToFile:savePath atomically:YES];  
}  

- (void)retrieveScoresFromDevice  
{  
    NSString *savePath = getGameCenterSavePath();  
    
    // If there are no files saved, return  
    if(![[NSFileManager defaultManager] fileExistsAtPath:savePath]){  
        return;  
    }  
    
    // First get the data  
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:savePath];  
    NSData *data = [dict objectForKey:scoresArchiveKey];  
    
    // A file exists, but it isn't for the scores key so return  
    if(!data){  
        return;  
    }  
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];  
    NSArray *scores = [unarchiver decodeObjectForKey:scoresArchiveKey];  
    [unarchiver finishDecoding];  
    
    // remove the scores key and save the dictionary back again  
    [dict removeObjectForKey:scoresArchiveKey];  
    [dict writeToFile:savePath atomically:YES];  
    
    // Since the scores key was removed, we can go ahead and report the scores again  
    for(GKScore *score in scores){  
        [self reportScore:score];  
    }  
}  

- (BOOL)showLeaderboard:(NSString*)category  
{  
    
    if(!userAuthenticated)  
        return NO;    
    DLog(@"leader");
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];      
    if (leaderboardController != nil) { 
        DLog(@"leaderboardController");
        [leaderboardController setCategory:category];
        leaderboardController.leaderboardDelegate = self;  
        [presentingViewController presentModalViewController: leaderboardController animated: YES]; 
        return YES;  
    }  
    return YES;
}  

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController  
{
    [presentingViewController dismissModalViewControllerAnimated:YES];  
    [viewController.view removeFromSuperview];  
}  
//--------------------------------------------------------  
// Achievements  
//--------------------------------------------------------  
#pragma mark Achievements
- (void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent
{  
    if(!userAuthenticated)  
        return;  
    
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: identifier];  
    if (achievement){         
        achievement.percentComplete = percent;        
        [achievement reportAchievementWithCompletionHandler:^(NSError *error){  
            if (error != nil){ 
                //               DLog(@"Achievements false %@ ",error);
//                [self saveAchievementToDevice:achievement];
            }  
        }];  
    }  
}  

- (void)reportAchievementIdentifier:(GKAchievement *)achievement  
{     
    if(!gameCenterAvailable)  
        return;  
    
    if (achievement){         
        [achievement reportAchievementWithCompletionHandler:^(NSError *error){  
            if (error != nil){  
//                [self saveAchievementToDevice:achievement];  
                //                DLog(@"Achievements false %@ ",error);
            }          
        }];  
    }  
}  

- (void)saveAchievementToDevice:(GKAchievement *)achievement  
{  
    NSString *savePath = getGameCenterSavePath();  
    // If achievements already exist, append the new achievement.  
    NSMutableArray *achievements = [[NSMutableArray alloc] init];  
    NSMutableDictionary *dict;  
    if([[NSFileManager defaultManager] fileExistsAtPath:savePath]){  
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:savePath];  
        
        NSData *data = [dict objectForKey:achievementsArchiveKey];  
        if(data) {  
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];  
            achievements = [unarchiver decodeObjectForKey:achievementsArchiveKey];  
            [unarchiver finishDecoding];  
            [dict removeObjectForKey:achievementsArchiveKey]; // remove it so we can add it back again later  
        }  
    }else{  
        dict = [[NSMutableDictionary alloc] init];  
    }  
    
    [achievements addObject:achievement];  
    
    // The achievement has been added, now save the file again  
    NSMutableData *data = [NSMutableData data];   
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];  
    [archiver encodeObject:achievements forKey:achievementsArchiveKey];  
    [archiver finishEncoding];  
    [dict setObject:data forKey:achievementsArchiveKey];  
    [dict writeToFile:savePath atomically:YES];  
}  

- (void)retrieveAchievementsFromDevice  
{  
    NSString *savePath = getGameCenterSavePath();  
    
    // If there are no files saved, return  
    if(![[NSFileManager defaultManager] fileExistsAtPath:savePath]){  
        return;  
    }  
    
    // First get the data  
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:savePath];  
    NSData *data = [dict objectForKey:achievementsArchiveKey];  
    
    // A file exists, but it isn't for the achievements key so return  
    if(!data){  
        return;  
    }  
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];  
    NSArray *achievements = [unarchiver decodeObjectForKey:achievementsArchiveKey];  
    [unarchiver finishDecoding];  
    
    // remove the achievements key and save the dictionary back again  
    [dict removeObjectForKey:achievementsArchiveKey];  
    [dict writeToFile:savePath atomically:YES];  
    
    // Since the key file was removed, we can go ahead and try to report the achievements again  
    for(GKAchievement *achievement in achievements){ 
        [self reportAchievementIdentifier:achievement]; 
    }  
}  

- (BOOL)showAchievements  
{     
    if(!userAuthenticated)  
        return NO;  
    
    GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init]; 
    if (achievements != nil){  
        achievements.achievementDelegate = self;  
        [presentingViewController presentModalViewController: achievements animated: YES];
        return YES;  
    } 
    return YES;
}  

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController  
{  
    [presentingViewController dismissModalViewControllerAnimated:YES];  
    [viewController.view removeFromSuperview];  
}  

-(void) loadAchievements
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
     {
         if (error == nil)
         {
             for (GKAchievement* achievement in achievements)
                 [achievementsDictionary setObject: achievement forKey: achievement.identifier];
        }else{
             DLog(@"load ach error %@",error);
         }
     }];
}

-(GKAchievement*) getAchievementForIdentifier: (NSString*) identifier
{   
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
     {
         if (error == nil)
         {
             for (GKAchievement* achievement in achievements)
                 
                 [achievementsDictionary setObject: achievement forKey: achievement.identifier];
             
             singleAchievement = [achievementsDictionary objectForKey:identifier];
             if (singleAchievement == nil)
             {
                 singleAchievement = [[GKAchievement alloc] initWithIdentifier:identifier];
                 [achievementsDictionary setObject:singleAchievement forKey:singleAchievement.identifier];
             }
         }else{
             DLog(@"load ach error %@",error);
         }
     }];
    return singleAchievement;
}

- (void) resetAchievements { 
    // Clear all locally saved achievement objects.
    achievementsDictionary = [[NSMutableDictionary alloc] init]; 
    // Clear all progress saved on Game Center 
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
     {
         if (error == nil)
         {
             DLog(@"Clere good");
             
         }else{
             DLog(@"load ach error %@",error);
         }
         
     }];
}


//--------------------------------------------------------  
// Multiplayer
//--------------------------------------------------------  


    - (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers {
    
    requestTime = [NSDate timeIntervalSinceReferenceDate];
    
    DLog(@"requestTime %d", requestTime);
    
    if (!gameCenterAvailable) return;
    DLog(@"Find oponents.....!");
    matchStarted = NO;
    botDuel = YES;
    self.match = nil;
    
    [presentingViewController dismissModalViewControllerAnimated:NO];
    
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init]; 
    request.minPlayers = minPlayers;     
    request.maxPlayers = maxPlayers;
    request.playersToInvite =nil;
    
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];    
    mmvc.matchmakerDelegate = self;
    [presentingViewController presentModalViewController:mmvc animated:YES];
    
    int randomTime = (arc4random() % 10)+15;
    [self performSelector:@selector(showBotDuel) withObject:self afterDelay:randomTime];    
}

#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [presentingViewController dismissModalViewControllerAnimated:YES]; 
    [self finishLaunching];
    botDuel = NO;
    requestTime = [NSDate timeIntervalSinceReferenceDate] - requestTime;
    DLog(@"cancel invite");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/duel_GS(cancel)" forKey:@"event"]];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [presentingViewController dismissModalViewControllerAnimated:YES];
    DLog(@"Error finding match: %@", error.localizedDescription); 
    botDuel = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/duel_GS(error)" forKey:@"event"]];    
}

// A peer-to-peer match has been found, the game should start v
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch {
    
    botDuel = NO;
    self.match = theMatch;
    
    requestTime = [NSDate timeIntervalSinceReferenceDate] - requestTime;
    
    DLog(@"requestTime %d", requestTime);
        
    DLog(@"didFindMatch math %@ delege %@",match, match.delegate);

    match.delegate = self;
    
    if (!matchStarted && match.expectedPlayerCount == 0) {
        matchStarted=YES;
        //        invaitFriend=YES;
        if (delegate==NULL){
            
            DLog(@"Delegate_null");
            [self setDelegate:[[GameCenterViewController alloc] initWithAccount:[self playerAccount] andParentVC:nil]];
            [delegate matchStarted];
        }else{
            DLog(@"Delegate_not_null");
            [delegate matchStarted];
            [delegate matchStartedSinxron];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/duel_GS(invait)" forKey:@"event"]];
        return;
    }          
}

#pragma mark GKMatchDelegate

-(void) sendDataData:(void *) data packetID:(int)packetID ofLength:(int)length{
    
    NSError *error = nil;
    
    static unsigned char networkPacket[1024];
	const unsigned int packetHeaderSize = 2 * sizeof(int); // we have two "ints" for our header
	
	if(length < (1024 - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
		int *pIntData = (int *)&networkPacket[0];
		// header info
		pIntData[0] = 1;
		pIntData[1] = packetID;
		
        
        // copy data in after the header
		memcpy( &networkPacket[packetHeaderSize], data, length ); 
		
		NSData *packet = [NSData dataWithBytes: networkPacket length: (length+10)];
        //    if(invaitFriend){
        if(match!=nil){   
            [match sendDataToAllPlayers: packet withDataMode: GKMatchSendDataUnreliable error:&error];
            if (error != nil)
            {
                DLog(@"send data false  %@",[error description]);
                // handle the error
            }else{
                DLog(@"send data good math %@ delege %@",match,match.delegate);
            }
        }else{
            DLog(@"match==nil");
        }
    }
}


// The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    if (match != theMatch) return;
    
    if (delegate) 
        [delegate match:theMatch didReceiveData:data fromPlayer:playerID];
    else
        DLog(@"Delegete nil");
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    
    if (match != theMatch) return; 
    switch (state) {
        case GKPlayerStateConnected: 
            // handle a new player connection.    
            
            if (!matchStarted && theMatch.expectedPlayerCount == 0) {
                matchStarted = YES;
                DLog(@"match didChangeState! player start");
                DLog(@"match %@",match.delegate);
                
                [delegate matchStarted];
                [delegate matchStartedSinxronPlayNow];
            }
            
            break; 
        case GKPlayerStateDisconnected:
            // a player just disconnected. 
            DLog(@"GC helper Player disconnected!");
            
            matchStarted = NO;
            [delegate matchEnded];
            break;
    }                 
    
}

- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    DLog(@"Failed to connect to player with error: ");
    if (match != theMatch) return;
    
    DLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    matchStarted = NO;
    [delegate matchEnded];
}

- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error {
    
    DLog(@"Match failed with error:");
    if (match != theMatch) return;
    
    DLog(@"Match failed with error: %@", error.localizedDescription);
    matchStarted = NO;
    [delegate matchEnded];
}

- (void)finishLaunching { 
    
    if (delegate){ 
        [delegate finishLaunching];
    }
}


- (void)findProgrammaticMatch
{
    DLog(@"findProgrammaticMatch...... ");
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    request.playersToInvite = [NSArray arrayWithObjects: @"G:1434757652",nil ];
    
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request
                                   withCompletionHandler:^(GKMatch *foundMatch, NSError *error)
     {
         if (error)
         {
             DLog(@"error %@ match %@", error, foundMatch);
         }
         else if (foundMatch != nil)
         {
             DLog(@"Match good");
             DLog(@"Match %@",foundMatch);
             self.match = foundMatch; // Use a retaining property to retain the match.
             self.match.delegate = self; // start!
             
         }
     }];
}

#pragma mark DuelWithBot

- (void)showBotDuel { 
	if(botDuel)
    {
        [presentingViewController performSelector:@selector(showAlertBotDuel) ];         
    }
	
	
}


@end
