//
//  GCHelper.m
//  CatRace
//
//  Created by Ray Wenderlich on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OGHelper.h"
#import "AccountDataSource.h"


static const char *DONATE_URL = BASE_URL"api/time";

@interface OGHelper()
{
    AccountDataSource * playerAccount;
    
    int currentAPICall;
    
    NSMutableArray *savedAPIResult;
    CLLocationManager *locationManager;
    CLLocation *mostRecentLocation;
}
@end

@implementation OGHelper;

@synthesize playerAccount,delegate;
@synthesize savedAPIResult;
@synthesize locationManager;
@synthesize mostRecentLocation;

//--------------------------------------------------------  
// Authentication  
//--------------------------------------------------------  

static NSString *getOpenGraphSavePath()  
{  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    return [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]];  
}  

static NSString *getSavePathForList()  
{  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *pathToDirectory=[NSString stringWithFormat:@"%@/savedImage",[paths objectAtIndex:0]]; 
    return pathToDirectory; 
}  

#pragma mark - Initialization

static OGHelper *sharedHelper = nil;
+ (OGHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[OGHelper alloc] init];
    }
    return sharedHelper;
}

- (id)initWithAccount:(AccountDataSource *)userAccount
{
    if (self == [super init]) {   
        [self createControllsWithAccount:userAccount];
    }
    return self;
}

-(void)createControllsWithAccount:(AccountDataSource *)userAccount
{
    playerAccount=userAccount;
    delegate=NULL;
    currentAPICall=kNone;
}

- (BOOL)isAuthorized;
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"]) {
        return YES;
    }else {
        return NO;
    }
}

-(NSString *)getOpenGraphSavePath{
    return getOpenGraphSavePath();
}

-(NSString *)getSavePathForList{
    return getSavePathForList();
}

-(NSString *)getClearName:(NSString*) pName{
    if (pName &&([pName length]>=2)) {
        NSMutableString *tfContent = [[NSMutableString alloc] initWithString:pName];
        NSRange rng=NSMakeRange (0,2);
        [tfContent deleteCharactersInRange:rng];
        return tfContent;
    }else {
        return pName;
    }
}
//#pragma mark Facebook API Calls
///*
// * Graph API: Method to get the user's friends.
// */
//- (void)apiGraphFriends {
////    [delegate showActivityIndicator];
//    // Do not set current API as this is commonly called by other methods
//    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
//}
//
///*
// * Graph API: Method to get the user's permissions for this app.
// */
//- (void)apiGraphUserPermissions {
////    [delegate showActivityIndicator];
//    currentAPICall = kAPIGraphUserPermissions;
//    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [facebook requestWithGraphPath:@"me/permissions" andDelegate:self];
//}
//
///*
// * Dialog: Authorization to grant the app check-in permissions.
// */
//- (void)apiPromptCheckinPermissions {
//    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSArray *checkinPermissions = [[NSArray alloc] initWithObjects:@"user_checkins", @"publish_checkins", nil];
//    facebook.sessionDelegate = self;
////    [facebook authorize:checkinPermissions];
////    [checkinPermissions release];
//}
//
//#pragma mark Login and Permissions
//
///*
// * --------------------------------------------------------------------------
// * Login and Permissions
// * --------------------------------------------------------------------------
// */
//
//
//
///*
// * iOS SDK method that handles the logout API call and flow.
// */
//- (void)apiLogin {
//    currentAPICall = kAPILogin;
//    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [facebook logout:self];
//}
//
//- (void)apiLogout {
//    currentAPICall = kAPILogout;
//    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [facebook logout:self];
//}
//
///*
// * Graph API: App unauthorize
// */
//- (void)apiGraphUserPermissionsDelete {
////    [delegate showActivityIndicator];
//    currentAPICall = kAPIGraphUserPermissionsDelete;
//    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    // Passing empty (no) parameters unauthorizes the entire app. To revoke individual permissions
//    // add a permission parameter with the name of the permission to revoke.
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
//    [facebook requestWithGraphPath:@"me/permissions"
//                         andParams:params
//                     andHttpMethod:@"DELETE"
//                       andDelegate:self];
//}
//
///*
// * Dialog: Authorization to grant the app user_likes permission.
// */
//- (void)apiPromptExtendedPermissions {
//    currentAPICall = kDialogPermissionsExtended;
//    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSArray *extendedPermissions = [[NSArray alloc] initWithObjects:@"user_likes", nil];
//    facebook.sessionDelegate = self;
////    [facebook authorize:extendedPermissions];
////    [extendedPermissions release];
//}
//
//#pragma mark News Feed
//
///**
// * --------------------------------------------------------------------------
// * News Feed
// * --------------------------------------------------------------------------
// */
//
///*
// * Dialog: Feed for the user
// */
- (void)apiDialogFeedUser;
{
    currentAPICall = kDialogFeedUser;
//    SBJSON *jsonWriter = [SBJSON new];
    
//    // The action links to be shown with the post in the feed
//    NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                      @"Get Started",@"name",@"http://apps.facebook.com/bidon_duels/?fb_source=timeline_og&fb_action_ids=358930200845338&fb_action_types=bidon_duels%3Aget",@"link", nil], nil];
//    NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
    // Dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   kFacebookAppId, @"app_id",
                                   @"Get Started", @"message",
                                   URL_APP_ESTIMATE, @"link",
                                   UIImagePNGRepresentation([UIImage imageNamed:@"icon@2x.png"]), @"picture",
                                   
                                   nil];
