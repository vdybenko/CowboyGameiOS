//
//  MyTest.m
//  MyTestable
//
//  Created by Gabriel Handford on 7/16/11.
//  Copyright 2011 rel.me. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h> 
#import "AccountDataSource.h"
#import <Foundation/Foundation.h>
#import "StartViewController.h"

static const char *AUTORIZATION_URL =  BASE_URL"api/authorization";
static const char *REGISTRATION_URL =  BASE_URL"api/registration";
static const char *MODIFIER_USER_URL =  BASE_URL"users/set_user_data";

static const char *URL_PRODUCT_FILE   = BASE_S3_URL"list_of_store_items_v2.2.json";
static const char *URL_PRODUCT_FILE_RETINEA   = BASE_S3_URL"list_of_store_items_retina_v2.2.json";
static const char *URL_USER_PRODUCTS = BASE_URL"store/get_buy_items_user";

@interface MyTestAsync : GHAsyncTestCase {
    AccountDataSource *accountDataSource;
    SEL currentSelector;
}
@end

@implementation MyTestAsync

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES.
    // Also an async test that calls back on the main thread, you'll probably want to return YES.
    return YES;
}

- (void)setUpClass {
    // Run at start of all tests in the class
    accountDataSource = [AccountDataSource sharedInstance];
    [accountDataSource loadAllParametrs];
}

- (void)testAutorizationConnection {
    
    [self prepare];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:AUTORIZATION_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                        accountDataSource.accountID, @"id",
                            nil];
    [request setHTTPMethod:@"POST"];
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [request setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];

    currentSelector = @selector(testAutorizationConnection);

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    
}

- (void)testRegistrationConnection {
    
    [self prepare];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    if ([accountDataSource.accountID length] < 9) [accountDataSource verifyAccountID];
    NSString *deviceToken;
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceToken"]) deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceToken"];
    else deviceToken = @"";
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    NSLocale* curentLocale = [NSLocale currentLocale];
    NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
       
    NSMutableDictionary *dicBody=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  version,@"app_ver",
                                  currentDevice.systemVersion,@"os",
                                  @"12345",@"auth_key",
                                  deviceToken,@"device_token",
                                  [curentLocale localeIdentifier] ,@"region",
                                  [languages objectAtIndex:0] ,@"current_language",
                                  nil];
    
    [dicBody setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceType"] forKey:@"device_name"];
    [dicBody setValue:accountDataSource.accountID forKey:@"authentification"];
    
    [dicBody setValue:accountDataSource.accountID forKey:@"authen_old"];
    //[dicBody setValue:oldAccounId forKey:@"authen_old"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",accountDataSource.accountLevel ] forKey:@"level"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",accountDataSource.accountPoints ] forKey:@"points"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",accountDataSource.accountWins] forKey:@"duels_win"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",accountDataSource.accountDraws] forKey:@"duels_lost"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",accountDataSource.accountBigestWin] forKey:@"bigest_win"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",accountDataSource.removeAds] forKey:@"remove_ads"];
    [dicBody setValue:accountDataSource.accountID forKey:@"identifier"];
    
    [dicBody setValue:[accountDataSource.avatar stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"avatar"];
    [dicBody setValue:[accountDataSource.age stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"age"];
    [dicBody setValue:[accountDataSource.homeTown stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"home_town"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",accountDataSource.friends] forKey:@"friends"];
    [dicBody setValue:accountDataSource.facebookName forKey:@"facebook_name"];
    
    GHTestLog(@"%@",dicBody);
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:REGISTRATION_URL encoding:NSUTF8StringEncoding]]
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:kTimeOutSeconds];
    [request setHTTPMethod:@"POST"];
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [request setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    currentSelector = @selector(testRegistrationConnection);
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

- (void)testModifyUserConnection {
    
    [self prepare];
    
    NSMutableDictionary *dicBody=[NSMutableDictionary dictionary];
    [dicBody setValue:accountDataSource.accountID forKey:@"authentification"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",accountDataSource.accountLevel ] forKey:@"level"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",accountDataSource.accountPoints ] forKey:@"points"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",accountDataSource.accountWins] forKey:@"duels_win"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",accountDataSource.accountDraws] forKey:@"duels_lost"];
    [dicBody setValue:[NSString stringWithFormat:@"%d",accountDataSource.accountBigestWin] forKey:@"bigest_win"];
    
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    GHTestLog(@"%@",dicBody);

    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:MODIFIER_USER_URL encoding:NSUTF8StringEncoding]]
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:kTimeOutSeconds];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    currentSelector = @selector(testModifyUserConnection);

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

- (void)testProductConnection {
    
    [self prepare];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:URL_PRODUCT_FILE encoding:NSUTF8StringEncoding]]
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:kTimeOutSeconds];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    currentSelector = @selector(testProductConnection);
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

- (void)testProductRetineConnection {
    
    [self prepare];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:URL_PRODUCT_FILE_RETINEA encoding:NSUTF8StringEncoding]]
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:kTimeOutSeconds];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    currentSelector = @selector(testProductRetineConnection);
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

- (void)testUserProductConnection {
    
    [self prepare];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:URL_USER_PRODUCTS encoding:NSUTF8StringEncoding]]
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:kTimeOutSeconds];
    [request setHTTPMethod:@"POST"];
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                           [AccountDataSource sharedInstance].accountID,@"authentification",
                           nil];
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [request setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    currentSelector = @selector(testUserProductConnection);
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

- (void)testUserFBScorePost
{
    currentSelector = @selector(testUserFBScorePost);
    
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         
         NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%d",100], @"score",
                                         nil];
         
         NSString *name=[[OGHelper sharedInstance ] getClearName:[AccountDataSource sharedInstance].accountID];
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
                  GHAssertNULL((__bridge void *) error, nil);
                  if (!error) {
                      // If permissions granted, publish the story
                      [FBRequestConnection startForPostWithGraphPath:requestSt graphObject:graphObject completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                          [self notify:kGHUnitWaitStatusSuccess forSelector:currentSelector];
                          
                      }];
                  }
                  else {
                      [self notify:kGHUnitWaitStatusFailure forSelector:currentSelector];
                  }
              }];
         } else {
             // If permissions present, publish the story
             [FBRequestConnection startForPostWithGraphPath:requestSt graphObject:graphObject completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                 GHAssertNULL((__bridge void *) error, nil);
                 if (!error) {
                     [self notify:kGHUnitWaitStatusSuccess forSelector:currentSelector];
                 } else{
                     [self notify:kGHUnitWaitStatusFailure forSelector:currentSelector];
                 }
                 
             }];
         }

     }];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self notify:kGHUnitWaitStatusSuccess forSelector:currentSelector];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self notify:kGHUnitWaitStatusFailure forSelector:currentSelector];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    GHTestLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *responseObject = ValidateObject([jsonString JSONValue], [NSDictionary class]);
    
    GHAssertGreaterThanOrEqual([[responseObject objectForKey:@"err_code"] intValue], 0, [responseObject objectForKey:@"err_description"]);
} 

@end


