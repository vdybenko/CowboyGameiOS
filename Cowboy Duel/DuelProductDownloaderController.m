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


NSString  *const URL_PRODUCT_FILE   = @"http://bidoncd.s3.amazonaws.com/list_of_store_items_v2.2.json";
NSString  *const URL_PRODUCT_FILE_RETINEA   = @"http://bidoncd.s3.amazonaws.com/list_of_store_items_retina_v2.2.json";
NSString  *const URL_USER_PRODUCTS = @"http://v201.cowboyduel.net/store/get_buy_items_user";
NSString  *const URL_PRODUCTS_BUY = @"http://v201.cowboyduel.net/store/bought";

@interface DuelProductDownloaderController()
{
    NSMutableDictionary *dicForRequests;
    NSMutableArray *arrItemsList;
    NSMutableArray *arrDefenseSaved;
    NSMutableArray *arrWeaponSaved;
}
@end

@implementation DuelProductDownloaderController
@synthesize didFinishBlock;

-(id)init{
    self = [super init];
	
	if (!self) {
		return nil;
	}
    arrItemsList=[[NSMutableArray alloc] init];
    dicForRequests=[[NSMutableDictionary alloc] init];

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
    int _numberRevision;
    NSUserDefaults *userDef=[NSUserDefaults standardUserDefaults];
    if (![userDef objectForKey:@"SERVER_REVISION_DUEL_PRODUCT"]) {
        _numberRevision=NUMBER_REVISION_DUEL_PRODUCT_DEFAULT;
        [userDef setInteger:_numberRevision forKey:@"SERVER_REVISION_DUEL_PRODUCT"];
    }else {
        _numberRevision=[userDef integerForKey:@"SERVER_REVISION_DUEL_PRODUCT"];
    }
    
    if (serverRevision>_numberRevision){
        _numberRevision=serverRevision;
        
        [userDef setInteger:_numberRevision forKey:@"SERVER_REVISION_DUEL_PRODUCT"];
        
        return YES;
    }else {
        return NO;
    }
}

-(void) refreshDuelProducts;
{
    arrWeaponSaved = [DuelProductDownloaderController loadWeaponArray];
    arrDefenseSaved = [DuelProductDownloaderController loadDefenseArray];
    
    NSString *URL;
    if ([Utils isiPhoneRetina]) {
        URL = URL_PRODUCT_FILE_RETINEA;
    }else{
        URL = URL_PRODUCT_FILE;
    }
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [dicForRequests setObject:receivedData forKey:[theConnection.requestURL lastPathComponent]];
    }
}

