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

 
@interface DuelViewControllerWithXib : UIViewController <DuelViewControllerDelegate,UIAccelerometerDelegate> {
    BOOL duelIsStarted;
    BOOL fireSound;

    BOOL acelStayt;

    AVAudioPlayer *player;
    AVAudioPlayer *player1;
    AVAudioPlayer *player2;
    AVAudioPlayer *player3;
    AVAudioPlayer *follPlayer;
    
    ActivityIndicatorView *activityIndicatorView;
    
    AccountDataSource *playerAccount;
    AccountDataSource *opAccount;
    
    SystemSoundID pickerTick;
       
    NSTimer *timer;
    int shotTime;
    
    BOOL accelerometerState;
    BOOL soundStart;
    BOOL foll;
    int shotCount;
    int shotCountForSound;
    int shotCountBullet;
    int maxCountBullet;
    BOOL follAccelCheck;
    BOOL LisForShot;
    
    UILabel *label;
    NSTimeInterval startInterval;
    NSTimeInterval stopInterval;
    NSTimeInterval nowInterval;
    NSTimeInterval activityInterval;
    
    BOOL duelTimerEnd;
        
    BOOL buttonCheck;
    AccelerometrDataSource *accelerometrDataSource;
    FintType fintType;
    
    SEL selectorAnim;
    CGRect imgFrame;
    
    int maxShotCount;
    
    float rollingX;
    float rollingY;
    float rollingZ;
    
    BOOL follViewShow;
    BOOL accelerometerStateSend;
    
    IBOutlet UIView *view;
    IBOutlet UIView *_vBackground;
    IBOutlet UIView *_vEarth;
    IBOutlet UIButton *_btnNab;
    IBOutlet UIImageView *_ivGun;
    IBOutlet UILabel *_lbBullets;
    IBOutlet UIButton *_infoButton;
    IBOutlet UILabel *lbBackButton;
    IBOutlet UIButton *menuButton;
    IBOutlet UIImageView *titleSteadyFire;
    IBOutlet UIImageView *titleReady;
    
    UIView  *helpPracticeView;
    UIImageView *imvArrow;
    BOOL arrowAnimationContinue;

    float steadyScale;
    float scaleDelta;


}
@property (strong, nonatomic) IBOutlet UIView *_vEarth;
@property (strong, nonatomic) IBOutlet UIButton *_btnNab;
@property (strong, nonatomic) IBOutlet UIImageView *_ivGun;
@property (strong, nonatomic) IBOutlet UILabel *_lbBullets;
@property (strong, nonatomic) IBOutlet UIButton *_infoButton;
@property (strong, nonatomic) IBOutlet UIImageView *titleSteadyFire;

-(id)initWithAccount:(AccountDataSource *)userAccount oponentAccount:(AccountDataSource *)oponentAccount;
-(float)abs:(float)d;
-(void)setRotationWithAngle:(float)angle andY:(float)y;
-(IBAction)buttonClick;
-(IBAction)backButtonClick:(id)sender;
-(void)vibrationStart;
-(void)startDuel;
-(void)restartCountdown;
-(void)hideHelpViewWithArm;
-(void)showHelpViewWithArm;
-(void)setTextToMessageShot;

@property(weak)id<DuelViewControllerDelegate> delegate;
@end
