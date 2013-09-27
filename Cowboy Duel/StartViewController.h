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
#import "DuelProductDownloaderController.h"
#import "FavouritesDataSource.h"

@class ListOfItemsViewController;
@class GameCenterViewController;

typedef enum{
    PUSH_NOTIFICATION_POKE,
    PUSH_NOTIFICATION_FAV_ONLINE,
    PUSH_NOTIFICATION_UPDATE_CONTENT,
    PUSH_NOTIFICATION_UPDATE_PRODUCTS
} TypeOfPushNotification;

@interface StartViewController : UIViewController <MFMailComposeViewControllerDelegate,GCAuthenticateDelegate, UIAlertViewDelegate, FBRequestDelegate,DuelProductDownloaderControllerDelegate>

@property (nonatomic) BOOL showFeedAtFirst;
@property (strong, nonatomic) NSString *oldAccounId;
@property (nonatomic) BOOL soundCheack;
@property (nonatomic) BOOL feedBackViewVisible;
@property (strong, nonatomic) TopPlayersDataSource *topPlayersDataSource;
@property (strong, nonatomic) FavouritesDataSource *favsDataSource;
@property (strong, nonatomic) DuelProductDownloaderController *duelProductDownloaderController;
@property (nonatomic) BOOL firstRun;
@property (strong,nonatomic)  NSDictionary *pushNotification;

+ (StartViewController *)sharedInstance;
-(id)init;     //must be login object!!!
-(void)playerStop;
-(void)playerStart;
-(BOOL)connectedToWiFi;
-(void)checkNetworkStatus:(NSNotification *)notice;
-(void)authorizationModifier:(BOOL)modifierName;
-(void)modifierUser:(AccountDataSource *)playerTemp;
-(void)sendMessageForPush:(NSString *)message withType:(TypeOfPushNotification)type fromPlayer:(NSString *)nick withId:(NSString *)playerId ;

-(void)soundOff;

-(void)duelButtonClick;
-(IBAction)profileButtonClick;
-(void)profileFirstRunButtonClickWithOutAnimation;
-(IBAction)startDuel;

-(IBAction)feedbackFacebookBtnClick:(id)sender;
-(IBAction)feedbackTweeterBtnClick:(id)sender;
-(IBAction)feedbackMailBtnClick:(id)sender;
-(IBAction)feedbackItuneskBtnClick:(id)sender;

- (IBAction)clickLogin:(id)sender;

-(void)didBecomeActive;
-(void)didEnterBackground;

-(void)favoritesDownloadListAfterAvtorization;

-(void)releseProfileSmallWindow;

@end
