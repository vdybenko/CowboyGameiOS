#import "AccountDataSource.h"
#import "CustomNSURLConnection.h"
#import "Utils.h"
#import "OGHelper.h"
#import "DuelProductDownloaderController.h"
#import "TestAppDelegate.h"

static const char *POST_TRANS_URL =  BASE_URL"api/transactions";
static const char *POST_DUEL_URL =  BASE_URL"api/duels";
static const char *LIST_BOTS_URL = BASE_URL"users/get_user_data";


@interface AccountDataSource(){
  NSMutableDictionary *dicForRequests;
}
@end

@implementation AccountDataSource

@synthesize money, accountName, teachingTimes, finalInfoTable, sessionID, accountID, accountDataSourceID, transactions, duels, achivments , glNumber,
 accountLevel,accountPoints,accountWins,accountDraws,accountBigestWin,removeAds,avatar,age,homeTown,friends,facebookName, bot, activeDuel;

@synthesize accountDefenseValue;
@synthesize curentIdWeapon;
@synthesize isTryingWeapon;
@synthesize accountWeapon;
@synthesize accountStore;
@synthesize loginAnimatedViewController;

#pragma mark

static AccountDataSource *sharedHelper = nil;
+ (AccountDataSource *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[AccountDataSource alloc] initWithLocalPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:sharedHelper
                                                 selector:@selector(sessionStateChanged:)
                                                     name:SCSessionStateChangedNotification
                                                   object:nil];
    }
    return sharedHelper;
}

-(id)initWithLocalPlayer;
{
    self = [super init];
    if (self) {
        self.accountName=@"Anonymous";
        money = 200;
        teachingTimes = [[NSMutableArray alloc] init];
        finalInfoTable = [[NSMutableArray alloc] init];
        [self makeLocalAccountID];
        accountDataSourceID = 1;
        sessionID=0;
        self.accountLevel=kCountOfLevelsMinimal;
        self.accountPoints=0;
        self.accountWins=0;
        self.accountDraws=0;
        self.accountBigestWin=0;
        self.removeAds=0;
        self.accountDefenseValue = 0;
        
        self.glNumber = 0;
        self.accountWeapon = [DuelProductDownloaderController defaultWeaponForPlayer];
        self.curentIdWeapon = self.accountWeapon.dID;
        
        self.isTryingWeapon=NO;
        
        self.avatar=@"";
        self.age=@"";
        self.homeTown=@"";
        self.friends=0;
        self.facebookName=@"";
                
        transactions = [[NSMutableArray alloc] init];
        duels = [[NSMutableArray alloc] init];
        achivments = [[NSMutableArray alloc] init];
        dicForRequests=[[NSMutableDictionary alloc] init];
        
    }
    return self;
}

