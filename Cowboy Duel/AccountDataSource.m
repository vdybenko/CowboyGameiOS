#import "AccountDataSource.h"
#import "CustomNSURLConnection.h"
#import "Utils.h"
#import "OGHelper.h"

static const char *POST_TRANS_URL =  BASE_URL"api/transactions";
static const char *POST_DUEL_URL =  BASE_URL"api/duels";

@interface AccountDataSource(){
  NSMutableDictionary *dicForRequests;
}
@end

@implementation AccountDataSource

@synthesize money, accountName, teachingTimes, finalInfoTable, sessionID, accountID, accountDataSourceID, transactions, duels, achivments , glNumber,
 accountLevel,accountPoints,accountWins,accountDraws,accountBigestWin,removeAds,avatar,age,homeTown,friends,facebookName;

#pragma mark

static AccountDataSource *sharedHelper = nil;
+ (AccountDataSource *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[AccountDataSource alloc] initWithLocalPlayer];
    }
    return sharedHelper;
}

<<<<<<< HEAD
-(int)stringToInt:(NSString *)string
{
    NSMutableString *tempString = [NSMutableString stringWithCapacity:10];
    for (int i = 0; i < 2; i++) {
        DLog(@"%u", (int)[string characterAtIndex:i]);
        [tempString appendString:[NSString stringWithFormat:@"%u", (int)[string characterAtIndex:i]]];
    }
    return [tempString intValue];
}

-(int)crypt:(int)secret_int
{
    DLog(@"sessionID %@",sessionID);
    return secret_int ^ [self stringToInt:sessionID];
}


=======
>>>>>>> refs/heads/refactor_AccountDataSource
-(id)initWithLocalPlayer;
{
    self.accountName=@"Anonymous";
    money = 200;
    teachingTimes = [[NSMutableArray alloc] init];
    finalInfoTable = [[NSMutableArray alloc] init];
    [self makeLocalAccountID ];
    accountDataSourceID = 1;
    sessionID=0;
    self.accountLevel=0;
    self.accountPoints=0;
    self.accountWins=0;
    self.accountDraws=0;
    self.accountBigestWin=0;
    self.removeAds=0;
    
    self.avatar=nil;
    self.age=@"";
    self.homeTown=@"";
    self.friends=0;
    self.facebookName=@"";
    
    transactions = [[NSMutableArray alloc] init];
    duels = [[NSMutableArray alloc] init];
    achivments = [[NSMutableArray alloc] init];
    dicForRequests=[[NSMutableDictionary alloc] init];

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
  
  self.avatar = [uDef stringForKey:@"avatar"];
  self.age = [uDef stringForKey:@"age"];
  self.homeTown = [uDef stringForKey:@"homeTown"];
  self.friends = [uDef integerForKey:@"friends"];
  self.facebookName = [uDef stringForKey:@"facebook_name"];
  
  if(![uDef stringForKey:@"deviceType"])
    [uDef setObject:ValidateObject([[StartViewController sharedInstance] deviceType], [NSString class]) forKey:@"deviceType"];
  
  if(self.money<0){
    self.money=0;
  }
  [uDef setObject:ValidateObject(self.accountID, [NSString class]) forKey:@"id"];
  
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
  CDTransaction *localTransaction = [self.transactions lastObject];
  self.glNumber = localTransaction.trLocalID;  
  
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
<<<<<<< HEAD
    
    DLog(@"AccountDataSource: New actions: %@", resultStr);
	
    //NSString *gcAlias = [[NSUserDefaults standardUserDefaults] stringForKey:@"name"];
=======

>>>>>>> refs/heads/refactor_AccountDataSource
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
<<<<<<< HEAD
    DLog(@"dicBody %@",dicBody);
=======
>>>>>>> refs/heads/refactor_AccountDataSource
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
<<<<<<< HEAD
    
    DLog(@"actions = %d", n);
    
=======
        
>>>>>>> refs/heads/refactor_AccountDataSource
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:n];
    
    for (int i = 0; i < n; i++) {
        NSMutableDictionary *reason = [NSMutableDictionary dictionary];
        CDTransaction *transaction = [array objectAtIndex:i];
        [reason setObject: [NSNumber numberWithInt:[self crypt:[transaction.trMoneyCh intValue]]] forKey:@"transaction_id"];
        [reason setObject:transaction.trDescription forKey:@"description"];
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
        [reason setObject:duel.dGps forKey:@"gps"];
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
    
<<<<<<< HEAD
    
    DLog(@"\n"
=======
    NSLog(@"\n"
>>>>>>> refs/heads/refactor_AccountDataSource
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
<<<<<<< HEAD
    
    DLog(@"AccountDataSource jsonValues %@",responseObject);
    
    DLog(@"err_des %@", ValidateObject([responseObject objectForKey:@"err_desc"], [NSString class]));
=======
        
    NSLog(@"err_des %@", ValidateObject([responseObject objectForKey:@"err_desc"], [NSString class]));
>>>>>>> refs/heads/refactor_AccountDataSource
    
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
    if([responseObject objectForKey:@"money"])
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
    NSMutableData *receivedData=[dicForRequests objectForKey:[currentParseString lastPathComponent]];
    [receivedData appendData:data];
}

- (void)connection:(CustomNSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kCheckfFBLoginSession
                                                        object:self
                                                      userInfo:nil];
<<<<<<< HEAD
    // inform the user
    DLog(@"AccountDataSource Connection failed! Error - %@ %@",
=======
    NSLog(@"AccountDataSource Connection failed! Error - %@ %@",
>>>>>>> refs/heads/refactor_AccountDataSource
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
    [[NSUserDefaults standardUserDefaults] setObject:ValidateObject(self.accountName, [NSString class]) forKey:@"avatar"];
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
    [[NSUserDefaults standardUserDefaults] setObject:ValidateObject([[StartViewController sharedInstance] deviceType], [NSString class]) forKey:@"deviceType"];
}

@end
