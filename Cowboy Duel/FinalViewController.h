//
//  FinalViewController.h
//  Test
//
//  Created by Sobol on 23.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DuelStartViewController.h"
#import "AccountDataSource.h"
#import "ValidationUtils.h"
#import "CDTransaction.h"
#import "CDDuel.h"
#import "ActivityIndicatorView.h"
#import "SBJSON.h"
#import "JSON.h"
#import "StartViewController.h"
#import "UIButton+Image+Title.h"
#import "UIView+Dinamic_BackGround.h"
#import "LoginAnimatedViewController.h"

#import "ValidationUtils.h"


#import "LevelCongratViewController.h"
#import "MoneyCongratViewController.h"

@interface FinalViewController : UIViewController <DuelViewControllerDelegate, UITableViewDataSource, UITableViewDelegate,MemoryManagement> {
    ActivityIndicatorView *activityIndicatorView;
    
    AccountDataSource *playerAccount;
    AccountDataSource *oponentAccount;
        
    LoginAnimatedViewController *loginViewController;
    
    int oldMoney;
    int oldMoneyForAnimation;
  
    int minUserTime;
    int userTime;
      
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
    
    __weak IBOutlet UIButton *backButton;

    
    __weak IBOutlet UILabel *lblNamePlayer;
    __weak IBOutlet UILabel *lblNameOponnent;
    
  
    __weak IBOutlet UIView *ivGoldCoin;
    __weak IBOutlet UIImageView *ivBlueLine;
    __weak IBOutlet UIImageView *ivCurrentRank;
    __weak IBOutlet UIImageView *ivNextRank;
    __weak IBOutlet FXLabel *lblGoldPlus;

    __weak IBOutlet UIView *viewLastSceneAnimation;
        
    UIImageView *loserImg;
    UIImageView *loserSpiritImg;
    UIImageView *winnerImg1;
    UIImageView *winnerImg2;
    UIImageView *loserMoneyImg;
  
    __weak IBOutlet UIView *view;
    
    __weak IBOutlet FXLabel *lblGold;
    __weak IBOutlet UILabel *gameStatusLable;
    __weak IBOutlet FXLabel *lblPoints;
    __weak IBOutlet UIView *goldPointBgView;
    __weak IBOutlet UILabel *lblGoldTitle;
}
@property(weak)id<ActiveDuelViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *tryButton;

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
