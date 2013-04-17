//
//  DuelProductDownloaderController.m
//  Cowboy Duels
//
//  Created by Taras on 24.10.12.
//
//

#import "DuelProductDownloaderController.h"
#import "JSON.h"
#import "ValidationUtils.h"
#import "Utils.h"
#import "UIImage+Save.h"
#import "SoundDownload.h"
#import "Utils.h"
#import "CustomNSURLConnection.h"
#import "AccountDataSource.h"

NSMutableData *responseData;

NSString  *const URL_PRODUCT_FILE   = @BASE_S3_URL"list_of_store_items_v2.2.json";
NSString  *const URL_PRODUCT_FILE_RETINEA   = @BASE_S3_URL"list_of_store_items_retina_v2.2.json";
NSString  *const URL_USER_PRODUCTS = @BASE_URL"store/get_buy_items_user";
NSString  *const URL_PRODUCTS_BUY = @BASE_URL"store/bought";

static BOOL isRefreshingNow;

@interface DuelProductDownloaderController()
{
    NSMutableDictionary *dicForRequests;
    NSMutableArray *arrDefenseSaved;
    NSMutableArray *arrItems;
    NSMutableArray *arrWeaponSaved;
    NSMutableArray *arrBarrierSaved;
}
@end

static int numberRevision;

@implementation DuelProductDownloaderController
@synthesize didFinishBlock;
@synthesize delegate;

-(id)init{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    dicForRequests=[NSMutableDictionary dictionary];
    arrDefenseSaved = [NSMutableArray array];
    arrWeaponSaved = [NSMutableArray array];
    arrBarrierSaved = [NSMutableArray array];
    
    arrItems = [NSMutableArray array];
    return self;
}

+(NSString *)getSavePathForDuelProduct{
    return getSavePathForDuelProduct();
}

static NSString *getSavePathForDuelProduct()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathToDirectory=[NSString stringWithFormat:@"%@/duelProduct",[paths objectAtIndex:0]];
    return pathToDirectory;
}

+(BOOL) isRefreshEvailable:(int)serverRevision;
{
    if (serverRevision == NSNotFound && !isRefreshingNow) {
        return YES;
    }else {
        return NO;
    }
    
    numberRevision = [DuelProductDownloaderController getDeviceRevision];
    
    if (serverRevision>numberRevision && !isRefreshingNow){
        numberRevision=serverRevision;
        return YES;
    }else {
        return NO;
    }
}

+(int) getDeviceRevision;
{
    int number;
    NSUserDefaults *userDef=[NSUserDefaults standardUserDefaults];
    if (![userDef objectForKey:@"SERVER_REVISION_DUEL_PRODUCT"]) {
        number=NUMBER_REVISION_DUEL_PRODUCT_DEFAULT;
    }else {
        number=[userDef integerForKey:@"SERVER_REVISION_DUEL_PRODUCT"];
    }
    
    return number;
}

#pragma mark user products

-(void) refreshDuelProducts;
{
    isRefreshingNow = YES;
    
    NSString *URL;
    if ([Utils isiPhoneRetina]) {
        URL = URL_PRODUCT_FILE_RETINEA;
    }else{
        URL = URL_PRODUCT_FILE;
    }
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    [NSURLConnection
     sendAsynchronousRequest:theRequest
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         if ([data length] >0 && error == nil)
         {
             NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             [self parsingResultDuelProduct:jsonString];
         }
         else if ([data length] == 0 && error == nil)
         {
             DLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             DLog(@"DuelProductDownloaderController Connection failed! Error - %@ %@",
                  [error localizedDescription],
                  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
             if (didFinishBlock) {
                 didFinishBlock(error);
             }
             
             DuelProductDownloaderType type = DuelProductDownloaderTypeDuelProduct;
             
             if (delegate) {
                 [delegate didFinishDownloadWithType:type error:error];
             }
             
             isRefreshingNow = NO;
         }
     }];
}

-(BOOL)isListProductsAvailable;
{
    arrWeaponSaved = [DuelProductDownloaderController loadDefenseArray];
    if ([arrWeaponSaved count]) {
        return YES;
    }else{
        return NO;
    }
}

