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
#import "CustomNSURLConnection.h"

static const char *DONATE_URL = BASE_URL"api/time";

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
                @"com.webkate.cowboyduels.achievement.0",
                @"com.webkate.cowboyduels.achievement.1", 
                @"com.webkate.cowboyduels.achievement.2",
                @"com.webkate.cowboyduels.achievement.3",
                @"com.webkate.cowboyduels.achievement.4",
                @"com.webkate.cowboyduels.achievement.5",
                @"com.webkate.cowboyduels.achievement.6",
                @"com.webkate.cowboyduels.achievement.7",
                @"com.webkate.cowboyduels.achievement.8",
                @"com.webkate.cowboyduels.achievement.9",
                @"com.webkate.cowboyduels.achievement.10",
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
        //       DuelDataSource *duelDataSource = [[DuelDataSource alloc] initWithLogin:localPlayer];
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
        [GClocalPlayer authenticateWithCompletionHandler:nil];        
    } else {
        DLog(@"Already authenticated!");
        [self acceptedInvite];
    }
}

-(void)acceptedInvite{
    DLog(@"acceptedInvite...");
    //    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"GC" message:@"acceptedInvite" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //    [av show];
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
            //NSString *st=[[NSString alloc] init];
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
            
            //            [presentingViewController popToRootViewControllerAnimated:YES];
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
            //            DLog(@"report false %@ ",error);
            [self saveScoreToDevice:scoreReporter];  
            
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
                [self saveScoreToDevice:scoreReporter];  
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
        //        
        //        UIWindow* window = [UIApplication sharedApplication].keyWindow;  
        //        [window addSubview: presentingViewController.view];  
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
                [self saveAchievementToDevice:achievement];
                
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
                [self saveAchievementToDevice:achievement];  
                //                DLog(@"Achievements false %@ ",error);
            }          
        }];  
    }  
}  

