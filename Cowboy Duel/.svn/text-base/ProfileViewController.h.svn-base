//
//  ProfileViewController.h
//  Test
//
//  Created by Sobol on 11.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "AccountDataSource.h"
#import "ProfileImageView.h"
#import "ScrollView.h"
#import "ViewProjectHelper.h"
#import "TopPlayersViewController.h"

@class LoginViewController;
@class StartViewController;

#define kFbUserNameKey @"fbUserName"
#define kFbUserIdKey @"fbUserId"

@protocol  ProfileWithLoginDelegate <NSObject>
@optional
-(void)skipLoginFB;
-(void)loginToFB;
@end

@interface ProfileViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate,ProfileWithLoginDelegate>{
    
    AccountDataSource *playerAccount;

    LoginViewController *loginViewController;
    
    NSString *namePlayerSaved;
    
    int typeAcc;
    BOOL firstRun;
    BOOL firstLocalRun;
    
    NSMutableString *stDonate;
    UIAlertView *baseAlert;
    
    IBOutlet UIImageView *_ivIconUser;
    IBOutlet UIButton *_btnBack;
    IBOutlet UIView *_vBackground;
    
    //Labels
    IBOutlet UILabel *lbProfileMain;
    IBOutlet UIView *mainProfileView;
    IBOutlet UITextField *lbFBName;
    IBOutlet UILabel *lbTitleTitle;
    IBOutlet UILabel *lbUserTitle;
    IBOutlet UILabel *lbPointsTitle;
    IBOutlet UILabel *lbPointsCount;
    
    IBOutlet UIView *ivPointsLine;
    IBOutlet UIImageView *ivPointsLineBackGround;

    IBOutlet UILabel *lbGoldCount;
    
    IBOutlet UIButton *btnLogInFB;
    IBOutlet UIButton *btnLogOutFB;
    
    IBOutlet UIButton *btnLeaderboard;
    IBOutlet UILabel *lbPlayerStats;
    IBOutlet UILabel *lbDuelsWon;
    IBOutlet UILabel *lbDuelsWonCount;
    IBOutlet UILabel *lbDuelsLost;
    IBOutlet UILabel *lbDuelsLostCount;
    IBOutlet UILabel *lbBiggestWin;
    IBOutlet UILabel *lbBiggestWinCount;
    IBOutlet UILabel *lbNotifyMessage;
    IBOutlet UILabel *lbLeaderboardTitle;
    IBOutlet UILabel *_lbMenuTitle;
    IBOutlet UILabel *lbSoundButtonText;
    
    //Buttons
    IBOutlet UIButton *_btnMusicContoller;
    
    IBOutlet UIView *ivBlack;

    NSNumberFormatter *numberFormatter;
        
    BOOL didDisappear;
}
@property (nonatomic) BOOL needAnimation;
@property (strong, nonatomic) IBOutlet UIView *ivBlack;


-(id)initWithAccount:(AccountDataSource *)userAccount startViewController:(StartViewController *)startViewController;
-(id)initForFirstRunWithLoginVC:(LoginViewController*) loginViewController Account:(AccountDataSource *)userAccount;

-(void)finishSwitchL;
-(int)nextElement:(int)elm;
-(int)previousElement:(int)elm;

-(void)clickLeftBtn;
-(void)sendRequestWithDonateSum:(int)sum;
-(void)postWin;
-(void)postMoneyWin;
-(void)postNewLVL; 

-(void)setImageFromFacebook;
-(void)refreshContentFromPlayerAccount;
-(void)checkLocationOfViewForFBLogin;
- (IBAction)btnFBLoginClick:(id)sender;
- (IBAction)btnFBLogOutClick:(id)sender;
- (IBAction)soundControll:(id)sender;
- (IBAction)btnLeaderbordClick:(id)sender ;

@end