-(void)refreshUserDuelProducts;
{
    arrDefenseSaved = [DuelProductDownloaderController loadDefenseArray];
    arrWeaponSaved = [DuelProductDownloaderController loadWeaponArray];
    arrBarrierSaved = [DuelProductDownloaderController loadBarrierArray];
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_USER_PRODUCTS]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    [theRequest setHTTPMethod:@"POST"];
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                           [AccountDataSource sharedInstance].accountID,@"authentification",
                           nil];
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection
     sendAsynchronousRequest:theRequest
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         if ([data length] >0 && error == nil)
         {
             NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             [self parsingResultUserProduct:jsonString];
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             DLog(@"DuelProductDownloaderController Connection failed! Error - %@ %@",
                  [error localizedDescription],
                  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
             if (didFinishBlock) {
                 didFinishBlock(error);
             }
             DuelProductDownloaderType type = DuelProductDownloaderTypeUserProduct;
             if (delegate) {
                 [delegate didFinishDownloadWithType:type error:error];
             }
             
             isRefreshingNow = NO;
         }
     }];
}

-(void)buyProductID:(int)productId transactionID:(int)transactionID;
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PRODUCTS_BUY]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    [theRequest setHTTPMethod:@"POST"];
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                           [AccountDataSource sharedInstance].accountID,@"authentification",
                           [NSString stringWithFormat:@"%d",productId],@"itemId",
                           [NSString stringWithFormat:@"%d",transactionID],@"transactionsId",
                           nil];
    
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection
     sendAsynchronousRequest:theRequest
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         if ([data length] >0 && error == nil)
         {
             [self parsingResultBuyProduct];
         }
         else if ([data length] == 0 && error == nil)
         {
             DLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             DLog(@"DuelProductDownloaderController Connection failed! Error - %@ %@",
                  [error localizedDescription],
                  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
             if (didFinishBlock) {
                 didFinishBlock(error);
             }
             
             DuelProductDownloaderType type = DuelProductDownloaderTypeBuyProduct;
             
             if (delegate) {
                 [delegate didFinishDownloadWithType:type error:error];
             }
             
             isRefreshingNow = NO;
         }
         
     }];
    
}

#pragma mark