//    NSMutableDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//     @"Get Started",@"name",@"http://apps.facebook.com/bidon_duels/?fb_source=timeline_og&fb_action_ids=358930200845338&fb_action_types=bidon_duels%3Aget",@"link", nil];
//    
//
//    facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
//    [facebook dialog:@"feed"
//           andParams:params
//         andDelegate:self];
    id<FBGraphObject> graphObject = (id<FBGraphObject>)[FBGraphObject graphObjectWrappingDictionary:params];
    
    
    [FBRequestConnection startForPostWithGraphPath:@"me/feed" graphObject:graphObject completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
        [[NSNotificationCenter defaultCenter] postNotificationName: kFBFeed
                                                                         object:self
                                                                       userInfo:nil];
        
        if (error)
        {
            //showing an alert for failure
            UIAlertView *alertView = [[UIAlertView alloc]  initWithTitle:@"Facebook" message:error.localizedDescription                                                                                                delegate:nil   cancelButtonTitle:@"OK"              otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            //showing an alert for success
            UIAlertView *alertView = [[UIAlertView alloc]  initWithTitle:@"Facebook" message:@"Shared the photo successfully"                                                                                                delegate:nil   cancelButtonTitle:@"OK"              otherButtonTitles:nil];
            [alertView show];
        }
    }];
    
//    [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_stream"]
//                                               defaultAudience:FBSessionDefaultAudienceFriends
//                                             completionHandler:^(FBSession *session, NSError *error)
//     {
//         // If permissions granted, publish the story
//         NSData* imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"icon.png"], 90);
//         NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                         @"This is my drawing!", @"message",
//                                         imageData, @"source",
//                                         nil];
//         
//         [FBRequestConnection startWithGraphPath:@"me/photos"
//                                      parameters:params
//                                      HTTPMethod:@"POST"
//                               completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                   
//                               }];
//
//     }];
//        // Second request retrieves photo information for just-created
//    // photo so we can grab its source.
////    FBRequest *request2 = [FBRequest
////                           requestForGraphPath:@"{result=photopost:$.id}"];
////    [FBRequestConnection addRequest:request2
////         completionHandler:
//    
//     [FBRequestConnection startWithGraphPath:@"{result=photopost:$.id}"
//                                  parameters:nil
//                                  HTTPMethod:@"GET"
//                           completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//             if (!error && result) {
//                 NSString *photoID = [result objectForKey:@"id"];
//                 NSMutableDictionary *params = [NSMutableDictionary dictionary];
//                 [params setObject:@"I'm totally posting on my own wall!" forKey:@"message"];
//                 
//                 if(photoID) {
//                     [params setObject:photoID forKey:@"object_attachment"];
//                 }
//                 
//                 [FBRequestConnection startForPostWithGraphPath:@"me/feed"
//                                          graphObject:[NSDictionary dictionaryWithDictionary:params]
//                                    completionHandler:
//                  ^(FBRequestConnection *connection, id result, NSError *error) {
//                      if (!error) {
//                          [[[UIAlertView alloc] initWithTitle:@"Result"
//                                                      message:@"Your update has been posted to Facebook!"
//                                                     delegate:self
//                                            cancelButtonTitle:@"Sweet!"
//                                            otherButtonTitles:nil] show];
//                      } else {
//                          [[[UIAlertView alloc] initWithTitle:@"Error"
//                                                      message:@"Yikes! Facebook had an error.  Please try again!"
//                                                     delegate:nil 
//                                            cancelButtonTitle:@"Ok" 
//                                            otherButtonTitles:nil] show]; 
//                      }
//                  }
//                  ];
//             }
//         }
//     ];
    
}



