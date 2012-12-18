//
//  DuelStartViewController.h
//  Test
//
//  Created by Sobol on 08.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountDataSource.h"
#import "TeachingViewController.h"
#import "GCHelper.h"
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ActivityIndicatorView.h"
#import "Utils.h"
#import "ProfileViewController.h"
#import "StartViewController.h"
#import "IconDownloader.h"

@class GameCenterViewController;
@interface DuelStartViewController : UIViewController<DuelStartViewControllerDelegate,FBRequestDelegate,IconDownloaderDelegate> {
    AccountDataSource *playerAccount;
    AccountDataSource *oponentAccount;
    ProfileViewController *profileViewController;
    NSString *__unsafe_unretained oponentNameOnLine;
    
    GCHelper *gameCenter;
    
    AVAudioPlayer *player;
    
    id messageViewControllerId;
    id messageViewControllerFB;
    
    NSString *pathFile;
    
    BOOL firstRun;
    
    NSTimer *waitTimer;
    
    int waitTimeCount;
    
    NSMutableArray *lineViews;
    NSMutableArray *twoLineViews;
    
    BOOL serverType;
    
    BOOL runAnimation;
    BOOL tryAgain;
    BOOL oponentAvailable;
    
    IconDownloader *iconDownloader;
    
    IBOutlet ActivityIndicatorView *activityIndicatorView;
    
    IBOutlet UIButton *_btnBack;
    IBOutlet UIButton *_btnStart;
    
    IBOutlet UIView *_vBackground;
    
    IBOutlet UIView  *_vWait;
    
    IBOutlet UIView *mainDuelView;
    IBOutlet UILabel *lbDuelStart;
    
    IBOutlet UILabel *_lbNamePlayer;
    IBOutlet UIImageView *_ivPlayer;
    IBOutlet UILabel *lbUserRank;
    IBOutlet UILabel *lbUserDuelsWin;
    IBOutlet UILabel *lbUserDuelsWinCount;
    
    IBOutlet UILabel *_lbNameOponent;
    IBOutlet UIImageView *_ivOponent;
    IBOutlet UILabel *lbOpponentRank;
    IBOutlet UILabel *lbOpponentDuelsWin;
    IBOutlet UILabel *lbOpponentDuelsWinCount;
      
    IBOutlet UILabel *lbForTheMurder;
    IBOutlet UILabel *lbReward;
    IBOutlet UILabel *lbGoldCount;
    IBOutlet UILabel *lbGold;
    IBOutlet UILabel *lbPointsCount;
    IBOutlet UILabel *lbPoints;

    NSString *serverName;
    int timerIndex;
    
       
}
@property (strong, nonatomic) IBOutlet ActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIImageView *_ivPlayer;
@property (strong, nonatomic) IBOutlet UIImageView *_ivOponent;
@property (strong, nonatomic) IBOutlet UILabel *_lbNamePlayer;
@property (strong, nonatomic) IBOutlet UILabel *_lbNameOponent;
@property (strong, nonatomic) IBOutlet UILabel  *lbOpponentDuelsWinCount;
@property (strong, nonatomic) IBOutlet UIButton *_btnBack;
@property (strong, nonatomic) IBOutlet UIButton *_btnStart;
@property (strong, nonatomic) IBOutlet UIView *_vBackground;

@property (strong, nonatomic) IBOutlet UILabel *_waitLabel;
@property (strong, nonatomic) IBOutlet UILabel *_pleaseWaitLabel;
@property (strong, nonatomic) IBOutlet UIView  *_vWait;
@property (unsafe_unretained, nonatomic) IBOutlet FBProfilePictureView *fbPlayerImage;
@property (unsafe_unretained, nonatomic) IBOutlet FBProfilePictureView *fbOpponentImage;

@property(strong)id<DuelViewControllerDelegate> delegate;
@property (unsafe_unretained, nonatomic) NSString *oponentNameOnLine;
@property (strong, nonatomic) NSString *serverName;
@property (nonatomic) BOOL oponentAvailable;
@property (nonatomic) BOOL tryAgain;

-(id)initWithAccount:(AccountDataSource *)userAccount
        andOpAccount:(AccountDataSource *)opAccount
        opopnentAvailable:(BOOL)available
       andServerType:(BOOL)server
         andTryAgain:(BOOL)tryA;

-(void)setMessageTry;
-(void)setUserMoney:(int)money;
-(void)setAttackAndDefenseOfOponent:(AccountDataSource*)oponent;
-(void)setOponentMoney:(int)money;
-(void)waitAnimation;


-(IBAction)startButtonClick;
-(IBAction)cancelButtonClick;

-(void)duelBot:(BOOL)duelWithBot;

@end