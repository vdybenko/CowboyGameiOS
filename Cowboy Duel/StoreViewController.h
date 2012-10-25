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

@interface StoreViewController : UIViewController
@property (strong, nonatomic) StoreDataSource *storeDataSource;

-(id)initWithAccount:(AccountDataSource *)userAccount;

@end