///*
// * Helper method to first get the user's friends then
// * pick one friend and post on their wall.
// */
//- (void)getFriendsCallAPIDialogFeed {
//    // Call the friends API first, then set up for targeted Feed Dialog
//    currentAPICall = kAPIFriendsForDialogFeed;
//    [self apiGraphFriends];
//}
//
///*
// * Dialog: Feed for friend
// */
//- (void)apiDialogFeedFriend:(NSString *)friendID {
//    currentAPICall = kDialogFeedFriend;
//    SBJSON *jsonWriter = [SBJSON new];
//    
//    NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                      @"Get Started",@"name",@"http://m.facebook.com/apps/hackbookios/",@"link", nil], nil];
//    NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
//    // The "to" parameter targets the post to a friend
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   friendID, @"to",
//                                   @"I'm using the Hackbook for iOS app", @"name",
//                                   @"Hackbook for iOS.", @"caption",
//                                   @"Check out Hackbook for iOS to learn how you can make your iOS apps social using Facebook Platform.", @"description",
//                                   @"http://m.facebook.com/apps/hackbookios/", @"link",
//                                   @"http://www.facebookmobileweb.com/hackbook/img/facebook_icon_large.png", @"picture",
//                                   actionLinksStr, @"actions",
//                                   nil];
//    
//    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [facebook dialog:@"feed"
//           andParams:params
//         andDelegate:self];
//    
//}
//#pragma mark Requests
///*
// * --------------------------------------------------------------------------
// * Requests
// * --------------------------------------------------------------------------
// */
//
///*
// * Dialog: Requests - send to all.
// */
//- (void)apiDialogRequestsSendToMany {
//    currentAPICall = kDialogRequestsSendToMany;
//    SBJSON *jsonWriter = [SBJSON new];
//    NSDictionary *gift = [NSDictionary dictionaryWithObjectsAndKeys:
//                          @"5", @"social_karma",
//                          @"1", @"badge_of_awesomeness",
//                          nil];
//    
//    NSString *giftStr = [jsonWriter stringWithObject:gift];
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   @"Learn how to make your iOS apps social.",  @"message",
//                                   @"Check this out", @"notification_text",
//                                   giftStr, @"data",
//                                   nil];
//    
//    facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
//    [facebook dialog:@"apprequests"
//           andParams:params
//         andDelegate:self];
//}
//
///*
// * API: Legacy REST for getting the friends using the app. This is a helper method
// * being used to target app requests in follow-on examples.
// */
//- (void)apiRESTGetAppUsers {
////    [delegate showActivityIndicator];
//    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   @"friends.getAppUsers", @"method",
//                                   nil];
//    [facebook requestWithParams:params
//                    andDelegate:self];
//}
//
///*
// * Dialog: Requests - send to friends not currently using the app.
// */
//- (void)apiDialogRequestsSendToNonUsers:(NSArray *)selectIDs {
//    currentAPICall = kDialogRequestsSendToSelect;
//    NSString *selectIDsStr = [selectIDs componentsJoinedByString:@","];
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   NSLocalizedString(@"INVITE_FRIENDS", @""),  @"message",
//                                   selectIDsStr, @"suggestions",
//                                   nil];
//    
//    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [facebook dialog:@"apprequests"
//           andParams:params
//         andDelegate:self];
//}
//
///*
// * Dialog: Requests - send to select users, in this case friends
// * that are currently using the app.
// */
//- (void)apiDialogRequestsSendToUsers:(NSArray *)selectIDs {
//    currentAPICall = kDialogRequestsSendToSelect;
//    NSString *selectIDsStr = [selectIDs componentsJoinedByString:@","];
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   @"It's your turn to visit the Hackbook for iOS app.",  @"message",
//                                   selectIDsStr, @"suggestions",
//                                   nil];
//    
//    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [facebook dialog:@"apprequests"
//           andParams:params
//         andDelegate:self];
//}
//
///*
// * Dialog: Request - send to a targeted friend.
// */
//- (void)apiDialogRequestsSendTarget:(NSString *)friend {
//    currentAPICall = kDialogRequestsSendToTarget;
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   @"Learn how to make your iOS apps social.",  @"message",
//                                   friend, @"to",
//                                   nil];
//    
//    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [facebook dialog:@"apprequests"
//           andParams:params
//         andDelegate:self];
//}
//
///*
// * Helper method to get friends using the app which will in turn
// * send a request to NON users.
// */
//- (void)getAppUsersFriendsNotUsing {
//    currentAPICall = kAPIGetAppUsersFriendsNotUsing;
//    facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
//    [self apiRESTGetAppUsers];
//}
//
///*
// * Helper method to get friends using the app which will in turn
// * send a request to current app users.
// */
//- (void)getAppUsersFriendsUsing {
//    currentAPICall = kAPIGetAppUsersFriendsUsing;
//    [self apiRESTGetAppUsers];
//}
//
///*
// * Helper method to get the users friends which will in turn
// * pick one to send a request.
// */
//- (void)getUserFriendTargetDialogRequest {
//    currentAPICall = kAPIFriendsForTargetDialogRequests;
//    [self apiGraphFriends];
//}
//
////count of user friends
//- (void)getCountOfUserFriends;
//{
//    currentAPICall = kAPIFriendsCount;
//    facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
//    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                    @"SELECT friend_count FROM user WHERE uid=me()", @"query",
//                                    nil];
//    [facebook   requestWithMethodName: @"fql.query"
//                            andParams: params
//                        andHttpMethod: @"GET"
//                          andDelegate: self];
//}
//
//- (NSUInteger)getCountOfUserFriendsRequest:(FBRequest *)request didLoad:(id)result;
//{
//    int countOfFriends = [[result objectForKey:@"friend_count"] integerValue];
//    [[AccountDataSource sharedInstance] setFriends:countOfFriends];
//    [[AccountDataSource sharedInstance] saveFriends];
//}
//- (void)getFriendsHowDontUseAppDelegate:(id<FBRequestDelegate>)pDelegate;
//{
//    currentAPICall = kAPIFriendsHowDontUseApp;
//    facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
//    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                    @"SELECT uid,devices FROM user WHERE uid IN ( SELECT uid2 FROM friend WHERE uid1 = me()) AND is_app_user = 0 ORDER BY rand()", @"query",
//                                    nil];
//    if (!pDelegate) {
//        pDelegate = self;
//    }
//    [facebook   requestWithMethodName: @"fql.query"
//                            andParams: params
//                        andHttpMethod: @"GET"
//                          andDelegate: pDelegate];
//}
//- (__autoreleasing NSArray *)getFriendsHowDontUseAppRequest:(FBRequest *)request didLoad:(id)result;
//{
//    NSArray  * arrResult =ValidateObject(result, [NSArray class]);
//    __autoreleasing NSMutableArray *friendToInvait = [NSMutableArray array];
//    for (NSDictionary *dic in arrResult) {
//        NSArray *arrDevises = [dic objectForKey:@"devices"];
//        if ([arrDevises count]==0) {
////            [friendToInvait addObject:[dic objectForKey:@"uid"]];
//        }else{
//            NSDictionary *dicOS=[arrDevises objectAtIndex:0];
//            NSString *userDeviseOS = [dicOS objectForKey:@"os"];
//            if ([userDeviseOS isEqualToString:@"iOS"]) {
//                [friendToInvait insertObject:[dic objectForKey:@"uid"] atIndex:0];
//            }
//        }
//        
//    }
//    return friendToInvait;
//}

#pragma mark Graph API

/*
 * --------------------------------------------------------------------------
 * Graph API
 * --------------------------------------------------------------------------
 */

/*
 * Graph API: Get the user's basic information, picking the name and picture fields.
 */
