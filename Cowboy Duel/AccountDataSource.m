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

@synthesize money, accountName, teachingTimes, finalInfoTable, sessionID, accountID, accountDataSourceID, transactions, achivments , glNumber,
 accountLevel,accountPoints,accountWins,accountDraws,accountBigestWin,accountBigestMoney,removeAds,avatar,age,homeTown,friends,facebookName, bot, activeDuel, accountSceneConfig;

@synthesize accountDefenseValue;
@synthesize accountAtackValue;
@synthesize curentIdWeapon;
@synthesize isTryingWeapon;
@synthesize gameType;
@synthesize accountWeapon;
@synthesize accountStore;
@synthesize loginAnimatedViewController;
@synthesize visualViewCap;
@synthesize visualViewHead;
@synthesize visualViewBody;
@synthesize visualViewLegs;
@synthesize visualViewShoose;
@synthesize visualViewJackets;
@synthesize visualViewGuns;
@synthesize visualViewSuits;
@synthesize arrayOfBoughtProducts;
@synthesize defaultName;
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
        defaultName = @"Anonymous";
        self.accountName=defaultName;
        money = 200;
        teachingTimes = [[NSMutableArray alloc] init];
        finalInfoTable = [[NSMutableArray alloc] init];
//        [self makeLocalAccountID];
        accountDataSourceID = 1;
        sessionID=0;
        self.accountLevel=kCountOfLevelsMinimal;
        self.accountPoints=0;
        self.accountWins=0;
        self.accountDraws=0;
        self.accountBigestWin=0;
        self.accountBigestMoney = 0;
        self.removeAds=0;
        self.accountDefenseValue = 0;
        self. accountAtackValue = 0;
        
        self.glNumber = 0;
        self.accountWeapon = [DuelProductDownloaderController defaultWeaponForPlayer];
        self.curentIdWeapon = self.accountWeapon.dID;
        
        self.isTryingWeapon=NO;
        
        self.bot = NO;
        
        self.avatar=@"";
        self.age=@"";
        self.homeTown=@"";
        self.friends=0;
        self.facebookName=@"";
        self.accountSceneConfig = [[GameSceneConfig alloc] init];
        transactions = [[NSMutableArray alloc] init];
        achivments = [[NSMutableArray alloc] init];
        dicForRequests=[[NSMutableDictionary alloc] init];
        arrayOfBoughtProducts=[[NSMutableArray alloc] init];
       
        self.visualViewCap = 0;
        self.visualViewHead = 0;
        self.visualViewBody = 0;
        self.visualViewLegs = 0;
        self.visualViewShoose = 0;
        self.visualViewJackets = 0;
        self.visualViewGuns = 0;
        self.visualViewSuits = 0;
        
        gameType = GameTypeAccelerometer;
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
  self.accountBigestMoney = [uDef integerForKey:@"MaxMoney"];
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
  
  NSArray *oldLocations3 = [uDef arrayForKey:@"achivments"];
    for( NSData *data in oldLocations3 )
    {
      CDAchivment * loc = (CDAchivment*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
      NSLog(@"achivments %@", loc.aAchivmentId);
      [self.achivments addObject:loc];
    }

     [self loadVisualView];
}

- (void)makeLocalAccountID{
    srand((unsigned)time( NULL ));
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    NSString *stUUID = [[oNSUUID UUIDString] substringToIndex:10];
    self.accountID = [NSString stringWithFormat:@"A:%@",stUUID];
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
    
    DLog(@"AccountDataSource jsonValues %@ \n %@", jsonString,currentParseString);
    
    DLog(@"err_des %@", ValidateObject([responseObject objectForKey:@"err_desc"], [NSString class]));
    
    int errCode=[[responseObject objectForKey:@"err_code"] intValue];
    if (errCode==-1) {
        [[NSNotificationCenter defaultCenter] postNotificationName: kCheckfFBLoginSession
                                                            object:self
                                                          userInfo:nil];
        return;
    }  
//    transaction
   
    if([responseObject objectForKey:@"money"] && [[responseObject objectForKey:@"user_id"] isEqualToString:accountID])
    {
        money = [self crypt:[[responseObject objectForKey:@"money"] intValue]];
        if(money < 0) money = 0;
        
        NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
        NSString *stRealID = [usrDef stringForKey:@"id"];
        if ([[responseObject objectForKey:@"user_id"] isEqualToString:stRealID]) {
            [usrDef removeObjectForKey:@"transactions"];
            [self.transactions removeAllObjects];
            [usrDef setInteger:money forKey:@"money"];
            [usrDef synchronize];
            DLog(@"money real %d", money);
        }else{
            DLog(@"money falt %d", money);
        }
        
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
- (void)saveAccountBigestMoney;
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.accountBigestMoney forKey:@"MaxMoney"];
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
    [[NSUserDefaults standardUserDefaults] setInteger:self.accountAtackValue forKey:@"DEFENSE_VALUE"];
}

- (void)loadWeapon;
{
    self.accountAtackValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"DEFENSE_VALUE"];
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

