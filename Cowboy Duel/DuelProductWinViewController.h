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

@interface DuelProductWinViewController : UIViewController
- (id)initWithAccount:(AccountDataSource*)account duelProduct:(CDWeaponProduct*)product parentVC:(UIViewController*)vc;;

@end