- (void)apiGraphMe {
//    [delegate showActivityIndicator];
    currentAPICall = kAPIGraphMe;
    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   @"name,picture",  @"fields",
//                                   nil];
//    [facebook requestWithGraphPath:@"me" andParams:params andDelegate:self];
    
    [FBRequestConnection startWithGraphPath:@"me" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];
}

-(NSString *)apiGraphGetImage:(NSString *)URL{
    
    NSString *path=[NSString stringWithFormat:@"%@/%@.png",getOpenGraphSavePath(),URL];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){  
        return path;
    }else{
        if ([self isAuthorized]&&currentAPICall!=kAPIGraphPictureGet) {
            currentAPICall = kAPIGraphPictureGet;
            
            NSString *requestSt=[NSString stringWithFormat:@"%@/picture",URL];
            NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            @"normal",@"type",
                                            nil];
//            
//            [facebook requestWithGraphPath:requestSt 
//                                 andParams:params 
//                               andDelegate:self];
            FBProfilePictureView *profilePic = [[FBProfilePictureView alloc] init];
            profilePic.profileID = playerAccount.facebookUser.id;
            
            
            
            NSMutableString *tfContent = [profilePic.profileID mutableCopy];
//            NSRange rng=NSMakeRange (0,27);
//            [tfContent deleteCharactersInRange:rng];
//            rng=NSMakeRange ([tfContent length]-8,8);
//            [tfContent deleteCharactersInRange:rng];

            NSString *path = [NSString stringWithFormat:@"%@/%@.png",getOpenGraphSavePath(),tfContent];
        
            UIGraphicsBeginImageContext(profilePic.frame.size);
            [profilePic drawRect:profilePic.frame];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
            [imageData writeToFile:path atomically:YES];
    
            [[NSNotificationCenter defaultCenter] postNotificationName: kReceiveImagefromFBNotification
                                                                            object:self
                                                                          userInfo:nil];

//            [FBRequestConnection startWithGraphPath:requestSt completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                DLog(@"%@ %@", result, error);
//            }];
            return path;
        }else {
            return nil;
        }
    }
}

-(void)apiGraphGetImage:(NSString *)URL delegate:(id<FBRequestDelegate>)pDelegate imageType:(typeOfFBImage)type;
{
    NSString *typeOfImage;
    switch (type) {
        case typeOfFBImageSquare:
            typeOfImage=@"square";
            break;
        case typeOfFBImageSmall:
            typeOfImage=@"small";
            break;
        case typeOfFBImageNormal:
            typeOfImage=@"normal";
            break;
        case typeOfFBImageLarge:
            typeOfImage=@"large";
            break;
        default:
            typeOfImage=@"normal";
            break;
    }
    NSString *requestSt=[NSString stringWithFormat:@"%@/picture",URL];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    typeOfImage,@"type",
                                    nil];
    
//    [facebook requestWithGraphPath:requestSt 
//                         andParams:params 
//                       andDelegate:pDelegate];
    [FBRequestConnection startWithGraphPath:requestSt completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];

}


-(void)apiGraphGetImageForList:(NSString *)URL delegate:(id<FBRequestDelegate>)pDelegate {
        
    NSString *requestSt=[NSString stringWithFormat:@"%@/picture",URL];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"square",@"type",
                                    nil];
    
//    [facebook requestWithGraphPath:requestSt 
//                         andParams:params 
//                       andDelegate:pDelegate];
    [FBRequestConnection startWithGraphPath:requestSt completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];

}

/*
 * Graph API: Get the user's friends
 */
- (void)getUserFriends {
    currentAPICall = kAPIGraphUserFriends;
    [FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];
}

/*
 * Graph API: Get the user's check-ins
 */
- (void)apiGraphUserCheckins {
//    [delegate showActivityIndicator];
    currentAPICall = kAPIGraphUserCheckins;
    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
    [FBRequestConnection startWithGraphPath:@"me/checkins" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];
}

/*
 * Helper method to check the user permissions which were stored in the app session
 * when the app was started. After the check decide on whether to prompt for user
 * check-in permissions first or get the check-in information.
 */
- (void)getPermissionsCallUserCheckins {
    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    if ([[delegate userPermissions] objectForKey:@"user_checkins"]) {
        [self apiGraphUserCheckins];
//    } else {
//        currentAPICall = kDialogPermissionsCheckinForRecent;
//        [self apiPromptCheckinPermissions];
//    }
}

/*
 * Graph API: Search query to get nearby location.
 */
- (void)apiGraphSearchPlace:(CLLocation *)location {
//    [delegate showActivityIndicator];
    currentAPICall = kAPIGraphSearchPlace;
    NSString *centerLocation = [[NSString alloc] initWithFormat:@"%f,%f",
                                location.coordinate.latitude,
                                location.coordinate.longitude];
    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"place",  @"type",
                                   centerLocation, @"center",
                                   @"1000",  @"distance",
                                   nil];
//    [centerLocation release];
    //[facebook requestWithGraphPath:@"search" andParams:params andDelegate:self];
    [FBRequestConnection startWithGraphPath:@"search" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];

}

/*
 * Method called when user location found. Calls the search API with the most
 * recent location reading.
 */
- (void)processLocationData {
    // Stop updating location information
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
    
    // Call the API to get nearby search results
    [self apiGraphSearchPlace:mostRecentLocation];
}

/*
 * Helper method to kick off GPS to get the user's location.
 */
- (void)getNearby {
//    [delegate showActivityIndicator];
    // A warning if the user turned off location services.
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
//        [servicesDisabledAlert release];
    }
    // Start the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    // Time out if it takes too long to get a reading.
    [self performSelector:@selector(processLocationData) withObject:nil afterDelay:15.0];
}