- (void)recountDefenseAndAtack;
{
    VisualViewDataSource *visualViewDataSource = [[VisualViewDataSource alloc] init];
    CDVisualViewCharacterPart *visualViewCharacterPart;
    accountDefenseValue = 0;
    if (visualViewSuits) {
        visualViewCharacterPart= [self loadProductWithIndex:visualViewSuits type:CharacterPartSuit visualViewDataSource:visualViewDataSource];
        accountDefenseValue+=visualViewCharacterPart.action;
    }else{
        visualViewCharacterPart= [self loadProductWithIndex:visualViewCap type:CharacterPartCap visualViewDataSource:visualViewDataSource];
        accountDefenseValue+=visualViewCharacterPart.action;
        visualViewCharacterPart= [self loadProductWithIndex:visualViewLegs type:CharacterPartLegs visualViewDataSource:visualViewDataSource];
        accountDefenseValue+=visualViewCharacterPart.action;
        visualViewCharacterPart= [self loadProductWithIndex:visualViewBody type:CharacterPartShirt visualViewDataSource:visualViewDataSource];
        accountDefenseValue+=visualViewCharacterPart.action;
        visualViewCharacterPart= [self loadProductWithIndex:visualViewJackets type:CharacterPartJaket visualViewDataSource:visualViewDataSource];
        accountDefenseValue+=visualViewCharacterPart.action;
        visualViewCharacterPart= [self loadProductWithIndex:visualViewShoose type:CharacterPartShoose visualViewDataSource:visualViewDataSource];
        accountDefenseValue+=visualViewCharacterPart.action;
    }
    accountAtackValue = 0;
    visualViewCharacterPart= [self loadProductWithIndex:visualViewGuns type:CharacterPartGun visualViewDataSource:visualViewDataSource];
    accountAtackValue+=visualViewCharacterPart.action;
    visualViewCharacterPart= [self loadProductWithIndex:visualViewHead type:CharacterPartFace visualViewDataSource:visualViewDataSource];
    accountAtackValue+=visualViewCharacterPart.action;
    
    [visualViewDataSource releaseComponents];
    visualViewDataSource = nil;
}

- (CDVisualViewCharacterPart*)loadProductWithIndex:(int)index type:(CharacterPart)type visualViewDataSource:(VisualViewDataSource*)datasource;
{
    NSArray *array;
    switch (type) {
        case CharacterPartCap:
            array = [datasource arrayCap];
            break;
        case CharacterPartFace:
            array = [datasource arrayHead];
            break;
        case CharacterPartGun:
            array = [datasource arrayGuns];
            break;
        case CharacterPartJaket:
            array = [datasource arrayJakets];
            break;
        case CharacterPartLegs:
            array = [datasource arrayLegs];
            break;
        case CharacterPartShirt:
            array = [datasource arrayBody];
            break;
        case CharacterPartShoose:
            array = [datasource arrayShoose];
            break;
        case CharacterPartSuit:
            array = [datasource arraySuits];
            break;
        default :
            break;
    }
    
    return [array objectAtIndex:index];
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

#pragma mark

- (void)saveVisualView;
{
    [[NSUserDefaults standardUserDefaults] setInteger:visualViewCap forKey:@"VV_CAP_VALUE"];
    [[NSUserDefaults standardUserDefaults] setInteger:visualViewHead forKey:@"VV_HEAD_VALUE"];
    [[NSUserDefaults standardUserDefaults] setInteger:visualViewBody forKey:@"VV_BODY_VALUE"];
    [[NSUserDefaults standardUserDefaults] setInteger:visualViewLegs forKey:@"VV_LEGS_VALUE"];
    [[NSUserDefaults standardUserDefaults] setInteger:visualViewShoose forKey:@"VV_SHOOSE_VALUE"];
    [[NSUserDefaults standardUserDefaults] setInteger:visualViewJackets forKey:@"VV_SHIRTS_VALUE"];
    [[NSUserDefaults standardUserDefaults] setInteger:visualViewGuns forKey:@"VV_GUN_VALUE"];
     [[NSUserDefaults standardUserDefaults] setInteger:visualViewSuits forKey:@"VV_SUITS_VALUE"];
    
    NSData *data= [NSKeyedArchiver archivedDataWithRootObject:arrayOfBoughtProducts];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VV_ARRAY_Bought"];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"VV_ARRAY_Bought"];
}

- (void)loadVisualView;
{
    self.visualViewCap = [[NSUserDefaults standardUserDefaults] integerForKey:@"VV_CAP_VALUE"];
    self.visualViewHead = [[NSUserDefaults standardUserDefaults] integerForKey:@"VV_HEAD_VALUE"];
    self.visualViewBody = [[NSUserDefaults standardUserDefaults] integerForKey:@"VV_BODY_VALUE"];
    self.visualViewLegs = [[NSUserDefaults standardUserDefaults] integerForKey:@"VV_LEGS_VALUE"];
    self.visualViewShoose = [[NSUserDefaults standardUserDefaults] integerForKey:@"VV_SHOOSE_VALUE"];
    self.visualViewJackets = [[NSUserDefaults standardUserDefaults] integerForKey:@"VV_SHIRTS_VALUE"];
    self.visualViewGuns = [[NSUserDefaults standardUserDefaults] integerForKey:@"VV_GUN_VALUE"];
    self.visualViewSuits = [[NSUserDefaults standardUserDefaults] integerForKey:@"VV_SUITS_VALUE"];
  
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"VV_ARRAY_Bought"];
    arrayOfBoughtProducts = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!arrayOfBoughtProducts) {
        arrayOfBoughtProducts=[[NSMutableArray alloc] init];
    }
    
    [self recountDefenseAndAtack];
}

- (BOOL)isProductBought:(NSInteger)index;{
    for (NSUInteger i = 0; i < [arrayOfBoughtProducts count]; i++) {
        NSNumber *indexProduct = [arrayOfBoughtProducts objectAtIndex:i];
        if ([indexProduct intValue]==index) {
            return YES;
        }
    }
    return NO;
}

-(void)addProductToBought:(NSInteger)index{
    NSNumber *num = [NSNumber numberWithInteger:index];
    [self.arrayOfBoughtProducts addObject:num];
    [self saveVisualView];
}
#pragma mark

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

-(void)dealloc
{
    
}
@end