-(void)parseDuelProduct:(CDDuelProduct *)product productDic:(NSDictionary*)dic;
{
    product.dID = [[dic objectForKey:@"id"] integerValue];
    product.dName=[dic objectForKey:@"title"];
    product.dDescription=[dic objectForKey:@"description"];
    
    product.dIconURL=[dic objectForKey:@"thumb"];
    if (product.dIconURL) {
        product.dIconLocal = [UIImage saveImage:[product.dIconURL lastPathComponent] URL:product.dIconURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
    }
    
    product.dImageURL=[dic objectForKey:@"img"];
    if (product.dImageURL && ![product.dImageURL isKindOfClass:[NSNull class]]) {
        product.dImageLocal = [UIImage saveImage:[product.dImageURL lastPathComponent] URL:product.dImageURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
    }
    product.dPrice=[[dic objectForKey:@"golds"] integerValue];
    product.dPurchaseUrl=[dic objectForKey:@"inappid"];
    product.dLevelLock=[[dic objectForKey:@"levelLock"] intValue];
    
}

#pragma mark NSURLConnection handlers

- (void)connectionDidFinishLoading:(CustomNSURLConnection *)connection1 {
    
    [connection1 cancel];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString * currentParseString = [NSString stringWithFormat:@"%@",connection1.requestURL];
        NSString *dictionaryKey = [currentParseString lastPathComponent];
        NSMutableData *receivedData=[dicForRequests objectForKey:dictionaryKey];
        NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        DLog(@"DuelProductDownloaderController jsonString %@",jsonString);
        
        if ([dictionaryKey isEqualToString:[URL_PRODUCT_FILE lastPathComponent]] || [dictionaryKey isEqualToString:[URL_PRODUCT_FILE_RETINEA lastPathComponent]]) {
            //URL_PRODUCT_FILE
            [self parsingResultDuelProduct:jsonString];
        }else if ([dictionaryKey isEqualToString:[URL_USER_PRODUCTS lastPathComponent]]){
            //URL_USER_PRODUCTS
            [self parsingResultUserProduct:jsonString];
        }else if ([dictionaryKey isEqualToString:[URL_PRODUCTS_BUY lastPathComponent]]){
            //URL_PRODUCTS_BUY
            [self parsingResultBuyProduct];
        }
        
    });
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
    [connection cancel];
    DLog(@"DuelProductDownloaderController Connection failed! Error - %@ %@",
         [error localizedDescription],
         [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    if (didFinishBlock) {
        didFinishBlock(error);
    }
    
    NSString * currentParseString = [NSString stringWithFormat:@"%@",connection.requestURL];
    NSString *dictionaryKey = [currentParseString lastPathComponent];
    DuelProductDownloaderType type;
    if ([dictionaryKey isEqualToString:[URL_PRODUCT_FILE lastPathComponent]] || [dictionaryKey isEqualToString:[URL_PRODUCT_FILE_RETINEA lastPathComponent]]) {
        type = DuelProductDownloaderTypeDuelProduct;
    }else if ([dictionaryKey isEqualToString:[URL_USER_PRODUCTS lastPathComponent]]){
        type = DuelProductDownloaderTypeUserProduct;
    }else if ([dictionaryKey isEqualToString:[URL_PRODUCTS_BUY lastPathComponent]]){
        type = DuelProductDownloaderTypeBuyProduct;
    }
    
    if (delegate) {
        [delegate didFinishDownloadWithType:type error:error];
    }
    
    isRefreshingNow = NO;
}

#pragma mark Parsing Result

-(void)parsingResultDuelProduct:(NSString *)jsonString;
{
    NSDictionary *responseObject = ValidateObject([jsonString JSONValue], [NSDictionary class]);
    NSArray *responseObjectOfProducts = [responseObject objectForKey:@"weapons"];
    NSMutableArray *arrayIDProducts = [NSMutableArray array];
    [arrItems removeAllObjects];
    for (NSDictionary *dic in responseObjectOfProducts) {
        CDWeaponProduct *product=[[CDWeaponProduct alloc] init];
        [self parseDuelProduct:product productDic:dic];
        product.dDamage=[[dic objectForKey:@"damage"] integerValue];
        
        product.dImageGunURL=[dic objectForKey:@"bigImg"];
        if (product.dImageGunURL) {
            product.dImageGunLocal = [UIImage saveImage:[product.dImageGunURL lastPathComponent] URL:product.dImageGunURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
        }
        product.dSoundURL = [dic objectForKey:@"sound"];
        if (product.dSoundURL) {
            product.dSoundLocal = [SoundDownload saveSound:[product.dSoundURL lastPathComponent] URL:product.dSoundURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
        }
        
        if ([arrWeaponSaved count]!=0) {
            product.dCountOfUse = [self checkProductForUseWithID:product.dID inArray:arrWeaponSaved];
        }
        
        if (product.dPrice == 0) {
            [arrayIDProducts addObject:product.dPurchaseUrl];
        }
        
        product.dFrequently = [[dic objectForKey:@"frequently"] floatValue];
        [arrItems addObject: product];
    }
    [DuelProductDownloaderController saveWeapon:arrItems];
    arrWeaponSaved = arrItems;
    
    [arrItems removeAllObjects];
    responseObjectOfProducts = [responseObject objectForKey:@"defenses"];
    for (NSDictionary *dic in responseObjectOfProducts) {
        CDDefenseProduct *product=[[CDDefenseProduct alloc] init];
        [self parseDuelProduct:product productDic:dic];
        product.dDefense=[[dic objectForKey:@"defense"] integerValue];
        
        if ([arrDefenseSaved count]!=0) {
            product.dCountOfUse = [self checkProductForUseWithID:product.dID inArray:arrDefenseSaved];
        }
        
        if (product.dPrice == 0) {
            [arrayIDProducts addObject:product.dPurchaseUrl];
        }
        [arrItems addObject: product];
    }
    [DuelProductDownloaderController saveDefense:arrItems];
    
    arrDefenseSaved = arrItems;
    
    [arrItems removeAllObjects];
    responseObjectOfProducts = [responseObject objectForKey:@"barrier"];
    for (NSDictionary *dic in responseObjectOfProducts) {
        CDBarrierDuelProduct *product=[[CDBarrierDuelProduct alloc] init];
        [self parseDuelProduct:product productDic:dic];
        product.dType=[[dic objectForKey:@"type"] integerValue];
        
        if ([arrBarrierSaved count]!=0) {
            product.dCountOfUse = [self checkProductForUseWithID:product.dID inArray:arrBarrierSaved];
        }
        
        if (product.dPrice == 0) {
            [arrayIDProducts addObject:product.dPurchaseUrl];
        }
        [arrItems addObject: product];
    }
    [DuelProductDownloaderController saveBarrier:arrItems];
    
    arrBarrierSaved = arrItems;
    
    
    if ([arrayIDProducts count]!=0) {
        [self requestProductDataWithNSSet:arrayIDProducts];
    }
    
    [self refreshUserDuelProducts];
    
}

-(void)parsingResultUserProduct:(NSString *)jsonString;
{
    NSArray *responseObjectOfProducts = ValidateObject([jsonString JSONValue], [NSArray class]);
    AccountDataSource *playerAccount=[AccountDataSource sharedInstance];
    NSUInteger indexOfProductInSavedDefenseArraySaved=-1;
    
    for (NSDictionary *dic in responseObjectOfProducts) {
        NSInteger idProduct = [[dic objectForKey:@"itemIdStore"] integerValue];
        
        NSUInteger indexOfProductInSavedWeaponArray=[[AccountDataSource sharedInstance] findObsByID](arrWeaponSaved,idProduct);
        if (indexOfProductInSavedWeaponArray != NSNotFound) {
            CDWeaponProduct *product=[arrWeaponSaved objectAtIndex:indexOfProductInSavedWeaponArray];
            product.dCountOfUse = 1;
            [arrWeaponSaved replaceObjectAtIndex:indexOfProductInSavedWeaponArray withObject:product];
            
            if (playerAccount.accountWeapon.dDamage < product.dDamage) {
                playerAccount.accountWeapon = product;
                playerAccount.curentIdWeapon = product.dID;
            }
        }else{
            NSUInteger indexOfProductInSavedDefenseArray=[[AccountDataSource sharedInstance] findObsByID](arrDefenseSaved,idProduct);
            
            if (indexOfProductInSavedDefenseArray != NSNotFound) {
                CDDefenseProduct *product=[arrDefenseSaved objectAtIndex:indexOfProductInSavedDefenseArray];
                if (indexOfProductInSavedDefenseArray == indexOfProductInSavedDefenseArraySaved) {
                    product.dCountOfUse += 1;
                    playerAccount.accountDefenseValue += product.dDefense;
                }else{
                    if (product.dCountOfUse == 0) {
                        product.dCountOfUse += 1;
                        playerAccount.accountDefenseValue += product.dDefense;
                    }else{
                        product.dCountOfUse = 1;
                        playerAccount.accountDefenseValue += product.dDefense;
                    }
                }
                [arrDefenseSaved replaceObjectAtIndex:indexOfProductInSavedDefenseArray withObject:product];
                [DuelProductDownloaderController saveDefense:arrDefenseSaved];
                indexOfProductInSavedDefenseArraySaved = indexOfProductInSavedDefenseArray;
            }
        }
    }
    [playerAccount saveWeapon];
    [playerAccount saveDefense];
    [DuelProductDownloaderController saveWeapon:arrWeaponSaved];
    [DuelProductDownloaderController saveDefense:arrDefenseSaved];
    
    NSError *error;
    if (didFinishBlock) {
        didFinishBlock(error);
    }
    didFinishBlock = nil;
    if (delegate) {
        [delegate didFinishDownloadWithType:DuelProductDownloaderTypeUserProduct error:error];
    }
    isRefreshingNow = NO;
    
    [[NSUserDefaults standardUserDefaults] setInteger:numberRevision forKey:@"SERVER_REVISION_DUEL_PRODUCT"];
    DLog(@"parsingResultUserProduct refresh complite");
}

-(void)parsingResultBuyProduct;
{
    NSError *error;
    if (didFinishBlock) {
        didFinishBlock(error);
    }
    didFinishBlock = nil;
    if (delegate) {
        [delegate didFinishDownloadWithType:DuelProductDownloaderTypeBuyProduct error:error];
    }
    
    isRefreshingNow = NO;
}

#pragma mark

+(void)saveWeapon:(NSArray*)array;
{
    NSMutableArray *arrayForSave = [NSMutableArray array];
    if (![self loadWeaponArray]) {
        CDWeaponProduct *product = [self defaultWeaponForPlayer];
        [arrayForSave addObject:product];
    }else{
        CDWeaponProduct *product = [array objectAtIndex:0];
        if (product.dID!=-1) {
            CDWeaponProduct *product = [self defaultWeaponForPlayer];
            [arrayForSave insertObject:product atIndex:0];
        }
    }
    [arrayForSave addObjectsFromArray:array];
    
    NSData *data= [NSKeyedArchiver archivedDataWithRootObject:arrayForSave];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DUEL_PRODUCTS_WEAPONS];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:DUEL_PRODUCTS_WEAPONS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(CDWeaponProduct*)defaultWeaponForPlayer
{
    CDWeaponProduct *product=[[CDWeaponProduct alloc] init];
    product.dID = -1;
    product.dName=@"Pepperbox";
    product.dDescription=@"Pepperbox";
    product.dPrice=0;
    product.dPurchaseUrl=nil;
    product.dLevelLock=0;
    product.dCountOfUse=1;
    product.dFrequently = 0.4f;
    return product;
}

+(NSMutableArray*)loadWeaponArray;
{
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:DUEL_PRODUCTS_WEAPONS];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data1];
}

+(void)saveDefense:(NSArray*)array;
{
    NSData *data= [NSKeyedArchiver archivedDataWithRootObject:array];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DUEL_PRODUCTS_DEFENSES];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:DUEL_PRODUCTS_DEFENSES];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSMutableArray*)loadDefenseArray;
{
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:DUEL_PRODUCTS_DEFENSES];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data1];
}