/*
 * Helper method to check the user permissions which were stored in the app session
 * when the app was started. After the check decide on whether to prompt for user
 * check-in permissions first or get the user's location which will in turn search
 * for nearby places the user can then check-in to.
 */
- (void)getPermissionsCallNearby {
    // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//    if ([[delegate userPermissions] objectForKey:@"publish_checkins"]) {
        [self getNearby];
//    } else {
//        currentAPICall = kDialogPermissionsCheckinForPlaces;
//        [self apiPromptCheckinPermissions];
//    }
}

/*
 * Graph API: Upload a photo. By default, when using me/photos the photo is uploaded
 * to the application album which is automatically created if it does not exist.
 */

/*
#pragma mark Graph API: Score

/*
 * Graph API: Score
 */

- (void)apiGraphScoreGet {
//    [delegate showActivityIndicator];
    currentAPICall = kAPIGraphScoreGet;
    
    //facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
    //[facebook requestWithGraphPath:@"me/scores" andDelegate:self];
    [FBRequestConnection startWithGraphPath:@"me/scores" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];
}

- (void)apiGraphScorePost:(int)num {
//    [delegate showActivityIndicator];
    currentAPICall = kNone;
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%d",num], @"score",
                                    nil];
    
    NSString *name=[[OGHelper sharedInstance ] getClearName:playerAccount.accountID];
    NSString *requestSt=[NSString stringWithFormat:@"%@/scores",name];
    
    //facebook.accessToken = kFacebookAppToken;
//    [facebook requestWithGraphPath:requestSt 
//                         andParams:params 
//                     andHttpMethod:@"POST" 
//                       andDelegate:self];
    
    id<FBGraphObject> graphObject = (id<FBGraphObject>)[FBGraphObject graphObjectWrappingDictionary:params];
    
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        // No permissions found in session, ask for it
        [FBSession.activeSession
         reauthorizeWithPublishPermissions:
         [NSArray arrayWithObject:@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) {
                 // If permissions granted, publish the story
                 [FBRequestConnection startForPostWithGraphPath:requestSt graphObject:graphObject completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                     DLog(@"%@ %@", result, error);
                     
                 }];
             }
         }];
    } else {
        // If permissions present, publish the story
        [FBRequestConnection startForPostWithGraphPath:requestSt graphObject:graphObject completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            DLog(@"%@ %@", result, error);
            
        }];
    }
    
    

}

#pragma mark Graph API: Achivments
/*
 * Graph API: Achivments
 */

- (void)apiGraphAchivAPPCreate:(NSString*)achivmentURL {
//    [delegate showActivityIndicator];
    currentAPICall = kAPIGraphAchivAPPCreate;
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    achivmentURL, @"achievement",
                                    nil];
   // facebook.accessToken = kFacebookAppToken;
//    [facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/achievements",kFacebookAppId] 
//                         andParams:params 
//                     andHttpMethod:@"POST" 
//                       andDelegate:self];
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/achievements",kFacebookAppId] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];
}

- (void)apiGraphAchivAPPGet {
//    [delegate showActivityIndicator];
    currentAPICall = kAPIGraphAchivAPPGet;
    
//    facebook.accessToken = kFacebookAppToken;
//    [facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/achievements",kFacebookAppId] 
//                       andDelegate:self];
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/achievements",kFacebookAppId] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];
}
- (void)apiGraphAchivAPPDelete:(NSString*)achivmentURL {
//    [delegate showActivityIndicator];
    currentAPICall = kAPIGraphAchivAPPDelete;
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    achivmentURL, @"achievement",
                                    nil];
//    facebook.accessToken = kFacebookAppToken;
//    [facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/achievements",kFacebookAppId] 
//                         andParams:params 
//                     andHttpMethod:@"DELETE" 
//                       andDelegate:self];
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/achievements",kFacebookAppId] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];
}


- (void)apiGraphAchivGet {
//    [delegate showActivityIndicator];
    currentAPICall = kAPIGraphAchivGet;
    
    NSString *name=[[OGHelper sharedInstance ] getClearName:playerAccount.accountID];
    NSString *requestSt=[NSString stringWithFormat:@"%@/achievements",name];
//    facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
//    [facebook requestWithGraphPath:requestSt andDelegate:self ];
    [FBRequestConnection startWithGraphPath:requestSt completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];
}

- (void)apiGraphAchivPost:(NSString*)achivmentURL {
//    [delegate showActivityIndicator];
    currentAPICall = kAPIGraphAchivPost;
    
    NSString *name=[[OGHelper sharedInstance ] getClearName:playerAccount.accountID];
    NSString *requestSt=[NSString stringWithFormat:@"%@/achievements",name];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    achivmentURL, @"achievement",
                                    nil];
//    facebook.accessToken = kFacebookAppToken;
//    [facebook requestWithGraphPath:requestSt 
//                         andParams:params 
//                     andHttpMethod:@"POST" 
//                       andDelegate:self];
    
    [FBRequestConnection startWithGraphPath:requestSt completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];
}

#pragma mark Graph API: Custom Action


/*
 * Graph API: Custom Action
 */

- (void)apiGraphCustomActionPost:(NSString*)objectURL actionTypeName:(NSString*)actionTypeName objectTypeName:(NSString*)objectTypeName {
    
    currentAPICall = kNone;
    NSString *requestSt=[NSString stringWithFormat:@"me/bidon_duels:%@",actionTypeName];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    objectURL, objectTypeName,
                                    nil];