-(void)parseDuelProduct:(CDDuelProduct *)product productDic:(NSDictionary*)dic;
{
    product.dID = [[dic objectForKey:@"id"] integerValue];
    product.dName=[dic objectForKey:@"title"];
    product.dDescription=[dic objectForKey:@"description"];
    
    product.dIconURL=[dic objectForKey:@"thumb"];
    if (product.dIconURL) {
        product.dIconLocal = [UIImage saveImage:[product saveNameThumb] URL:product.dIconURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
    }
    
    product.dImageURL=[dic objectForKey:@"img"];
    if (product.dImageURL) {
        product.dImageLocal = [UIImage saveImage:[product saveNameImage] URL:product.dImageURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
    }
    product.dPrice=[[dic objectForKey:@"golds"] integerValue];
    product.dPurchaseUrl=[dic objectForKey:@"inappid"];
    product.dLevelLock=[[dic objectForKey:@"levelLock"] intValue];
    
}

#pragma mark NSURLConnection handlers

- (void)connectionDidFinishLoading:(CustomNSURLConnection *)connection1 {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString * currentParseString = [NSString stringWithFormat:@"%@",connection1.requestURL];
        NSString *dictionaryKey = [currentParseString lastPathComponent];
        NSMutableData *receivedData=[dicForRequests objectForKey:dictionaryKey];
        NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        DLog(@"DuelProductDownloaderController jsonString %@",jsonString);
        
        
        if ([dictionaryKey isEqualToString:[URL_PRODUCT_FILE lastPathComponent]] || [dictionaryKey isEqualToString:[URL_PRODUCT_FILE_RETINEA lastPathComponent]]) {
//URL_PRODUCT_FILE
            NSDictionary *responseObject = ValidateObject([jsonString JSONValue], [NSDictionary class]);
            NSArray *responseObjectOfProducts = [responseObject objectForKey:@"weapons"];
            for (NSDictionary *dic in responseObjectOfProducts) {
                CDWeaponProduct *product=[[CDWeaponProduct alloc] init];
                [self parseDuelProduct:product productDic:dic];
                product.dDamage=[[dic objectForKey:@"damage"] integerValue];
                
                product.dImageGunURL=[dic objectForKey:@"bigImg"];
                if (product.dImageGunURL) {
                    product.dImageGunLocal = [UIImage saveImage:[product saveNameImageGun] URL:product.dImageGunURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
                }
                product.dSoundURL = [dic objectForKey:@"sound"];
                if (product.dSoundURL) {
                    product.dSoundLocal = [SoundDownload saveSound:[product saveNameSoundGun] URL:product.dSoundURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
                }
                
                if ([arrWeaponSaved count]!=0) {
                    product.dCountOfUse = [self checkProductForUseWithID:product.dID inArray:arrWeaponSaved];
                }
                
                [arrItemsList addObject: product];
            }
            NSLog(@"arrItemsList %@",arrItemsList);
            [DuelProductDownloaderController saveWeapon:arrItemsList];
            
            [arrItemsList removeAllObjects];
            responseObjectOfProducts = [responseObject objectForKey:@"defenses"];
            for (NSDictionary *dic in responseObjectOfProducts) {
                CDDefenseProduct *product=[[CDDefenseProduct alloc] init];
                [self parseDuelProduct:product productDic:dic];
                product.dDefense=[[dic objectForKey:@"defense"] integerValue];
                
                if ([arrDefenseSaved count]!=0) {
                    product.dCountOfUse = [self checkProductForUseWithID:product.dID inArray:arrDefenseSaved];
                }
                
                [arrItemsList addObject: product];
            }
            NSLog(@"arrItemsList %@",arrItemsList);
            [DuelProductDownloaderController saveDefense:arrItemsList];
            
            if (didFinishBlock) {
                NSError *error;
                didFinishBlock(error);
            }
        }else if ([dictionaryKey isEqualToString:[URL_USER_PRODUCTS lastPathComponent]]){
//URL_USER_PRODUCTS
            NSUInteger indexOfProductInSavedDefenseArraySaved=-1;
            NSArray *responseObjectOfProducts = ValidateObject([jsonString JSONValue], [NSArray class]);
            for (NSDictionary *dic in responseObjectOfProducts) {
                NSInteger idProduct = [[dic objectForKey:@"itemIdStore"] integerValue];
                
                NSUInteger indexOfProductInSavedWeaponArray=[[AccountDataSource sharedInstance] findObs](arrWeaponSaved,idProduct);
                if (indexOfProductInSavedWeaponArray != NSNotFound) {
                    CDWeaponProduct *product=[arrWeaponSaved objectAtIndex:indexOfProductInSavedWeaponArray];
                    product.dCountOfUse = 1;
                    [arrWeaponSaved replaceObjectAtIndex:indexOfProductInSavedWeaponArray withObject:product];
                }else{
                    NSUInteger indexOfProductInSavedDefenseArray=[[AccountDataSource sharedInstance] findObs](arrDefenseSaved,idProduct);
                    
                    if (indexOfProductInSavedDefenseArray != NSNotFound) {
                        CDDefenseProduct *product=[arrDefenseSaved objectAtIndex:indexOfProductInSavedDefenseArray];
                        if (indexOfProductInSavedDefenseArray == indexOfProductInSavedDefenseArraySaved) {
                            product.dCountOfUse += 1;
                        }else{
                            if (product.dCountOfUse == 0) {
                                product.dCountOfUse += 1;
                            }else{
                                product.dCountOfUse = 1;
                            }
                        }
                        [arrDefenseSaved replaceObjectAtIndex:indexOfProductInSavedDefenseArray withObject:product];
                        [DuelProductDownloaderController saveDefense:arrDefenseSaved];
                        indexOfProductInSavedDefenseArraySaved = indexOfProductInSavedDefenseArray;
                    }
                }
            }
            [DuelProductDownloaderController saveWeapon:arrWeaponSaved];
            [DuelProductDownloaderController saveDefense:arrDefenseSaved];
            
            if (didFinishBlock) {
                NSError *error;
                didFinishBlock(error);
            }
        }else if ([dictionaryKey isEqualToString:[URL_PRODUCTS_BUY lastPathComponent]]){
//URL_PRODUCTS_BUY
            if (didFinishBlock) {
                NSError *error;
                didFinishBlock(error);
            }
        }
        didFinishBlock = nil;
    });
}

- (void)connection:(CustomNSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString * currentParseString = [NSString stringWithFormat:@"%@",connection.requestURL];
    NSMutableData *receivedData=[dicForRequests objectForKey:[currentParseString lastPathComponent]];
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{  
    DLog(@"DuelProductDownloaderController Connection failed! Error - %@ %@",
         [error localizedDescription],
         [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    if (didFinishBlock) {
        didFinishBlock(error);
    }
}

#pragma mark

+(void)saveWeapon:(NSArray*)array;
{
    NSData *data= [NSKeyedArchiver archivedDataWithRootObject:array];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DUEL_PRODUCTS_WEAPONS];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:DUEL_PRODUCTS_WEAPONS];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

#pragma mark user products

-(BOOL)isListProductsAvailable;
{
    arrWeaponSaved = [DuelProductDownloaderController loadWeaponArray];
    if ([arrWeaponSaved count]) {
         return YES;
    }else{
        return NO;
    }
}

-(void)refreshUserDuelProducts;
{
    arrDefenseSaved = [DuelProductDownloaderController loadDefenseArray];
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_USER_PRODUCTS]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    [theRequest setHTTPMethod:@"POST"];
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                           [AccountDataSource sharedInstance].accountID,@"authentification",
                           nil];
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]];
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [dicForRequests setObject:receivedData forKey:[theConnection.requestURL lastPathComponent]];
    }
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
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        NSMutableData *receivedData = [[NSMutableData alloc] init];
        [dicForRequests setObject:receivedData forKey:[theConnection.requestURL lastPathComponent]];
    }
}

#pragma mark

-(void)dealloc
{
    dicForRequests = nil;
    arrItemsList = nil;
    arrDefenseSaved = nil;
    arrWeaponSaved = nil;
}

@end