- (void)loadAllParametrs;
{
  NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
  self.accountID = [uDef stringForKey:@"id"];
  if ([self.accountID isEqualToString:@""]) [self makeLocalAccountID];
  
  self.accountName = [uDef stringForKey:@"name"];
  self.money = [uDef integerForKey:@"money"];
  self.accountLevel = [uDef integerForKey:@"accountLevel"];
  self.accountPoints = [uDef integerForKey:@"lvlPoints"];
  self.accountWins= [uDef integerForKey:@"WinCount"];
  self.accountDraws = [uDef integerForKey:@"DrawCount"];
  self.accountBigestWin = [uDef integerForKey:@"MaxWin"];
  self.removeAds = [uDef integerForKey:@"RemoveAds"];
    
    [self loadDefense];
    
    [self loadWeapon];
    
  self.avatar = [uDef stringForKey:@"avatar"];
  self.age = [uDef stringForKey:@"age"];
  self.homeTown = [uDef stringForKey:@"homeTown"];
  self.friends = [uDef integerForKey:@"friends"];
  self.facebookName = [uDef stringForKey:@"facebook_name"];
  
  if(![uDef stringForKey:@"deviceType"])
    [uDef setObject:ValidateObject([Utils deviceType], [NSString class]) forKey:@"deviceType"];
  
  if(self.money<0){
    self.money=0;
  }
  [uDef setObject:ValidateObject(self.accountID, [NSString class]) forKey:@"id"];
  
    self.glNumber = [uDef integerForKey:@"GL_NUMBER"];
    
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"transactions"];
  
  NSArray *oldLocations = [uDef arrayForKey:@"transactions"];
  if( [oldLocations count]!=0)
  {
    for( NSData *data in oldLocations )
    {
      CDTransaction * loc = (CDTransaction*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
      [self.transactions addObject:loc];
    }
  }
  
  NSArray *oldLocations2 = [uDef arrayForKey:@"duels"];
  if( self.duels )
  {
    for( NSData *data in oldLocations2 )
    {
      CDDuel * loc = (CDDuel*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
      [self.duels addObject:loc];
    }
  }
  
  NSArray *oldLocations3 = [uDef arrayForKey:@"achivments"];
  if( self.duels )
  {
    for( NSData *data in oldLocations3 )
    {
      CDAchivment * loc = (CDAchivment*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
      NSLog(@"achivments %@", loc.aAchivmentId);
      [self.achivments addObject:loc];
    }
  }
}

- (void)makeLocalAccountID{
  UIDevice *currentDevice = [UIDevice currentDevice];
  self.accountID = [NSString stringWithFormat:@"A:%@",[currentDevice.uniqueIdentifier substringToIndex:10]];
}

- (NSString *)verifyAccountID{
  [self makeLocalAccountID];
  return self.accountID;
}

#pragma mark

- (void)sendTransactions:(NSMutableArray *)transactions1 {
  
    SBJSON *jsonWriter = [SBJSON new];
  
    NSDictionary *resultObj = [NSDictionary dictionaryWithObject:[self fetchArray:transactions1] forKey:@"transactions"];
  
    NSString *resultStr = [jsonWriter stringWithObject:resultObj];
    
    DLog(@"AccountDataSource: New actions: %@", resultStr);
	
    NSString *gcAlias = accountID;
    if ([gcAlias length] == 0)
        gcAlias = @"Anonymous";
  
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:POST_TRANS_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    [theRequest setHTTPMethod:@"POST"]; 
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    
    [dicBody setValue:sessionID forKey:@"session_id"];
    [dicBody setValue:gcAlias forKey:@"authentification"];
    [dicBody setValue:resultStr forKey:@"transactions"];  
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    DLog(@"dicBody %@",dicBody);
	[theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [dicForRequests setObject:receivedData forKey:[theConnection.requestURL lastPathComponent]];
    } else {
    }
}

- (NSArray *)fetchArray:(NSMutableArray *)array {
    
    int n = [array count];    
    DLog(@"actions = %d", n);
    
    NSMutableArray *result = [NSMutableArray array];
    
    for (CDTransaction *transaction in array) {
        NSMutableDictionary *reason = [NSMutableDictionary dictionary];
        [reason setObject:transaction.trOpponentID ? transaction.trOpponentID: @"" forKey:@"opponent_authen"];
        [reason setObject: [NSNumber numberWithInt:-1] forKey:@"local_id"];
        [reason setObject: [NSNumber numberWithInt:[self crypt:[transaction.trMoneyCh intValue]]] forKey:@"transaction_id"];
        [reason setObject:transaction.trDescription forKey:@"description"];
        [reason setObject:transaction.trLocalID forKey:@"local_id"];
        [result addObject:[NSDictionary dictionaryWithObject:reason forKey:@"transaction"]];
    }
    return result;
}


- (void)sendDuels:(NSMutableArray *)duels1 {
    
    SBJSON *jsonWriter = [SBJSON new];
    
    NSDictionary *resultObj = [NSDictionary dictionaryWithObject:[self fetchDuelArray:duels1] forKey:@"duels"];
    
    NSString *resultStr = [jsonWriter stringWithObject:resultObj];
    
    DLog(@"AccountDataSource: New duels: %@", resultStr);
	
    NSString *gcAlias = accountID;
    if ([gcAlias length] == 0)
        gcAlias = @"Anonymous";
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:POST_DUEL_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    [theRequest setHTTPMethod:@"POST"]; 
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    [dicBody setValue:version forKey:@"app_ver"];
    [dicBody setValue:currentDevice.systemName forKey:@"system_name"];
    [dicBody setValue:currentDevice.systemVersion forKey:@"system_version"];
    [dicBody setValue:gcAlias forKey:@"authentification"];
                                 
    [dicBody setValue:resultStr forKey:@"duels"];
    [dicBody setValue:sessionID forKey:@"session_id"];  
    [dicBody setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceType"] forKey:@"device_name"];
    
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    
	[theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [dicForRequests setObject:receivedData forKey:[theConnection.requestURL lastPathComponent]];
    } else {
    }
}

- (NSArray *)fetchDuelArray:(NSMutableArray *)array {
    
    int n = [array count];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:n];
    
    for (int i = 0; i < n; i++) {
        NSMutableDictionary *reason = [NSMutableDictionary dictionary];
        CDDuel *duel = [array objectAtIndex:i];
        
        [reason setObject:duel.dRateFire forKey:@"rate_fire"];
        [reason setObject:duel.dOpponentId forKey:@"opponent"];
        [reason setObject:duel.dDate forKey:@"date"];
        [result addObject:[NSDictionary dictionaryWithObject:reason forKey:@"duel"]];
    }
    return result;
}

#pragma mark

-(NSString *)dateFormat
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *theDate = [dateFormat stringFromDate:now];
    NSString *theTime = [timeFormat stringFromDate:now];
    
    DLog(@"\n"
          "theDate: |%@| \n"
          "theTime: |%@| \n"
          , theDate, theTime);
    
    return [NSString stringWithFormat:@"%@ %@", theDate, theTime];
}

-(NSString *)dateFormatDay
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *theDate = [dateFormat stringFromDate:now];
        
    DLog(@"\n"
          "theDate: |%@| \n"
          , theDate);
    
    return [NSString stringWithFormat:@"%@", theDate];
}

