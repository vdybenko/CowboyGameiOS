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
#import "MKStoreManager.h"

@interface StoreViewController : UIViewController<UITableViewDelegate,TableCellWithButton,MKStoreKitDelegate>
@property (strong, nonatomic) StoreDataSource *storeDataSource;
@property (strong, nonatomic) IBOutlet UIView *loadingView;

-(id)initWithAccount:(AccountDataSource *)userAccount;
- (IBAction)backButtonClick:(id)sender;
-(void)refreshController;
@end
