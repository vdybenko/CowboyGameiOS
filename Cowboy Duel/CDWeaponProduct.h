//
//  CDWeaponProduct.h
//  Cowboy Duels
//
//  Created by Taras on 24.10.12.
//
//

#import "CDDuelProduct.h"

#define PRODUCT_IMG_NAME_GUN @"gun";

@interface CDWeaponProduct : CDDuelProduct
@property(nonatomic) NSInteger dDamage;
@property(nonatomic) CGFloat dFrequently;
@property(nonatomic, strong) NSString *dImageGunLocal;
@property(nonatomic, strong) NSString *dImageGunURL;
@property(nonatomic, strong) NSString *dSoundLocal;
@property(nonatomic, strong) NSString *dSoundURL;

-(NSString*) saveNameImageGun;
-(NSString*) saveNameSoundGun;

@end
