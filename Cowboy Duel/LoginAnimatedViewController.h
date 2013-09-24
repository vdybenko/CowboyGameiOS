//
//  LoginAnimatedViewController.h
//  Bounty Hunter
//
//  Created by Sergey Sobol on 07.11.12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
#import "ProfileViewController.h"
#import "MKStoreManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Facebook.h"

typedef enum {
    LoginFacebookStatusNone,
    LoginFacebookStatusSimple,
    LoginFacebookStatusLevel,
    LoginFacebookStatusMoney,
    LoginFacebookStatusFeed,
    LoginFacebookStatusInvaitFriends,
    LoginFacebookStatusProfile
} LoginFacebookStatus;

@class StartViewController;
@interface LoginAnimatedViewController : UIViewController <UIWebViewDelegate, MKStoreKitDelegate>

@property (strong,nonatomic) id<ProfileWithLoginDelegate> delegate;
@property (nonatomic)  LoginFacebookStatus loginFacebookStatus;
@property (nonatomic) BOOL payment;
@property (nonatomic) BOOL isDemoPractice;
@property (weak) id<FBRequestDelegate> delegateFacebook;

+ (LoginAnimatedViewController *) sharedInstance;
-(void)initFacebook;
-(IBAction)loginButtonClick:(id)sender;
-(void)logOutFB;
- (void)fbDidLogin;
-(void)fbDidLogout;
-(void)failed;

@end
