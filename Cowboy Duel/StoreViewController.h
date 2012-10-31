//
//  StoreViewController.h
//  Cowboy Duels
//
//  Created by Taras on 25.10.12.
//
//

#import <UIKit/UIKit.h>
#import "StoreDataSource.h"
#import "AccountDataSource.h"
#import "PlayersOnLineDataSource.h"

@interface StoreViewController : UIViewController<UITableViewDelegate,TableCellWithButton>
@property (strong, nonatomic) StoreDataSource *storeDataSource;

-(id)initWithAccount:(AccountDataSource *)userAccount;

@end
