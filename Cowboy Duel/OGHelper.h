//
//  GCHelper.h
//  CatRace
//
//  Created by Ray Wenderlich on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import <CoreLocation/CoreLocation.h>
#import "StartViewController.h"

#define NAME_SPACE_APP "bidon_duels"

#define kReceiveImagefromFBNotification @"ImagefromFB"
#define kCheckfFBLoginSession @"SessionAction"
#define kFBFeed @"feedAction"
#define URL_FB_PICTURE @"http://bidoncd.s3.amazonaws.com/app_icon_share.png"
#define URL_APP_SHARE @"http://cowboyduel.mobi/"

@protocol ProtocolForDelegate <NSObject>

-(void)userPermissions;

@end

@class AccountDataSource;

typedef enum apiCall {
    kNone,
    kParseByURL,
    kAPILogin,
    kAPILogout,
    kAPIGraphUserPermissionsDelete,
    kDialogPermissionsExtended,
    kDialogRequestsSendToMany,
    kAPIGetAppUsersFriendsNotUsing,
    kAPIGetAppUsersFriendsUsing,
    kAPIFriendsForDialogRequests,
    kDialogRequestsSendToSelect,
    kAPIFriendsForTargetDialogRequests,
    kDialogRequestsSendToTarget,
    kDialogFeedUser,
    kAPIFriendsForDialogFeed,
    kAPIFriendsCount,
    kAPIFriendsHowDontUseApp,
    kDialogFeedFriend,
    kAPIGraphUserPermissions,
    kAPIGraphMe,
    kAPIGraphPictureGet,
    kAPIGraphUserFriends,
    kDialogPermissionsCheckin,
    kDialogPermissionsCheckinForRecent,
    kDialogPermissionsCheckinForPlaces,
    kAPIGraphSearchPlace,
    kAPIGraphUserCheckins,
    kAPIGraphUserPhotosPost,
    kAPIGraphUserVideosPost,
    kAPIGraphScoreGet,
    kAPIGraphScorePost,
    kAPIGraphAchivAPPCreate,
    kAPIGraphAchivAPPGet,
    kAPIGraphAchivAPPDelete,
    kAPIGraphAchivGet,
    kAPIGraphAchivPost,
    kAPIGraphCustomActionPost,
    kAPIGraphCustomActionGet,
    kAPIGraphCustomActionUpdate
} apiCall;

typedef enum typeOfFBImage {
    typeOfFBImageSquare,
    typeOfFBImageSmall,
    typeOfFBImageNormal,
    typeOfFBImageLarge
} typeOfFBImage;

@interface OGHelper : NSObject<FBDialogDelegate>
@property (strong,retain) id delegate;
@property (strong,retain) AccountDataSource *playerAccount;
@property (nonatomic, retain) NSMutableArray *savedAPIResult;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *mostRecentLocation;

static NSString *getOpenGraphSavePath() ;
+ (OGHelper *)sharedInstance;
- (id)initWithAccount:(AccountDataSource *)userAccount;
- (void)createControllsWithAccount:(AccountDataSource *)userAccount;
- (BOOL)isAuthorized;
- (void)apiLogout;
- (NSString *)getOpenGraphSavePath;
- (NSString *)getSavePathForList;

- (NSString *)getClearName:(NSString*) pName;

- (void)apiDialogRequestsSendToNonUsers:(NSArray *)selectIDs;
- (void)apiDialogRequestsSendTarget:(NSString *)friend;
- (void)getAppUsersFriendsNotUsing;
- (void)getCountOfUserFriends;
- (NSUInteger)getCountOfUserFriendsRequest:(FBRequest *)request didLoad:(id)result;
-(void) apiRESTGetAppUsers;
- (void)getFriendsHowDontUseAppDelegate:(__weak id<FBRequestDelegate>)delegate;
- (__autoreleasing NSArray *)getFriendsHowDontUseAppRequest:(FBRequest *)request didLoad:(id)result;


- (void)apiDialogFeedUser;
- (void)publishPostOnFeed;
- (void)apiGraphScoreGet;
- (void)apiGraphScorePost:(int)num ;
- (void)apiGraphAchivAPPCreate:(NSString*)achivmentURL ;
- (void)apiGraphAchivAPPGet ;
- (void)apiGraphAchivAPPDelete:(NSString*)achivmentURL ;

- (void)apiGraphAchivGet;
- (void)apiGraphAchivPost:(NSString*)achivmentURL;

- (void)getAppUsersFriendsNotUsing;
- (void)apiDialogRequestsSendToMany;
- (void)apiGraphCustomActionPost:(NSString*)objectURL actionTypeName:(NSString*)actionTypeName objectTypeName:(NSString*)objectTypeName;
- (void)apiGraphCustomActionGet:(NSString *)objectID ;
- (void)apiGraphCustomActionUpdate:(NSString *)objectID;
-(NSString *)apiGraphGetImage:(NSString *)URL;
-(void)apiGraphGetImageForList:(NSString *)URL didFinishBlock:(void (^)(UIImage*)) finishBlock;
-(void)apiGraphGetImage:(NSString *)URL didFinishBlock:(void (^)(UIImage*)) finishBlock imageType:(typeOfFBImage)type;

- (void)apiGraphMe;
-(void) showMessage:(NSString *)message;

@end
