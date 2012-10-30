//
//  DuelProductWinViewController.h
//  Cowboy Duels
//
//  Created by Taras on 29.10.12.
//
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
#import "CDDuelProduct.h"

@interface DuelProductWinViewController : UIViewController
- (id)initWithAccount:(AccountDataSource*)account duelProduct:(CDDuelProduct*)product;

@end
