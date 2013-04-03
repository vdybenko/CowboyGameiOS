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
#import "CDBarrierDuelProduct.h"
#import <StoreKit/StoreKit.h>

#define DUEL_PRODUCTS_WEAPONS @"DUEL_PRODUCT_WEARON"
#define DUEL_PRODUCTS_DEFENSES @"DUEL_PRODUCT_DEFENSES"
#define DUEL_PRODUCTS_BARRIER @"DUEL_PRODUCT_BARRIER"

typedef void (^DuelProductDownloaderControllerResult)(NSError *error);

typedef enum{
    DuelProductDownloaderTypeDuelProduct,
    DuelProductDownloaderTypeUserProduct,
    DuelProductDownloaderTypeBuyProduct
}DuelProductDownloaderType;

@protocol DuelProductDownloaderControllerDelegate

-(void)didFinishDownloadWithType:(DuelProductDownloaderType)type error:(NSError *)error;

@end

@interface DuelProductDownloaderController : NSObject<SKProductsRequestDelegate>

@property (copy) DuelProductDownloaderControllerResult didFinishBlock;
@property (nonatomic) id<DuelProductDownloaderControllerDelegate> delegate;

+(BOOL) isRefreshEvailable:(int)serverRevision;
-(void) refreshDuelProducts;
+(NSString *)getSavePathForDuelProduct;

+(void)saveWeapon:(NSArray*)array;
+(NSMutableArray*)loadWeaponArray;
+(void)saveDefense:(NSArray*)array;
+(NSMutableArray*)loadDefenseArray;
+(CDWeaponProduct*)defaultWeaponForPlayer;

+(NSMutableArray*)loadBarrierArray;
+(void)saveBarrier:(NSArray*)array;

-(BOOL)isListProductsAvailable;
-(void)refreshUserDuelProducts;
-(void)buyProductID:(int)productId transactionID:(int)transactionID;
@end
