//
//  ActiveDuelViewController.h
//  Cowboy Duels
//
//  Created by Sergey Sobol on 10.01.13.
//
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
#import <AVFoundation/AVFoundation.h>
#import "PLView.h"
#import "PLJSONLoader.h"

@protocol ActiveDuelViewControllerDelegate <NSObject>

@optional
-(void)setAccelStateTrue;
-(void)setAccelStateFalse;
-(BOOL)accelerometerSendPositionSecond;
-(void)sendShotTime:(int)shotTime;
-(void)startDuel;
-(void)btnClickStart;
-(void)follStart;
-(void)follEnd;
- (void) peerListDidChange:(NSMutableArray *)peer;
- (void) connect:(NSString *)currentPeer;
- (void) didReceiveInvitation:(GKSession *)session fromPeer:(NSString *)participantID;

-(void)partnerFoll;

-(BOOL) didAcceptInvitation;
-(void) didDeclineInvitation;

-(void)duelTimerEnd;
-(void)duelTimerEndFeedBack;

-(void)setNumWins;

-(void)nextDuelStart;

-(void)matchStartedTry;

-(void)duelCancel;
-(void)duelRunAway;

-(void)shutDownTimer;

-(void)opponentShot;
-(void)sendShot;

-(void)oponnentFollStart;
-(void)oponnentFollEnd;

-(void)readyToStart;

@end

@protocol DuelStartViewControllerDelegate <NSObject>

@optional
-(void)setOponent:(NSString*)iv Label1:(NSString*)uil1 Label1:(int)uil2;
-(void)setMessageToOponent:(NSString*)pMessage;
-(void)cancelDuel;
-(void)setUserMoney:(int)money;
-(void)setOponentMoney:(int)money;
@end


@interface ActiveDuelViewController : UIViewController
{
    BOOL duelIsStarted;
    BOOL fireSound;
    
    BOOL acelStatus;
    
    AVAudioPlayer *player;
    
    NSTimeInterval startInterval;
    NSTimeInterval stopInterval;
    NSTimeInterval nowInterval;
    NSTimeInterval activityInterval;
    
    NSTimer *timer;
    int shotTime;
    BOOL soundStart;
    BOOL accelerometerState;
    
    BOOL accelerometerStateSend;
    
    BOOL follAccelCheck;
    
    PLView *plView;
    
}

@property(weak)id<ActiveDuelViewControllerDelegate> delegate;

-(id)initWithTime:(int)randomTime Account:(AccountDataSource *)userAccount oponentAccount:(AccountDataSource *)pOponentAccount;
-(void)userLost;
@end
