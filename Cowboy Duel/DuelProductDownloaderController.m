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

NSMutableData *responseData;


NSString  *const URL_PRODUCT_FILE   = @"http://bidoncd.s3.amazonaws.com/list_of_store_items_v2.2.json";
NSString  *const URL_PRODUCT_FILE_RETINEA   = @"http://bidoncd.s3.amazonaws.com/list_of_store_items_v2.2.json";


@interface DuelProductDownloaderController()
{
    NSMutableData *responseData;
    NSMutableArray *arrItemsList;
    NSArray *arrDefenseSaved;
    NSArray *arrWeaponSaved;
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
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        responseData = [[NSMutableData alloc] init];
    }
}

-(void)parseDuelProduct:(CDDuelProduct *)product productDic:(NSDictionary*)dic;
{
    product.dID = [[dic objectForKey:@"id"] integerValue];
    product.dName=[dic objectForKey:@"title"];
    product.dDescription=[dic objectForKey:@"description"];
    
    product.dIconURL=[dic objectForKey:@"thumb"];
    if (product.dIconURL) {
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png",[DuelProductDownloaderController getSavePathForDuelProduct],[product saveNameThumb]];
        if (![UIImage isFileDownloadedForPath:pngFilePath]) {
            product.dIconLocal = [UIImage saveImage:[product saveNameThumb] URL:product.dIconURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
        }
    }
    
    product.dImageURL=[dic objectForKey:@"img"];
    if (product.dImageURL) {
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png",[DuelProductDownloaderController getSavePathForDuelProduct],[product saveNameImage]];
        if (![UIImage isFileDownloadedForPath:pngFilePath]) {
            product.dImageLocal = [UIImage saveImage:[product saveNameImage] URL:product.dImageURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
        }
    }
    product.dPrice=[[dic objectForKey:@"golds"] integerValue];
    product.dPurchaseUrl=[dic objectForKey:@"inappid"];
    
}

#pragma mark NSURLConnection handlers

- (void)connectionDidFinishLoading:(NSURLConnection *)connection1 {
    NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    DLog(@"DuelProductDownloaderController jsonString %@",jsonString);
    NSDictionary *responseObject = ValidateObject([jsonString JSONValue], [NSDictionary class]);
    
    NSArray *responseObjectOfProducts = [responseObject objectForKey:@"weapons"];
    for (NSDictionary *dic in responseObjectOfProducts) {
        CDWeaponProduct *product=[[CDWeaponProduct alloc] init];
        [self parseDuelProduct:product productDic:dic];
        product.dDamage=[[dic objectForKey:@"damage"] integerValue];
        
        product.dImageGunURL=[dic objectForKey:@"bigImg"];
        if (product.dImageGunURL) {
            NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png",[DuelProductDownloaderController getSavePathForDuelProduct],[product saveNameImageGun]];
            if (![UIImage isFileDownloadedForPath:pngFilePath]) {
                product.dImageGunLocal = [UIImage saveImage:[product saveNameImageGun] URL:product.dImageGunURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
            }
        }
        
        product.dSoundURL = [dic objectForKey:@"sound"];
        if (product.dSoundURL) {
            NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.mp3",[DuelProductDownloaderController getSavePathForDuelProduct],[product saveNameSoundGun]];
            if (![UIImage isFileDownloadedForPath:pngFilePath]) {
                product.dSoundLocal = [SoundDownload saveSound:[product saveNameSoundGun] URL:product.dSoundURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
            }
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
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
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

@end
