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

@interface FinalViewController : UIViewController <DuelViewControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    ActivityIndicatorView *activityIndicatorView;
    
    AccountDataSource *playerAccount;
    AccountDataSource *oponentAccount;
        
    TeachingViewController *teachingViewController;
    LoginAnimatedViewController *loginViewController;
    
//    CongratulationViewController *congratulationViewController;
    LevelCongratViewController *lvlCongratulationViewController;
    MoneyCongratViewController *moneyCongratulationViewController; 
    
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
  
    //WinView
    IBOutlet UIView *viewWin;
    IBOutlet UILabel *lblWinEarned;
    IBOutlet UILabel *lblWinGold;
    IBOutlet UILabel *lblWinGoldCount;
    IBOutlet UILabel *lblWinPoints;
    IBOutlet UILabel *lblWinPointsCount;
    
    //LoseView
    IBOutlet UIView *viewLose;
    IBOutlet UILabel *lblLoseEarned;
    IBOutlet UILabel *lblLoseLost;
    IBOutlet UILabel *lblLoseGold;
    IBOutlet UILabel *lblLoseGoldCount;
    IBOutlet UILabel *lblLosePoints;
    IBOutlet UILabel *lblLosePointsCount;

    IBOutlet UIView *viewLastSceneAnimation;
    
    IBOutlet UIView *hudView;
    
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
    
    
    __unsafe_unretained IBOutlet FXLabel *lblGold;
    __unsafe_unretained IBOutlet UILabel *gameStatusLable;
    __unsafe_unretained IBOutlet FXLabel *lblPoints;
    __unsafe_unretained IBOutlet UIView *goldPointBgView;
    __unsafe_unretained IBOutlet UILabel *lblGoldTitle;
    __unsafe_unretained IBOutlet UILabel *lblPointsTitle;
}
@property(unsafe_unretained)id<DuelViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *tryButton;
@property (strong, nonatomic) IBOutlet UIView *statView;

@property (strong, nonatomic) IBOutlet UIView *viewWin;
@property (strong, nonatomic) IBOutlet UILabel *lblWinEarned;
@property (strong, nonatomic) IBOutlet UILabel *lblWinGold;
@property (strong, nonatomic) IBOutlet UILabel *lblWinGoldCount;
@property (strong, nonatomic) IBOutlet UILabel *lblWinPoints;
@property (strong, nonatomic) IBOutlet UILabel *lblWinPointsCount;
 
@property (strong, nonatomic) IBOutlet UIView *viewLose;
@property (strong, nonatomic) IBOutlet UILabel *lblLoseEarned;
@property (strong, nonatomic) IBOutlet UILabel *lblLoseLost;
@property (strong, nonatomic) IBOutlet UILabel *lblLoseGold;
@property (strong, nonatomic) IBOutlet UILabel *lblLoseGoldCount;
@property (strong, nonatomic) IBOutlet UILabel *lblLosePoints;
@property (strong, nonatomic) IBOutlet UILabel *lblLosePointsCount;

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
