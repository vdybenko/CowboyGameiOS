//
//  DuelProductWinViewController.h
//  Cowboy Duels
//
//  Created by Taras on 29.10.12.
//
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
#import "CDWeaponProduct.h"
#import "MKStoreManager.h"

@interface DuelProductWinViewController : UIViewController<MKStoreKitDelegate>
- (id)initWithAccount:(AccountDataSource*)account duelProduct:(CDWeaponProduct*)product parentVC:(UIViewController*)vc;;

@end
