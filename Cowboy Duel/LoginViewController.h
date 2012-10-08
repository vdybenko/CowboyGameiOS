//
//  LoginViewController.h
//  Cowboy Duel 1
//
//  Created by Sergey Sobol on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
//#import "OpenFeint+UserOptions.h"
#import "FBConnect.h"
#import "ProfileViewController.h"
#import "GameCenterViewController.h"

typedef enum {
    LoginFacebookStatusNone,
    LoginFacebookStatusSimple,
    LoginFacebookStatusLevel,
    LoginFacebookStatusMoney,
    LoginFacebookStatusFeed,
    LoginFacebookStatusInvaitFriends
} LoginFacebookStatus;

@class StartViewController;
@interface LoginViewController : UIViewController <FBSessionDelegate, FBDialogDelegate, UIWebViewDelegate>
{
    StartViewController * startViewController;
    Facebook *facebook;
    AccountDataSource *playerAccount;
    IBOutlet UIView *view;
//    IBOutlet UIImageView *boardBackground;
    IBOutlet UILabel *congLabel;
    IBOutlet UILabel *loginBtnTitle;
    IBOutlet UILabel *nextTimeBtnTitle;
//    IBOutlet UILabel *achievTellFriendsBtnTitle;
//    IBOutlet UILabel *achievNextTimeBtnTitle;
//    IBOutlet UIView *achievMainView;
    IBOutlet UIView *mainLoginView;
   
//    IBOutlet UIWebView *webMesView;
    
    IBOutlet UIButton *_btnFBLogin;
    IBOutlet UIButton *_btnNextTime;
    IBOutlet UIWebView *link;
    
    GameCenterViewController *gameCenterViewController;
    LoginFacebookStatus loginFacebookStatus;
}

@property (strong,nonatomic) Facebook *facebook;
@property (strong,nonatomic) StartViewController *startViewController;
@property (strong,nonatomic) id<ProfileWithLoginDelegate> delegate;
@property (nonatomic)  LoginFacebookStatus loginFacebookStatus;


+ (LoginViewController *) sharedInstance ;
-(IBAction)fbLoginBtnClick:(id)sender;
-(IBAction)scipLoginBtnClick:(id)sender;

-(void)logOutFB;

@end
