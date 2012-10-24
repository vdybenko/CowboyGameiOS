//
//  DuelProductDownloaderController.h
//  Cowboy Duels
//
//  Created by Taras on 24.10.12.
//
//

#import <Foundation/Foundation.h>
#import "CDDuelProduct.h"

NSString  *const DUEL_PRODUCT_LIST = @"DUEL_PRODUCT_LIST";

@interface DuelProductDownloaderController : NSObject
+(BOOL) isRefreshEvailable:(int)serverRevision;
-(void) refreshDuelProduct;
@end