- (void)saveAchievementToDevice:(GKAchievement *)achievement  
{  
    NSString *savePath = getGameCenterSavePath();  
    DLog(@"saveAchievementToDevice");
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
             
             
             //             DLog(@"Ach = ",[achievementsDictionary g]);
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
    //    request.playersToInvite = [NSArray arrayWithObjects: @"G:1121692656",nil ];
    
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
    [self sendRequestWithTime:requestTime andCancel:YES];
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
    
    [self sendRequestWithTime:requestTime andCancel:NO];
    
    DLog(@"didFindMatch math %@ delege %@",match, match.delegate);
    
    //    NSString *st=[NSString stringWithFormat:@"didFindMatch math %@ delege %@",match,match.delegate];
    //    UIAlertView* startAv = [[UIAlertView alloc] initWithTitle:@"GCHelper" message:st delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    //    [startAv show];
    match.delegate = self;
    
    if (!matchStarted && match.expectedPlayerCount == 0) {
        matchStarted=YES;
        //        invaitFriend=YES;
        if (delegate==NULL){
            
            DLog(@"Delegate_null");
            //            UIAlertView* startAv = [[UIAlertView alloc] initWithTitle:@"matchmakerViewController" message:@"Delegate_null" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            //            [startAv show];
            [self setDelegate:[[GameCenterViewController alloc] initWithAccount:[self playerAccount] andParentVC:nil]];
            [delegate matchStarted];
        }else{
            DLog(@"Delegate_not_null");
            //            UIAlertView* startAv = [[UIAlertView alloc] initWithTitle:@"matchmakerViewController" message:@"Delegate_not_null" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            //            [startAv show];
            [delegate matchStarted];
            [delegate matchStartedSinxron];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/duel_GS(invait)" forKey:@"event"]];
//        [TestFlight passCheckpoint:@"/duel_GS(invait)"];
        return;
    }          
}

#pragma mark GKMatchDelegate

-(void) sendDataData:(void *) data packetID:(int)packetID ofLength:(int)length{
    
    NSError *error = nil;
    
    static unsigned char networkPacket[kMaxTankPacketSize];
	const unsigned int packetHeaderSize = 2 * sizeof(int); // we have two "ints" for our header
	
	if(length < (kMaxTankPacketSize - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
		int *pIntData = (int *)&networkPacket[0];
		// header info
		pIntData[0] = 1;
		pIntData[1] = packetID;
		
        
        // copy data in after the header
		memcpy( &networkPacket[packetHeaderSize], data, length ); 
		
		NSData *packet = [NSData dataWithBytes: networkPacket length: (length+10)];
        //    if(invaitFriend){
        if(match!=nil){   
            
            //            [delegate match:match didReceiveData:packet fromPlayer:NULL];
            
            [match sendDataToAllPlayers: packet withDataMode: GKMatchSendDataUnreliable error:&error];
            if (error != nil)
            {
                DLog(@"send data false  %@",[error description]);
                UIAlertView *startAv = [[UIAlertView alloc] initWithTitle:@"send data false" message:@"send data false" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [startAv show];
                // handle the error
            }else{
                DLog(@"send data good math %@ delege %@",match,match.delegate);
                
//                                   NSString *st=[NSString stringWithFormat:@"send data good math "];
//                                    UIAlertView* startAv = [[UIAlertView alloc] initWithTitle:@"GC helper" message:st delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
//                                    [startAv show];
            }
        }else{
            DLog(@"match==nil");
        }
    }
}


// The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    
    
//    UIAlertView* startAv = [[UIAlertView alloc] initWithTitle:@"GC helper" message:@"didReceiveData" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
//    [startAv show];
    
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
                
                //                NSString *st=[NSString stringWithFormat:@"match didChangeState! player start math %@",match];
                //                UIAlertView* startAv = [[UIAlertView alloc] initWithTitle:@"GC helper" message:st delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                //                [startAv show];
                
                [delegate matchStarted];
                [delegate matchStartedSinxronPlayNow];
            }
            
            break; 
        case GKPlayerStateDisconnected:
            // a player just disconnected. 
            DLog(@"GC helper Player disconnected!");
            
            //            UIAlertView* startAv = [[UIAlertView alloc] initWithTitle:@"GC helper" message:@"Player disconnected!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            //            [startAv show];
            
            matchStarted = NO;
            [delegate matchEnded];
            break;
    }                 
    
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    DLog(@"Failed to connect to player with error: ");
    if (match != theMatch) return;
    
    DLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    matchStarted = NO;
    [delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
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
             // Process the error.
             DLog(@"error %@ match %@", error, foundMatch);
         }
         else if (foundMatch != nil)
         {
             DLog(@"Match good");
             DLog(@"Match %@",foundMatch);
             self.match = foundMatch; // Use a retaining property to retain the match.
             self.match.delegate = self; // start!
             // Start the match.
             // Start the game using the match.
             
         }
     }];
}

#pragma mark -

-(void)sendRequestWithTime:(int)time
                 andCancel:(BOOL)cancel
{
    NSString *cancelReq;
    if (cancel) cancelReq = @"YES";
    else cancelReq = @"NO";
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    NSLocale* curentLocale = [NSLocale currentLocale];
    NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:DONATE_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    [theRequest setHTTPMethod:@"POST"]; 
    NSMutableDictionary *dicBody=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [NSString stringWithFormat:@"%d", time],@"time",
                           cancelReq,@"cancel",
                           version,@"app_ver",
                           currentDevice.systemName,@"system_name",
                           currentDevice.systemVersion,@"system_version",
                           currentDevice.uniqueIdentifier,@"unique_identifier",
                           [curentLocale localeIdentifier],@"region",
                           [languages objectAtIndex:0],@"current_language",
                           nil];
    
    [dicBody setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceType"] forKey:@"device_name"];
    [dicBody setValue:GClocalPlayer.playerID forKey:@"authentification"];
    [dicBody setValue:playerAccount.sessionID forKey:@"session_id"];
    
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
//        [receivedData setLength:0];
        receivedData = [[NSMutableData alloc] init];
    } else {
    }

    
}

#pragma mark CustomNSURLConnection handlers

- (void)connectionDidFinishLoading:(CustomNSURLConnection *)connection1 {
    
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
}

- (void)connection:(CustomNSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(CustomNSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // inform the user
    DLog(@"Chat Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

#pragma mark DuelWithBot

- (void)showBotDuel { 
	if(botDuel)
    {
        [presentingViewController performSelector:@selector(showAlertBotDuel) ];         
    }
	
	
}


@end
