//
//  ProfileViewController.h
//  Test
//
//  Created by Sobol on 11.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountDataSource.h"
#import "SSServer.h"
#import "CDFavPlayer.h"

@class LoginAnimatedViewController;
@class StartViewController;

#define kFbUserNameKey @"fbUserName"
#define kFbUserIdKey @"fbUserId"

typedef enum {
    ProfileViewControllerInitSimple,
    ProfileViewControllerInitFirstStart,
    ProfileViewControllerInitOpponent,
    ProfileViewControllerInitFavorite
} ProfileViewControllerInit;

@protocol  ProfileWithLoginDelegate <NSObject>
@optional
-(void)skipLoginFB;
-(void)loginToFB;
@end

@interface ProfileViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate,ProfileWithLoginDelegate,MemoryManagement>
@property (nonatomic) BOOL needAnimation;
@property (weak, nonatomic) IBOutlet UIView *ivBlack;
@property (weak, nonatomic) IBOutlet UILabel *addFaforitesLb;
@property (weak, nonatomic) IBOutlet UITextField *tfFBName;

@property IBOutlet UIImageView *profilePictureViewDefault;

-(id)initWithAccount:(AccountDataSource *)userAccount;
-(id)initFirstStartWithAccount:(AccountDataSource *)userAccount;
-(id)initForOponent:(AccountDataSource *)oponentAccount andOpponentServer:(SSServer *)server;
-(id)initForFavourite:(CDFavPlayer *)favPlayer withAccount:(AccountDataSource *)oponentAccount;


-(void)checkValidBlackActivity;
-(void)checkLocationOfViewForFBLogin;
- (IBAction)duelButtonClick:(id)sender;
-(void)startVisualLoading;
@end