#pragma mark

-(int)stringToInt:(NSString *)string
{
  NSMutableString *tempString = [NSMutableString stringWithCapacity:10];
  for (int i = 0; i < 2; i++) {
    NSLog(@"%u", (int)[string characterAtIndex:i]);
    [tempString appendString:[NSString stringWithFormat:@"%u", (int)[string characterAtIndex:i]]];
  }
  return [tempString intValue];
}

-(int)crypt:(int)secret_int
{
  return secret_int ^ [self stringToInt:sessionID];
}



#pragma mark CustomNSURLConnection handlers

- (void)connectionDidFinishLoading:(CustomNSURLConnection *)connection1 {
    NSString * currentParseString = [NSString stringWithFormat:@"%@",connection1.requestURL];
    
    NSMutableData *receivedData=[dicForRequests objectForKey:[currentParseString lastPathComponent]];
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    [dicForRequests removeObjectForKey:[currentParseString lastPathComponent]];
    NSDictionary *responseObject = ValidateObject([jsonString JSONValue], [NSDictionary class]);
    
    DLog(@"AccountDataSource jsonValues %@", jsonString);
    
    DLog(@"err_des %@", ValidateObject([responseObject objectForKey:@"err_desc"], [NSString class]));
    
    int errCode=[[responseObject objectForKey:@"err_code"] intValue];
    if (errCode==-1) {
        [[NSNotificationCenter defaultCenter] postNotificationName: kCheckfFBLoginSession
                                                            object:self
                                                          userInfo:nil];
        return;
    }
//    duels
    if (errCode==1) {
        NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
        [usrDef removeObjectForKey:@"duels"];
        [usrDef synchronize];
        return;
    }   
//    transaction
    if([responseObject objectForKey:@"money"] && [[responseObject objectForKey:@"user_id"] isEqualToString:accountID])
    {
        money = [self crypt:[[responseObject objectForKey:@"money"] intValue]];
        if(money < 0) money = 0;
        DLog(@"money %d", money);
        NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
        [usrDef removeObjectForKey:@"transactions"];
        [self.transactions removeAllObjects];
        [usrDef setInteger:money forKey:@"money"];
        [usrDef synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kCheckfFBLoginSession
                                                            object:self
                                                          userInfo:nil];
    }
}

- (void)connection:(CustomNSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString * currentParseString = [NSString stringWithFormat:@"%@",connection.requestURL];
    [dicForRequests setObject:data forKey:[currentParseString lastPathComponent]];
}