//    facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
//    [facebook requestWithGraphPath:requestSt 
//                         andParams:params 
//                     andHttpMethod:@"POST" 
//                       andDelegate:self];
    
    
    id<FBGraphObject> graphObject = (id<FBGraphObject>)[FBGraphObject graphObjectWrappingDictionary:params];
    
    
    [FBRequestConnection startForPostWithGraphPath:requestSt graphObject:graphObject completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
        
    }];

}

- (void)apiGraphCustomActionGet:(NSString *)objectID {
//    [delegate showActivityIndicator];
    currentAPICall = kAPIGraphCustomActionGet;
    
    //    NSString *requestSt=[NSString stringWithFormat:@"%@/achievements",tfContent];
//    facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
//    [facebook requestWithGraphPath:objectID andDelegate:self ];
    
    [FBRequestConnection startWithGraphPath:objectID completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];

}

- (void)apiGraphCustomActionUpdate:(NSString *)objectID {
//    [delegate showActivityIndicator];
    currentAPICall = kAPIGraphCustomActionUpdate;
    
    //    NSString *requestSt=[NSString stringWithFormat:@"%@/achievements",tfContent];
    //facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBAccessTokenKey"];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"TestTaras",@"title",
                                    nil];
//    
//    [facebook requestWithGraphPath:objectID 
//                         andParams:params 
//                     andHttpMethod:@"POST" 
//                       andDelegate:self];
    
    [FBRequestConnection startWithGraphPath:objectID completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"%@ %@", result, error);
    }];
}


