//
//  FinalViewController.h
//  Test
//
//  Created by Sobol on 23.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DuelViewController.h"
#import "DuelStartViewController.h"
#import "AccountDataSource.h"
//#import "BluetoothViewController.h"
#import "ResoultDataSource.h"
#import "ValidationUtils.h"
#import "CDTransaction.h"
#import "CDDuel.h"
#import "ActivityIndicatorView.h"
#import "TeachingViewController.h"
#import "SBJSON.h"
#import "JSON.h"
//#import "ASIFormDataRequest.h"
#import "StartViewController.h"
#import "UIButton+Image+Title.h"
#import "UIView+Dinamic_BackGround.h"
#import "LoginAnimatedViewController.h"

#import "ValidationUtils.h"

//#import "CongratulationViewController.h"

#import "LevelCongratViewController.h"
#import "MoneyCongratViewController.h"

@interface FinalViewController : UIViewController <DuelViewControllerDelegate, UITableViewDataSource, UITableViewDelegate,MemoryManagement> {
    ActivityIndicatorView *activityIndicatorView;
    
    AccountDataSource *playerAccount;
    AccountDataSource *oponentAccount;
        
    TeachingViewController *teachingViewController;
    LoginAnimatedViewController *loginViewController;
    
    int oldMoney;
    int oldMoneyForAnimation;
  
    int fMutchNumberWin;
    int fMutchNumberLose;
    int minUserTime;
    int userTime;
    ResoultDataSource *resoultDataSource;
      
    NSString *stGA;
    NSString *falseLabel;
    BOOL foll;
    
    BOOL teaching;
    BOOL duelWithBotCheck;
    BOOL reachNewLevel;
    BOOL lastDuel;
    BOOL runAway;
    BOOL runAwayGood;
    
    BOOL firstRun;
    
    AVAudioPlayer *player;
    AVAudioPlayer *follPlayerFinal;
    CDTransaction *transaction;
    CDDuel *duel;
    
    NSArray *_pointForEachLevels;
    NSArray *_pontsForWin;
    NSArray *_pontsForLose;
    
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *nextButton;

    IBOutlet UITableView *resultTable;
    
    IBOutlet UILabel *lblNamePlayer;
    IBOutlet UILabel *lblNameOponnent;
    
    IBOutlet UILabel *lblResulDescription;
  
    IBOutlet UIView *ivGoldCoin;
    IBOutlet UIImageView *ivBlueLine;
    IBOutlet UIImageView *ivCurrentRank;
    IBOutlet UIImageView *ivNextRank;
    IBOutlet FXLabel *lblGoldPlus;

    IBOutlet UIView *viewLastSceneAnimation;
        
    UIImageView *loserImg;
    UIImageView *loserSpiritImg;
    UIImageView *winnerImg1;
    UIImageView *winnerImg2;
    UIImageView *loserMoneyImg;
  
    IBOutlet UIView *view;
    IBOutlet UIView *statView;
    
    IBOutlet UILabel *lbBack;
    IBOutlet UILabel *lbTryAgain;
    IBOutlet UILabel *lbNextRound;
    
    
    __weak IBOutlet FXLabel *lblGold;
    __weak IBOutlet UILabel *gameStatusLable;
    __weak IBOutlet FXLabel *lblPoints;
    __weak IBOutlet UIView *goldPointBgView;
    __weak IBOutlet UILabel *lblGoldTitle;
}
@property(weak)id<DuelViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *tryButton;
@property (strong, nonatomic) IBOutlet UIView *statView;

-(id)initWithUserTime:(int)userTimePar
       andOponentTime:(int)oponentTime
        andGameCenterController:(id)delegateController
          andTeaching:(BOOL)teach
           andAccount:(AccountDataSource *)userAccount
         andOpAccount:(AccountDataSource *)opAccount;

-(void)showMessage;
-(void)hideMessage;

-(void)winAnimation;
-(void)loseAnimation;

-(void)prepeareForWinScene;
-(void)prepeareForLoseScene;

-(void)runAway;
+(NSArray *)getStaticPointsForEachLevels;
-(IBAction)backButtonClick:(id)sender;
-(IBAction)tryButtonClick:(id)sender;

@end