- (void)connection:(CustomNSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kCheckfFBLoginSession
                                                        object:self
                                                      userInfo:nil];
    // inform the user
    DLog(@"AccountDataSource Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

#pragma mark
- (void)saveID;
{
    [[NSUserDefaults standardUserDefaults] setObject:ValidateObject(self.accountID, [NSString class]) forKey:@"id"];
}
- (void)saveAccountName;
{
    [[NSUserDefaults standardUserDefaults] setObject:ValidateObject(self.accountName, [NSString class]) forKey:@"name"];
}
- (void)saveMoney;
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.money forKey:@"money"];
}
- (void)saveAccountLevel;
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.accountLevel forKey:@"accountLevel"];
}
- (void)saveAccountPoints;
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.accountPoints forKey:@"lvlPoints"];
}
- (void)saveAccountWins;
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.accountWins forKey:@"WinCount"];
}
- (void)saveAccountDraws;
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.accountDraws forKey:@"DrawCount"];
}
- (void)saveAccountBigestWin;
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.accountBigestWin forKey:@"MaxWin"];
}
- (void)saveRemoveAds;
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.removeAds forKey:@"RemoveAds"];
}
- (void)saveAvatar;
{
    [[NSUserDefaults standardUserDefaults] setObject:ValidateObject(self.avatar, [NSString class]) forKey:@"avatar"];
}
- (void)saveAge;
{
    [[NSUserDefaults standardUserDefaults] setObject:self.age forKey:@"age"];
}
- (void)saveHomeTown;
{
    [[NSUserDefaults standardUserDefaults] setObject:ValidateObject(self.homeTown, [NSString class]) forKey:@"homeTown"];
}
- (void)saveFriends;
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.friends forKey:@"friends"];
}
- (void)saveFacebookName;
{
    [[NSUserDefaults standardUserDefaults] setObject:ValidateObject(self.facebookName, [NSString class]) forKey:@"facebook_name"];
}

- (void)saveDeviceType;
{
    [[NSUserDefaults standardUserDefaults] setObject:ValidateObject([Utils deviceType], [NSString class]) forKey:@"deviceType"];
}

- (void)saveWeapon;
{    
    [[NSUserDefaults standardUserDefaults] setInteger:self.curentIdWeapon forKey:@"WEAPON"];
}

- (void)loadWeapon;
{
    self.curentIdWeapon = [[NSUserDefaults standardUserDefaults] integerForKey:@"WEAPON"];
    [self loadAccountWeapon];
}

- (void)saveDefense;
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.accountDefenseValue forKey:@"DEFENSE_VALUE"];
}

- (void)loadDefense;
{
    self.accountDefenseValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"DEFENSE_VALUE"];
}

- (void)cleareWeaponAndDefense;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray *arrWeaponSaved = [DuelProductDownloaderController loadWeaponArray];
        for (CDWeaponProduct *product in arrWeaponSaved) {
            product.dCountOfUse = 0;
        }
        [DuelProductDownloaderController saveWeapon:arrWeaponSaved];
        self.curentIdWeapon = -1;
        self.accountWeapon = [[CDWeaponProduct alloc] init];
        [self saveWeapon];
        
        NSArray *arrDefenseSaved = [DuelProductDownloaderController loadDefenseArray];
        for (CDDefenseProduct *product in arrDefenseSaved) {
            product.dCountOfUse = 0;
        }
        [DuelProductDownloaderController saveDefense:arrDefenseSaved];
        self.accountDefenseValue = 0;
        [self saveDefense];
    });
}

- (void)saveTransaction;
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableArray *locationData = [[NSMutableArray alloc] init];
    for( CDTransaction *loc in self.transactions)
    {
        [locationData addObject: [NSKeyedArchiver archivedDataWithRootObject:loc]];
    }
    [def setObject:locationData forKey:@"transactions"];
}

- (void)saveGlNumber;
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.glNumber forKey:@"GL_NUMBER"];
}

- (int)increaseGlNumber;
{
    glNumber++;
    [self saveGlNumber];
    return glNumber;
}

