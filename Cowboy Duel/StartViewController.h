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
#import <StoreKit/StoreKit.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "AccountDataSource.h"
#import "ProfileViewController.h"
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
#import "revision.h"
#import "LoginAnimatedViewController.h"
#import "ActivityIndicatorView.h"
#import "CollectionAppViewController.h"
#import "RefreshContentDataController.h"
#import "UIImageView+AttachedView.h"
#import "TopPlayersDataSource.h"
#import "SSConnection.h"
#import "TestAppDelegate.h"

@class ListOfItemsViewController;
@class GameCenterViewController;

@interface StartViewController : UIViewController <MFMailComposeViewControllerDelegate,GCAuthenticateDelegate, UIAlertViewDelegate, FBRequestDelegate, GADBannerViewDelegate>

@property (nonatomic) BOOL showFeedAtFirst;
@property (strong, nonatomic) NSString *oldAccounId;
@property (nonatomic) BOOL soundCheack;
@property (nonatomic) BOOL feedBackViewVisible;
@property (strong, nonatomic) TopPlayersDataSource *topPlayersDataSource;


+ (StartViewController *)sharedInstance;
-(id)init;     //must be login object!!!
-(void)playerStop;
-(BOOL)connectedToWiFi;
-(void)profileButtonClick;
-(void)authorizationModifier:(BOOL)modifierName;
-(void)modifierUser:(AccountDataSource *)playerTemp;

-(float)abs:(float)d;

-(void)soundOff;

-(void)duelButtonClick;
-(IBAction)profileButtonClick;
-(void)profileButtonClickWithOutAnimation;
-(IBAction)startDuel;

-(IBAction)feedbackFacebookBtnClick:(id)sender;
-(IBAction)feedbackTweeterBtnClick:(id)sender;
-(IBAction)feedbackMailBtnClick:(id)sender;
-(IBAction)feedbackItuneskBtnClick:(id)sender;


-(void)didBecomeActive;
-(void)didEnterBackground;

@end
