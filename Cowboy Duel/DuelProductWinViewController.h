//
//  DuelProductWinViewController.h
//  Bounty Hunter
//
//  Created by Taras on 29.10.12.
//
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
#import "CDWeaponProduct.h"
#import "MKStoreManager.h"

@interface DuelProductWinViewController : UIViewController<MKStoreKitDelegate,MemoryManagement>
- (id)initWithAccount:(AccountDataSource*)account duelProduct:(CDWeaponProduct*)product parentVC:(UIViewController*)vc;;

@end