- (BOOL)isPlayerPlayDuel;
{
    if (self.finalInfoTable && [self.finalInfoTable count]) {
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)isPlayerForPractice{
    return [self.sessionID isEqualToString:@"-1"]?YES:NO;
}

#pragma mark accountWeapon

- (CDWeaponProduct*)loadAccountWeapon;
{
    NSArray *arrayWeapon = [DuelProductDownloaderController loadWeaponArray];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.dID = %d", self.curentIdWeapon];
    NSArray *results = [arrayWeapon filteredArrayUsingPredicate:predicate];
    if ([results count]) {
        self.accountWeapon = [results objectAtIndex:0];
        return [results objectAtIndex:0];
    }
    return nil;
}

-(NSUInteger(^)(NSArray *, NSInteger))findObsByID {
    return ^(NSArray * array, NSInteger idObject) {
        for (NSUInteger i = 0; i < [array count]; i++) {
            CDDuelProduct *product = [array objectAtIndex:i];
            if (product.dID == idObject) {
                return i;
            }
        }
        return (NSUInteger)NSNotFound;
    };
}

-(NSUInteger(^)(NSArray *, NSString *))findObsByPurchase {
    return ^(NSArray * array, NSString *purchaseString) {
        for (NSUInteger i = 0; i < [array count]; i++) {
            CDDuelProduct *product = [array objectAtIndex:i];
            if ([product.dPurchaseUrl isEqualToString:purchaseString]) {
                return i;
            }
        }
        return (NSUInteger)NSNotFound;
    };
}

-(BOOL)isAvatarImage:(NSString*)imagePath
{
    if (([self.accountID rangeOfString:@"F:"].location != NSNotFound)){
        NSString *extencion=[imagePath pathExtension];
        if (([extencion isEqualToString:@"jpg"])||([extencion isEqualToString:@"jpeg"])||([extencion isEqualToString:@"png"])||([extencion isEqualToString:@"gif"])){
            return YES;
        }else {
            return NO;
        }
    }else {
        return YES;
    }
}

-(BOOL)putchAvatarImageSendInfo{
    BOOL putchAvatarImageCHeck = [[NSUserDefaults standardUserDefaults] boolForKey:@"putchAvatarImageCHeck"];
    if (!putchAvatarImageCHeck) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"putchAvatarImageCHeck"];
        return YES;
    }else {
        return NO;
    }
}

#pragma mark - FBLoginViewDelegate

//- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
//    // first get the buttons set for login mode
////    self.buttonPostPhoto.enabled = YES;
////    self.buttonPostStatus.enabled = YES;
////    self.buttonPickFriends.enabled = YES;
////    self.buttonPickPlace.enabled = YES;
//    DLog(@"User login");
//}
//
//- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
//                            user:(id<FBGraphUser>)user {
//    // here we use helper properties of FBGraphUser to dot-through to first_name and
//    // id properties of the json response from the server; alternatively we could use
//    // NSDictionary methods such as objectForKey to get values from the my json object
//    // setting the profileID property of the FBProfilePictureView instance
//    // causes the control to fetch and display the profile picture for the user
//    self.facebookUser = user;
//    if(user) [self.loginAnimatedViewController fbDidLogin];
//}
//
//- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
////    BOOL canShareAnyhow = [FBNativeDialogs canPresentShareDialogWithSession:nil];
////    self.buttonPostPhoto.enabled = canShareAnyhow;
////    self.buttonPostStatus.enabled = canShareAnyhow;
////    self.buttonPickFriends.enabled = NO;
////    self.buttonPickPlace.enabled = NO;
////    
////    self.profilePic.profileID = nil;
////    self.labelFirstName.text = nil;
////    self.loggedInUser = nil;
//}

- (void)sessionStateChanged:(NSNotification*)notification {
    // A more complex app might check the state to see what the appropriate course of
    // action is, but our needs are simple, so just make sure our idea of the session is
    // up to date and repopulate the user's name and picture (which will fail if the session
    // has become invalid).
    [self populateUserDetails];
}


// FBSample logic
// Displays the user's name and profile picture so they are aware of the Facebook
// identity they are logged in as.
- (void)populateUserDetails {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 self.facebookUser = user;
                 if(user) [self.loginAnimatedViewController fbDidLogin];
//                 self.userNameLabel.text = user.name;
//                 self.userProfileImage.profileID = [user objectForKey:@"id"];
             }
         }];
    }
}


@end
