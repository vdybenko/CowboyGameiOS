//
//  DuelProductDownloaderController.h
//  Cowboy Duels
//
//  Created by Taras on 24.10.12.
//
//

#import <Foundation/Foundation.h>
#import "CDWeaponProduct.h"
#import "CDDefenseProduct.h"

#define DUEL_PRODUCTS_WEAPONS @"DUEL_PRODUCT_WEARON"
#define DUEL_PRODUCTS_DEFENSES @"DUEL_PRODUCT_DEFENSES"

typedef void (^DuelProductDownloaderControllerResult)(NSError *error);

@interface DuelProductDownloaderController : NSObject
@property (copy) DuelProductDownloaderControllerResult didFinishBlock;
+(BOOL) isRefreshEvailable:(int)serverRevision;
-(void) refreshDuelProducts;
+(NSString *)getSavePathForDuelProduct;

+(void)saveWeapon:(NSArray*)array;
+(NSMutableArray*)loadWeaponArray;
+(void)saveDefense:(NSArray*)array;
+(NSMutableArray*)loadDefenseArray;

-(BOOL)downloadUserProductsIsListProductsAvailable;
-(void)buyProductID:(int)productId transactionID:(int)transactionID;
@end