+(void)saveBarrier:(NSArray*)array;
{
    NSData *data= [NSKeyedArchiver archivedDataWithRootObject:array];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DUEL_PRODUCTS_BARRIER];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:DUEL_PRODUCTS_BARRIER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSMutableArray*)loadBarrierArray;
{
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:DUEL_PRODUCTS_BARRIER];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data1];
}

#pragma mark

-(NSInteger)checkProductForUseWithID:(NSInteger)idValue inArray:(NSArray*)array;
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.dID = %d",idValue];
    NSArray *results = [array filteredArrayUsingPredicate:predicate];
    if ([results count]==0) {
        return 0;
    }else{
        CDDuelProduct *product = [results objectAtIndex:0];
        return product.dCountOfUse;
    }
}

#pragma mark SKProductsRequestDelegate
- (void) requestProductDataWithNSSet:(NSMutableArray*)arrayProducts
{
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:arrayProducts]];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableArray *array = [NSMutableArray array];
        [array addObjectsFromArray:response.products];
        
        NSMutableArray *arrWeapon = [DuelProductDownloaderController loadWeaponArray];
        NSMutableArray *arrDefense = [DuelProductDownloaderController loadDefenseArray];
        
        for(int i=0;i<[array count];i++)
        {
            SKProduct *productPurches = [array objectAtIndex:i];
            NSString *priceType = [[productPurches priceLocale] objectForKey:NSLocaleCurrencySymbol];
            
            NSUInteger indexOfProductInSavedWeaponArray=[[AccountDataSource sharedInstance] findObsByPurchase](arrWeapon,[productPurches productIdentifier]);
            if (indexOfProductInSavedWeaponArray != NSNotFound) {
                CDWeaponProduct *product=[arrWeapon objectAtIndex:indexOfProductInSavedWeaponArray];
                product.dPurchasePrice = [NSString stringWithFormat:@"%.2f%@",[[productPurches price] doubleValue],priceType];
                [arrWeapon replaceObjectAtIndex:indexOfProductInSavedWeaponArray withObject:product];
            }else{
                NSUInteger indexOfProductInSavedDefenseArray=[[AccountDataSource sharedInstance] findObsByPurchase](arrDefense,[productPurches productIdentifier]);
                if (indexOfProductInSavedDefenseArray != NSNotFound){
                    CDDefenseProduct *product=[arrDefense objectAtIndex:indexOfProductInSavedDefenseArray];
                    product.dPurchasePrice = [NSString stringWithFormat:@"%.2f%@",[[productPurches price] doubleValue],priceType];
                    [arrDefense replaceObjectAtIndex:indexOfProductInSavedDefenseArray withObject:product];
                }
            }
        }
        
        [DuelProductDownloaderController saveWeapon:arrWeapon];
        [DuelProductDownloaderController saveDefense:arrDefense];
    });
}

#pragma mark

-(void)dealloc
{
    dicForRequests = nil;
    arrDefenseSaved = nil;
    arrWeaponSaved = nil;
    arrItems = nil;
}

@end