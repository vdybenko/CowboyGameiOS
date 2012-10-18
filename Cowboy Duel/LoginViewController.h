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
#import "FBConnect.h"
#import "ProfileViewController.h"

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

@property (strong,nonatomic) Facebook *facebook;
@property (strong,nonatomic) StartViewController *startViewController;
@property (strong,nonatomic) id<ProfileWithLoginDelegate> delegate;
@property (nonatomic)  LoginFacebookStatus loginFacebookStatus;

+ (LoginViewController *) sharedInstance ;
-(void)initFacebook;
-(IBAction)fbLoginBtnClick:(id)sender;
-(void)logOutFB;

@end
