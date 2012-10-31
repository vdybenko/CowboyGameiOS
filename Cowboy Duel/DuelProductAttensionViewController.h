//
//  DuelProductAttensionViewController.h
//  Cowboy Duels
//
//  Created by Taras on 26.10.12.
//
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
#import "StoreDataSource.h"

@interface DuelProductAttensionViewController : UIViewController<TableCellWithButton>
- (id)initWithAccount:(AccountDataSource*)account;
@end
