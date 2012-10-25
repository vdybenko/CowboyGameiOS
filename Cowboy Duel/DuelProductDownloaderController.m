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

NSMutableData *responseData;


NSString  *const URL_PRODUCT_FILE_DEFULT   = @"http://bidoncd.s3.amazonaws.com/list_of_store_items.scriptJson";
NSString  *const DUEL_PRODUCTS = @"DUEL_PRODUCT_LIST";

@interface DuelProductDownloaderController()
{
    NSMutableData *responseData;
    NSMutableArray *arrItemsList;
}
@end

@implementation DuelProductDownloaderController

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

-(void) refreshContent;
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_PRODUCT_FILE_DEFULT]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        responseData = [[NSMutableData alloc] init];
    }
}

#pragma mark NSURLConnection handlers

- (void)connectionDidFinishLoading:(NSURLConnection *)connection1 {
    NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    DLog(@"DuelProductDownloaderController jsonString %@",jsonString);
    NSArray *responseObject = ValidateObject([jsonString JSONValue], [NSArray class]);
    for (NSDictionary *dic in responseObject) {
        CDDuelProduct *product=[[CDDuelProduct alloc] init];
        product.dName=[dic objectForKey:@"name"];
        product.dDescription=[dic objectForKey:@"description"];
        product.dIconURL=[dic objectForKey:@"IconURL"];
        
        NSString *nameFile=[NSString stringWithFormat:@"%@.png",product.dName];
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",[DuelProductDownloaderController getSavePathForDuelProduct],nameFile];
        if (![UIImage isImageDownloadedForPathToImage:pngFilePath]) {
            product.dIconLocal = [UIImage saveImage:product.dName URL:product.dIconURL directory:[DuelProductDownloaderController getSavePathForDuelProduct]];
        }
        
        product.dPrice=[[dic objectForKey:@"Price"] integerValue];
        product.dPurchaseUrl=[dic objectForKey:@"PurcheseUrl"];
        [arrItemsList addObject: product];
    }
    NSData *data= [NSKeyedArchiver archivedDataWithRootObject:arrItemsList];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DUEL_PRODUCTS];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:DUEL_PRODUCTS];
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
}

@end
