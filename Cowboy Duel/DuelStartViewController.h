//
//  DuelStartViewController.h
//  Test
//
//  Created by Sobol on 08.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountDataSource.h"
#import "GCHelper.h"
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Utils.h"
#import "ProfileViewController.h"
#import "StartViewController.h"
#import "IconDownloader.h"
#import "DuelViewControllerWithXib.h"

@class GameCenterViewController;
@interface DuelStartViewController : UIViewController<DuelStartViewControllerDelegate,FBRequestDelegate,IconDownloaderDelegate,MemoryManagement> {
    AccountDataSource *playerAccount;
    AccountDataSource *oponentAccount;
    NSString *__weak oponentNameOnLine;
    
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
    
    
    __weak IBOutlet UIButton *_btnStart;
    
    __weak IBOutlet UIView *_vBackground;
    
    __weak IBOutlet UIView  *_vWait;
    
    __weak IBOutlet UIView *mainDuelView;
    __weak IBOutlet UILabel *lbDuelStart;
    
    __weak IBOutlet UILabel *_lbNamePlayer;
    __weak IBOutlet UIImageView *_ivPlayer;
    __weak IBOutlet UILabel *lbUserRank;
    __weak IBOutlet UILabel *lbUserDuelsWin;
    __weak IBOutlet UILabel *lbUserDuelsWinCount;
    
    __weak IBOutlet UILabel *_lbNameOponent;
    __weak IBOutlet UIImageView *_ivOponent;
    __weak IBOutlet UILabel *lbOpponentRank;
    __weak IBOutlet UILabel *lbOpponentDuelsWin;
    __weak IBOutlet UILabel *lbOpponentDuelsWinCount;
      
    __weak IBOutlet UILabel *lbForTheMurder;
    __weak IBOutlet UILabel *lbReward;
    __weak IBOutlet UILabel *lbGoldCount;
    __weak IBOutlet UILabel *lbGold;
    __weak IBOutlet UILabel *lbPointsCount;
    __weak IBOutlet UILabel *lbPoints;

    NSString *serverName;
    int timerIndex;
    
       
}
@property (weak, nonatomic) IBOutlet UIImageView *_ivPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *_ivOponent;
@property (weak, nonatomic) IBOutlet UILabel *_lbNamePlayer;
@property (weak, nonatomic) IBOutlet UILabel *_lbNameOponent;
@property (weak, nonatomic) IBOutlet UILabel  *lbOpponentDuelsWinCount;
@property (weak, nonatomic) IBOutlet UIButton *_btnBack;
@property (weak, nonatomic) IBOutlet UIButton *_btnStart;
@property (weak, nonatomic) IBOutlet UIView *_vBackground;
@property (weak, nonatomic) IBOutlet UIView  *_vWait;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *fbPlayerImage;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *fbOpponentImage;

@property(weak, nonatomic)id<DuelViewControllerDelegate> delegate;
@property (weak, nonatomic) NSString *oponentNameOnLine;
@property (strong, nonatomic) NSString *serverName;
@property (nonatomic) BOOL oponentAvailable;
@property (nonatomic) BOOL tryAgain;
@property (nonatomic) NSTimer *waitTimer;

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

-(void)stopWaitTimer;
@end