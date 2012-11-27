//
//  ProfileViewController.h
//  Test
//
//  Created by Sobol on 11.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountDataSource.h"

@class LoginAnimatedViewController;
@class StartViewController;

#define kFbUserNameKey @"fbUserName"
#define kFbUserIdKey @"fbUserId"

@protocol  ProfileWithLoginDelegate <NSObject>
@optional
-(void)skipLoginFB;
-(void)loginToFB;
@end

@interface ProfileViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate,ProfileWithLoginDelegate>@property (nonatomic) BOOL needAnimation;
@property (strong, nonatomic) IBOutlet UIView *ivBlack;

-(id)initWithAccount:(AccountDataSource *)userAccount startViewController:(StartViewController *)startViewController;
-(id)initFirstStartWithAccount:(AccountDataSource *)userAccount startViewController:(StartViewController *)startViewController;

-(void)checkValidBlackActivity;
-(void)checkLocationOfViewForFBLogin;

@end
