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

@class LoginAnimatedViewController;
@class StartViewController;

#define kFbUserNameKey @"fbUserName"
#define kFbUserIdKey @"fbUserId"

@protocol  ProfileWithLoginDelegate <NSObject>
@optional
-(void)skipLoginFB;
-(void)loginToFB;
@end

@interface ProfileViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate,ProfileWithLoginDelegate,MemoryManagement>
@property (nonatomic) BOOL needAnimation;
@property (weak, nonatomic) IBOutlet UIView *ivBlack;

-(id)initWithAccount:(AccountDataSource *)userAccount startViewController:(StartViewController *)startViewController;
-(id)initFirstStartWithAccount:(AccountDataSource *)userAccount startViewController:(StartViewController *)startViewController;
-(id)initForOponent:(AccountDataSource *)oponentAccount andOpponentServer:(SSServer *)server;

-(void)checkValidBlackActivity;
-(void)checkLocationOfViewForFBLogin;
- (IBAction)duelButtonClick:(id)sender;

@end
