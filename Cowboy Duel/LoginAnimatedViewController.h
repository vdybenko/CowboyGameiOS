//
//  LoginAnimatedViewController.h
//  Cowboy Duels
//
//  Created by Sergey Sobol on 07.11.12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
#import "ProfileViewController.h"
#import "MKStoreManager.h"

typedef enum {
    LoginFacebookStatusNone,
    LoginFacebookStatusSimple,
    LoginFacebookStatusLevel,
    LoginFacebookStatusMoney,
    LoginFacebookStatusFeed,
    LoginFacebookStatusInvaitFriends
} LoginFacebookStatus;

@class StartViewController;
@interface LoginAnimatedViewController : UIViewController <FBSessionDelegate, FBDialogDelegate, UIWebViewDelegate, MKStoreKitDelegate, FBRequestDelegate>

@property (strong,nonatomic) Facebook *facebook;
@property (strong,nonatomic) StartViewController *startViewController;
@property (strong,nonatomic) id<ProfileWithLoginDelegate> delegate;
@property (nonatomic)  LoginFacebookStatus loginFacebookStatus;
@property (nonatomic) BOOL payment;

+ (LoginAnimatedViewController *) sharedInstance;
-(void)initFacebook;
-(IBAction)loginButtonClick:(id)sender;
-(void)logOutFB;
-(void)facebookiOS6DidLogin;

@end
