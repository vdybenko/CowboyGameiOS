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

NSMutableData *responseData;


NSString  *const URL_PRODUCT_FILE_DEFULT   = @"http://bidoncd.s3.amazonaws.com/list_of_store_items_v2.2.scriptJson";

@interface DuelProductDownloaderController()
{
    NSMutableData *responseData;
    NSMutableArray *arrItemsList;
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
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PRODUCT_FILE_DEFULT]
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
            product.dImageLocal = [UIImage saveImage:[product saveNameImage] URL:product.dIconURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
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
                product.dIconLocal = [UIImage saveImage:[product saveNameImageGun] URL:product.dIconURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
            }
        }
        
        product.dSoundURL = [dic objectForKey:@"sound"];
        if (product.dSoundURL) {
            NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.mp3",[DuelProductDownloaderController getSavePathForDuelProduct],[product saveNameSoundGun]];
            if (![UIImage isFileDownloadedForPath:pngFilePath]) {
                product.dIconLocal = [SoundDownload saveSound:[product saveNameSoundGun] URL:product.dSoundURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
            }
        }
        [arrItemsList addObject: product];
    }
    NSData *data= [NSKeyedArchiver archivedDataWithRootObject:arrItemsList];
    NSLog(@"arrItemsList %@",arrItemsList);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DUEL_PRODUCTS_WEAPONS];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:DUEL_PRODUCTS_WEAPONS];
    
    [arrItemsList removeAllObjects];
    responseObjectOfProducts = [responseObject objectForKey:@"defenses"];
    for (NSDictionary *dic in responseObjectOfProducts) {
        CDDefenseProduct *product=[[CDDefenseProduct alloc] init];
        [self parseDuelProduct:product productDic:dic];
        product.dDefense=[[dic objectForKey:@"defense"] integerValue];
        [arrItemsList addObject: product];
    }
    data= [NSKeyedArchiver archivedDataWithRootObject:arrItemsList];
    NSLog(@"arrItemsList %@",arrItemsList);

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DUEL_PRODUCTS_DEFENSES];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:DUEL_PRODUCTS_DEFENSES];

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

@end