#pragma mark FConnect Methods

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response;
{
    DLog(@"didReceiveResponse %@ %@",request,response);
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */

//- (void)request:(FBRequest *)request didLoad:(id)result {
//    DLog(@"OGHelper Facebook request: %@ \n response: %@  \n currentAPICall %d", [request url], result, currentAPICall);
//    //    [delegate hideActivityIndicator];
//
//    if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)&&(currentAPICall != kAPIFriendsHowDontUseApp)) {
//        result = [result objectAtIndex:0];
//    }
//    if ([[request url] rangeOfString:@"me/feed"].location != NSNotFound) {
//        [[NSNotificationCenter defaultCenter] postNotificationName: kFBFeed
//                                                            object:self
//                                                          userInfo:nil];
//    }else if (([[request url] rangeOfString:@"method/fql.query"].location != NSNotFound) &&(currentAPICall !=kAPIFriendsHowDontUseApp)) {
//       [self getCountOfUserFriendsRequest:request didLoad:result];
//        return;
//    }else if (([[request url] rangeOfString:@"me/picture"].location != NSNotFound)) {
//        NSMutableString *tfContent = [[NSMutableString alloc] initWithString:[request url]];
//        NSRange rng=NSMakeRange (0,27);
//        [tfContent deleteCharactersInRange:rng];
//        rng=NSMakeRange ([tfContent length]-8,8);
//        [tfContent deleteCharactersInRange:rng];
//        NSData *data = [[NSData alloc] initWithData:result];
//        
//        NSString *path = [NSString stringWithFormat:@"%@/%@.png",getOpenGraphSavePath(),tfContent];
//        [data writeToFile:path atomically:YES];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName: kReceiveImagefromFBNotification
//                                                            object:self
//                                                          userInfo:nil];
//        return;
//    }
//    
//    switch (currentAPICall) {
//        case kAPIGraphUserPermissionsDelete:
//        {
//            [self showMessage:@"User uninstalled app"];
//            //            // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
//            //            // Nil out the session variables to prevent
//            //            // the app from thinking there is a valid session
//            //            facebook.accessToken = nil;
//            //            facebook.expirationDate = nil;
//            //            [self backToMain];
//            break;
//        }
//        case kAPIFriendsForDialogFeed:
//        {
//            NSArray *resultData = [result objectForKey:@"data"];
//            // Check that the user has friends
//            if ([resultData count] > 0) {
//                // Pick a random friend to post the feed to
//                int randomNumber = arc4random() % [resultData count];
//                [self apiDialogFeedFriend:[[resultData objectAtIndex:randomNumber] objectForKey:@"id"]];
//            } else {
//                [self showMessage:@"You do not have any friends to post to."];
//            }
//            break;
//        }
//        case kDialogFeedUser:
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName: kFBFeed
//                                                                object:self
//                                                              userInfo:nil];
//            break;
//        }
//        case kAPIGetAppUsersFriendsNotUsing:
//        {
//            // Save friend results
////            [savedAPIResult release];
//            savedAPIResult = nil;
//            // Many results
//            if ([result isKindOfClass:[NSArray class]]) {
//                savedAPIResult = [[NSMutableArray alloc] initWithArray:result copyItems:YES];
//            } else if ([result isKindOfClass:[NSDecimalNumber class]]) {
//                savedAPIResult = [[NSMutableArray alloc] initWithObjects:[result stringValue], nil];
//            }
//            
//            // Set up to get friends
//            currentAPICall = kAPIFriendsForDialogRequests;
//            [self apiGraphFriends];
//            break;
//        }
//        case kAPIGetAppUsersFriendsUsing:
//        {
//            NSMutableArray *friendsWithApp = [[NSMutableArray alloc] initWithCapacity:1];
//            // Many results
//            if ([result isKindOfClass:[NSArray class]]) {
//                friendsWithApp = [[NSMutableArray alloc] initWithArray:result copyItems:YES];
//            } else if ([result isKindOfClass:[NSDecimalNumber class]]) {
//                friendsWithApp = [[NSMutableArray alloc] initWithObjects:[result stringValue], nil];
//            }
//            if ([friendsWithApp count] > 0) {
//                [self apiDialogRequestsSendToUsers:friendsWithApp];
//            } else {
//                [self showMessage:@"None of your friends are using the app."];
//            }
////            [friendsWithApp release];
//            break;
//        }
//        case kAPIFriendsForDialogRequests:
//        {
//            NSArray *resultData = [result objectForKey:@"data"];
//            if ([resultData count] == 0) {
//                [self showMessage:@"You have no friends to select."];
//            } else {
//                NSMutableArray *friendsWithoutApp = [[NSMutableArray alloc] initWithCapacity:1];
//                // Loop through friends and find those who do not have the app
//                for (NSDictionary *friendObject in resultData) {
//                    BOOL foundFriend = NO;
//                    for (NSString *friendWithApp in savedAPIResult) {
//                        if ([[friendObject objectForKey:@"id"] isEqualToString:friendWithApp]) {
//                            foundFriend = YES;
//                            break;
//                        }
//                    }
//                    if (!foundFriend) {
//                        [friendsWithoutApp addObject:[friendObject objectForKey:@"id"]];
//                    }
//                }
//                if ([friendsWithoutApp count] > 0) {
//                    [self apiDialogRequestsSendToNonUsers:friendsWithoutApp];
//                } else {
//                    [self showMessage:@"All your friends are using the app."];
//                }
////                [friendsWithoutApp release];
//            }
//            break;
//        }
//        case kAPIFriendsForTargetDialogRequests:
//        {
//            NSArray *resultData = [result objectForKey:@"data"];
//            if ([resultData count] > 0) {
//                [self apiDialogRequestsSendTarget:[[resultData objectAtIndex:0] objectForKey:@"id"]];
//            } else {
//                [self showMessage:@"You have no friends to select."];
//            }
//            break;
//        }
//        case kAPIFriendsCount:
//        {
//            [self getCountOfUserFriendsRequest:request didLoad:result];
//            break;
//        }
//        case kAPIFriendsHowDontUseApp:
//        {
//            NSArray *friendToInvait = [self getFriendsHowDontUseAppRequest:request didLoad:result];
//            [self apiDialogRequestsSendToNonUsers:friendToInvait];
//            break;
//        }
//        case kAPIGraphMe:
//        {
//            NSString *nameID = [[NSString alloc] initWithFormat:@"%@ (%@)", [result objectForKey:@"name"], [result objectForKey:@"id"]];
//            NSMutableArray *userData = [[NSMutableArray alloc] initWithObjects:
//                                        [NSDictionary dictionaryWithObjectsAndKeys:
//                                         [result objectForKey:@"id"], @"id",
//                                         nameID, @"name",
//                                         [result objectForKey:@"picture"], @"details",
//                                         nil], nil];
//            // Show the basic user information in a new view controller
//            //            APIResultsViewController *controller = [[APIResultsViewController alloc]
//            //                                                    initWithTitle:@"Your Information"
//            //                                                    data:userData
//            //                                                    action:@""];
//            //            [self.navigationController pushViewController:controller animated:YES];
//            //            [controller release];
////            [userData release];
////            [nameID release];
//            break;
//        }
//        case kAPIGraphPictureGet:
//        {
//            
//            NSMutableString *tfContent = [[NSMutableString alloc] initWithString:[request url]];
//            NSRange rng=NSMakeRange (0,27);
//            [tfContent deleteCharactersInRange:rng];
//            rng=NSMakeRange ([tfContent length]-8,8);
//            [tfContent deleteCharactersInRange:rng];
//            NSData *data = [[NSData alloc] initWithData:result];
//            
//            NSString *path = [NSString stringWithFormat:@"%@/%@.png",getOpenGraphSavePath(),tfContent];
//            [data writeToFile:path atomically:YES];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName: kReceiveImagefromFBNotification
//                                                                object:self
//                                                              userInfo:nil];
//            break;
//        }
//            
//        case kAPIGraphUserFriends:
//        {
//            NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:1];
//            NSArray *resultData = [result objectForKey:@"data"];
//            if ([resultData count] > 0) {
//                for (NSUInteger i=0; i<[resultData count] && i < 25; i++) {
//                    [friends addObject:[resultData objectAtIndex:i]];
//                }
//                // Show the friend information in a new view controller
//                //                APIResultsViewController *controller = [[APIResultsViewController alloc]
//                //                                                        initWithTitle:@"Friends"
//                //                                                        data:friends action:@""];
//                //                [self.navigationController pushViewController:controller animated:YES];
//                //                [controller release];
//            } else {
//                [self showMessage:@"You have no friends."];
//            }
////            [friends release];
//            break;
//        }
//        case kAPIGraphUserCheckins:
//        {
//            NSMutableArray *places = [[NSMutableArray alloc] initWithCapacity:1];
//            NSArray *resultData = [result objectForKey:@"data"];
//            for (NSUInteger i=0; i<[resultData count] && i < 5; i++) {
//                NSString *placeID = [[[resultData objectAtIndex:i] objectForKey:@"place"] objectForKey:@"id"];
//                NSString *placeName = [[[resultData objectAtIndex:i] objectForKey:@"place"] objectForKey:@"name"];
//                NSString *checkinMessage = [[resultData objectAtIndex:i] objectForKey:@"message"] ?
//                [[resultData objectAtIndex:i] objectForKey:@"message"] : @"";
//                [places addObject:[NSDictionary dictionaryWithObjectsAndKeys:
//                                   placeID,@"id",
//                                   placeName,@"name",
//                                   checkinMessage,@"details",
//                                   nil]];
//            }
//            // Show the user's recent check-ins a new view controller
//            //            APIResultsViewController *controller = [[APIResultsViewController alloc]
//            //                                                    initWithTitle:@"Recent Check-ins"
//            //                                                    data:places
//            //                                                    action:@"recentcheckins"];
//            //            [self.navigationController pushViewController:controller animated:YES];
//            //            [controller release];
////            [places release];
//            break;
//        }
//        case kAPIGraphSearchPlace:
//        {
//            NSMutableArray *places = [[NSMutableArray alloc] initWithCapacity:1];
//            NSArray *resultData = [result objectForKey:@"data"];
//            for (NSUInteger i=0; i<[resultData count] && i < 5; i++) {
//                [places addObject:[resultData objectAtIndex:i]];
//            }
//            break;
//        }
//        case kAPIGraphUserPhotosPost:
//        {
//            [self showMessage:@"Photo uploaded successfully."];
//            break;
//        }
//        case kAPIGraphUserVideosPost:
//        {
//            [self showMessage:@"Video uploaded successfully."];
//            break;
//        }
//        case kAPIGraphScoreGet:
//        {
//            NSArray *resultData = [result objectForKey:@"data"];
//            if ([resultData count] > 0) {
//                [self showMessage:[NSString stringWithFormat:@"Your score %@",[[resultData objectAtIndex:0] objectForKey:@"score"]]];
//            } else {
//                [self showMessage:@"You have no score"];
//            }
//            break;
//        }
//        case kAPIGraphScorePost:
//        {
//            NSString *st = [result objectForKey:@"result"];
//            [self showMessage:[NSString stringWithFormat:@"Post score %@",st]];
//            
//            break;
//        }
//        case kAPIGraphAchivAPPCreate:
//        {
//            NSString *st = [result objectForKey:@"result"];
//            [self showMessage:[NSString stringWithFormat:@"Achivment create %@",st]];
//            break;
//        }
//        case kAPIGraphAchivAPPGet:
//        {
//            NSArray *resultData = [result objectForKey:@"data"];
//            NSMutableArray *mArrayAchivments = [[NSMutableArray alloc] init];
//            if ([resultData count]!=0) {
//                for(NSDictionary *value1 in resultData){
//                    NSString *st=[value1 objectForKey:@"title"];
//                    [mArrayAchivments addObject:st];
//                }
//            }
//            [self showMessage:[NSString stringWithFormat:@"APP Achivment  %@",mArrayAchivments]];
////            [mArrayAchivments release];
//            break;
//        }
//        case kAPIGraphAchivAPPDelete:
//        {
//            NSString *st = [result objectForKey:@"result"];
//            [self showMessage:[NSString stringWithFormat:@"Achivment Delete %@",st]];
//            break;
//        }
//        case kAPIGraphAchivGet:
//        {
//            NSArray *resultData = [result objectForKey:@"data"];
//            if ([resultData count] > 0) {
//                NSDictionary *resultData2 = [[resultData objectAtIndex:0] objectForKey:@"achievement"];
//                [self showMessage:[NSString stringWithFormat:@"Your achivments (%@)",[resultData2 objectForKey:@"title"]]];
//            } else {
//                [self showMessage:@"You have no achivments"];
//            }
//            break;
//        }
//        case kAPIGraphAchivPost:
//        {
//            [self showMessage:@"Achivment post."];
//            break;
//        }
//            
//        case kAPIGraphCustomActionPost:
//        {
//            NSString *resultData = [result objectForKey:@"id"];
//            [self showMessage:[NSString stringWithFormat:@"Custom action post  %@",resultData]];
//            break;
//        }    
//        case kAPIGraphCustomActionGet:
//        {
//            NSDictionary *resultData = [result objectForKey:@"data"];
//            if ([resultData count] > 0) {
//                NSDictionary *tournament=[resultData objectForKey:@"tournament"];
//                NSString *name=[tournament objectForKey:@"title"];
//                NSString *type=[tournament objectForKey:@"type"];
//                [self showMessage:[NSString stringWithFormat:@"Tournament title %@ type %@",name,type]];
//            } else {
//                [self showMessage:@"Tournament not found"];
//            }
//            break;
//        }
//        case kAPIGraphCustomActionUpdate:
//        {
//            NSString *st = [result objectForKey:@"result"];
//            [self showMessage:[NSString stringWithFormat:@"Custom URL update %@",st]];
//            break;
//        }
//            
//        default:
//            currentAPICall=kNone;
//            break;
//    }
//    currentAPICall=kNone;
//}
//
/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
//- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
//    //    [delegate hideActivityIndicator];
//    if ([[request url] isEqualToString:@"me/feed"]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName: kFBFeed
//                                                            object:self
//                                                          userInfo:nil];
//        return;
//    }else if (([[request url] rangeOfString:@"me/picture"].location != NSNotFound)){
//        [[NSNotificationCenter defaultCenter] postNotificationName: kReceiveImagefromFBNotification
//                                                            object:self
//                                                          userInfo:nil];
//        return;
//    }
//    
//    switch (currentAPICall) {
//        case kAPIGraphPictureGet:
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName: kReceiveImagefromFBNotification
//                                                                object:self
//                                                              userInfo:nil];
//            break;
//        }
//        case kDialogFeedUser:
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName: kFBFeed
//                                                                object:self
//                                                              userInfo:nil];
//            
//            
//            break;
//        }
//    
//        default:
//            currentAPICall=kNone;
//            break;
//    }
//    currentAPICall=kNone;
//
//    DLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
//    DLog(@"Facebook didFailWithError: %@  error %@"  , request,[error description]);
////        [self showMessage:[error debugDescription]];
//}




#pragma mark - Private metods

-(void) showMessage:(NSString *)message;
{
    DLog(@"mes %@",message);
}

@end
