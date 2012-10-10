//
//  StartViewController.h
//  Test
//
//  Created by Sobol on 20.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>

#import "AccountDataSource.h"
//#import "BluetoothViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "ProfileViewController.h"
//#import <GameKit/GameKit.h>
//#import "MessageViewController.h"
#import "DuelViewController.h"
#import "TeachingViewController.h"
#import "HelpViewController.h"
#import "GCHelper.h"
#import "OGHelper.h"
#import "Reachability.h"
#import "ValidationUtils.h"
#import "JSON.h"
#import "CDTransaction.h"
#import "CDDuel.h"
#import "CDAchivment.h"
#import "ActivityIndicatorView.h"
#import <StoreKit/StoreKit.h>
#import "revision.h"
#import "LoginViewController.h"
//#import "OpenFeint+UserOptions.h"
#import "ActivityIndicatorView.h"
#import "CollectionAppViewController.h"
#import "RefreshContentDataController.h"
#import "UIImageView+AttachedView.h"
#import "TopPlayersDataSource.h"

@class ListOfItemsViewController;
@class GameCenterViewController;
//#define btnFBId @"http://m.facebook.com/profile.php?id=217230251641433"

@interface StartViewController : UIViewController <MFMailComposeViewControllerDelegate,GCAuthenticateDelegate, UIAccelerometerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, FBRequestDelegate> {
    AccountDataSource *playerAccount;
    AccountDataSource *oponentAccount;
//    BluetoothViewController *bluetoothViewController;
    ActivityIndicatorView *activityIndicatorView;
    ActivityIndicatorView *activityIndicatorView2;
    CollectionAppViewController *collectionAppViewController;
    ListOfItemsViewController *listOfItemsViewController;
    ProfileViewController *profileViewController;
    
    TopPlayersDataSource *topPlayersDataSource;
    
    NSTimer *avtorizationTimer;
    
        
    UIView *hudView;
    UIView *hudView1;
    
    BOOL firstRun;
    BOOL firstRunLocal;
    BOOL checkNewVer;
    BOOL firstDayWithOutAdvertising;
    
    AVAudioPlayer *player;
    NSString *pathFile;
    
    UIAlertView *baseAlert;
    UIView *v10DolarsForDay;
        
    float globalAngle;
    BOOL soundCheack;
    BOOL avtorisationCheck;
    BOOL animationCheck;
    BOOL checkGameCenter;
    
    BOOL firstRunController;
    
    BOOL inBackground;
    
    BOOL avtorizationInProcess;
    
    BOOL internetActive;
    BOOL hostActive;
    BOOL viewIsVisible;

    BOOL feedBackViewVisible;
    
    Reachability* internetReachable;
    Reachability* hostReachable;
    Facebook *facebook;
    
    
    NSDictionary *pushNotification;
    NSMutableString *stDonate;
    
    UIImageView_AttachedView *arrowImage;

    int arrowDirection;
    int arrowXlimitMin;
    int arrowXlimitMax;
        
    NSString *oldAccounId;
    LoginViewController *loginViewController;
    
    NSMutableDictionary *dicForRequests;
    BOOL modifierName;
    //buttons
    IBOutlet UIButton *teachingButton;
    IBOutlet UIButton *duelButton;
    IBOutlet UIButton *mapButton;
    IBOutlet UIButton *profileButton;
    IBOutlet UIButton *feedbackButton;
    IBOutlet UIButton *helpButton;
    
    IBOutlet UIView *_vBackground;
    IBOutlet UIView *feedbackView;
    
    IBOutlet UIImageView *backGroundfeedbackView;
    IBOutlet UIActivityIndicatorView *indicatorfeedbackView;

    
    IBOutlet UILabel *lbPostMessage;
    IBOutlet UILabel *lbMailMessage;
    IBOutlet UILabel *lbRateMessage;
    IBOutlet UILabel *lbFeedbackCancelBtn;
    __unsafe_unretained IBOutlet UIView *dayliMoneyView;
    __unsafe_unretained IBOutlet UIWebView *dayliMoneyText;
    __unsafe_unretained IBOutlet UIButton *dayliOkButton;
    
    
}

@property (strong, nonatomic) IBOutlet UIButton *teachingButton;
@property (strong, nonatomic) IBOutlet UIButton *duelButton;
@property (strong, nonatomic) IBOutlet UIButton *mapButton;
@property (strong, nonatomic) IBOutlet UIButton *helpButton;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (strong, nonatomic) IBOutlet UIButton *feedbackButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorfeedbackView;
@property (strong, nonatomic) IBOutlet UIImageView *backGroundfeedbackView;
@property (strong, nonatomic) IBOutlet UIView *_vBackground;

@property (strong, nonatomic) NSString *oldAccounId;

@property (strong) GameCenterViewController *gameCenterViewController;
@property (strong, nonatomic) TopPlayersDataSource *topPlayersDataSource;


@property (strong,nonatomic) AVAudioPlayer *player;

@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL hostActive;
@property (nonatomic) BOOL soundCheack;
@property (nonatomic) BOOL feedBackViewVisible;
@property (nonatomic) BOOL showFeedAtFirst;

@property (strong) LoginViewController *loginViewController;

+ (StartViewController *)sharedInstance;
-(id)init;     //must be login object!!!
-(void)playerStart;
-(void)playerStop;
-(bool)connectedToWiFi;
-(void)profileButtonClick;
-(void)authorizationModifier:(BOOL)modifierName;
-(void)modifierUser;


-(float)abs:(float)d;

-(void)showProfile;
-(void)logout;
-(void)login;
-(void)requestProductData;
-(void)avtorizationFailed;

- (void) checkNetworkStatus:(NSNotification *)notice;

-(void)volumeDec:(NSNumber *)level;
-(void)volumeInc;
-(void)soundOff;
-(void)playerHalf;

-(void)duelButtonClick;
-(IBAction)showHelp:(id)sender;
-(IBAction)mapButtonClick;
-(IBAction)profileButtonClick;
-(void)profileButtonClickWithOutAnimation;
-(IBAction)teachingButtonClick;
-(IBAction)fbButtonClick:(id)sender;
-(IBAction)startDuel;
-(IBAction)feedbackButtonClick:(id)sender;
- (IBAction)feedbackCancelButtonClick:(id)sender;

- (IBAction)feedbackFacebookBtnClick:(id)sender;
- (IBAction)feedbackTweeterBtnClick:(id)sender;
- (IBAction)feedbackMailBtnClick:(id)sender;
- (IBAction)feedbackItuneskBtnClick:(id)sender;

-(void) advertButtonClick;

-(NSString *)deviceType;

-(void)didBecomeActive;
-(void)didEnterBackground;

@end
