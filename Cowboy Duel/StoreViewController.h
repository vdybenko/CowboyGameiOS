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
#import "DuelProductDownloaderController.h"

@interface StoreViewController : UIViewController<UITableViewDelegate,TableCellWithButton,MKStoreKitDelegate,DuelProductDownloaderControllerDelegate,MemoryManagement>

@property (strong, nonatomic) StoreDataSource *storeDataSource;
@property (nonatomic) BOOL bagFlag;

-(id)initWithAccount:(AccountDataSource *)userAccount;
- (IBAction)backButtonClick:(id)sender;
- (IBAction)bagButtonClick:(id)sender;
-(void)refreshController;
@end
