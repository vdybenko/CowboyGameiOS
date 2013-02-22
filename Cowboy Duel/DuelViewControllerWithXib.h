//
//  TestViewController.h
//  Test
//
//  Created by Sobol on 11.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>
#import "AccelerometrDataSource.h"
#import "ActivityIndicatorView.h"
#import "UIView+Dinamic_BackGround.h"
#import "AccountDataSource.h"

#define kFilteringFactor 0.5
static CGFloat const ANIMATION_TIME = 0.3f;

@protocol DuelViewControllerDelegate <NSObject>

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

-(void)increaseMutchNumberLose;
-(void)increaseMutchNumber;
-(void)increaseMutchNumberWin;
-(int)fMutchNumberLose;
-(int)fMutchNumber;
-(int)fMutchNumberWin;

-(void)duelCancel;
-(void)duelRunAway;

-(void)shutDownTimer;

@end

@protocol DuelStartViewControllerDelegate <NSObject>

@optional
-(void)setOponent:(NSString*)iv Label1:(NSString*)uil1 Label1:(int)uil2;
-(void)cancelDuel;
-(void)setUserMoney:(int)money;
-(void)setOponentMoney:(int)money;
@end
