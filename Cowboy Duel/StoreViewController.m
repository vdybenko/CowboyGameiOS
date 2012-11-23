//
//  StoreViewController.m
//  Cowboy Duels
//
//  Created by Taras on 25.10.12.
//
//

#import "StoreViewController.h"
#import "UIButton+Image+Title.h"
#import "StoreProductCell.h"
#import "CDDefenseProduct.h"
#import "DuelProductDownloaderController.h"

@interface StoreViewController ()
{
    AccountDataSource *playerAccount;
    DuelProductDownloaderController *duelProductDownloaderController;
    
    int purchesingProductIndex;
}
@property (strong, nonatomic) IBOutlet UILabel *title;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIButton *btnWeapons;
@property (strong, nonatomic) IBOutlet UIButton *btnDefenses;

@end

@implementation StoreViewController
#pragma mark - Instance initialization

@synthesize storeDataSource;
@synthesize title;
@synthesize tableView;
@synthesize btnBack;
@synthesize btnWeapons;
@synthesize btnDefenses;
@synthesize loadingView;
#pragma mark
-(id)initWithAccount:(AccountDataSource *)pUserAccount;
{
    self = [super initWithNibName:@"StoreViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        playerAccount = pUserAccount;
        duelProductDownloaderController = [[DuelProductDownloaderController alloc] init];
        purchesingProductIndex =-1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     storeDataSource = [[StoreDataSource alloc] initWithTable:tableView parentVC:self];
    storeDataSource.delegate = self;
    [tableView setDataSource:storeDataSource];
    
    title.text = NSLocalizedString(@"SHOP", @"");
    title.textColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    title.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
    UIColor *buttonsTitleColor = [[UIColor alloc] initWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];

    [btnBack setTitleByLabel:@"BACK"];
    [btnBack changeColorOfTitleByLabel:buttonsTitleColor];
    [btnWeapons setTitleByLabel:@"WEAPONS"];
    [btnWeapons changeColorOfTitleByLabel:buttonsTitleColor];
    [btnDefenses setTitleByLabel:@"DEFENSES"];
    [btnDefenses changeColorOfTitleByLabel:buttonsTitleColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MKStoreManager sharedManager].delegate = self;    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [storeDataSource reloadDataSource];
        [self startTableAnimation];
    });
}

-(void)refreshController;
{
    [storeDataSource reloadDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark

-(void)startTableAnimation;
{
    int countOfCells=[storeDataSource.arrItemsList count];
    int maxIndex;
    if (countOfCells<5) {
        maxIndex=countOfCells;
    }else {
        maxIndex=5;
    }
    for (int i=0; i<maxIndex; i++) {
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:i inSection:0];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableViewCell *cell = [tableView.visibleCells lastObject];
            [cell setHidden:YES];
            UITableViewRowAnimation type;
            if (storeDataSource.typeOfTable == StoreDataSourceTypeTablesWeapons)
            {
                type = UITableViewRowAnimationRight;
            }else{
                type = UITableViewRowAnimationLeft;
            }
            [storeDataSource setCellsHide:NO];
            [tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:type];
        });
        [NSThread sleepForTimeInterval:0.2];
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.f;
}

#pragma mark - TableCellWithButton methods

-(void)clickButton:(NSIndexPath *)indexPath;
{
    StoreProductCell *cell=(StoreProductCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.buyProduct.enabled = NO;
    loadingView.hidden = NO;

    if (storeDataSource.typeOfTable == StoreDataSourceTypeTablesWeapons) {
        CDWeaponProduct *product = [storeDataSource.arrItemsList objectAtIndex:indexPath.row];
        if (product.dCountOfUse==0) {
            if (product.dPrice==0) {
                purchesingProductIndex = indexPath.row;
                [[MKStoreManager sharedManager] buyFeature:product.dPurchaseUrl];
            }else{
                [duelProductDownloaderController buyProductID:product.dID transactionID:playerAccount.glNumber];
                duelProductDownloaderController.didFinishBlock = ^(NSError *error){
                    cell.buyProduct.enabled = YES;
                    loadingView.hidden = YES;
                    if (!error) {
                        CDTransaction *transaction = [[CDTransaction alloc] init];
                        transaction.trDescription = [[NSString alloc] initWithFormat:@"BuyProductWeapon"];
                        transaction.trType = [NSNumber numberWithInt:-1];
                        transaction.trMoneyCh = [NSNumber numberWithInt:-product.dPrice];
                        transaction.trLocalID = [NSNumber numberWithInt:[playerAccount increaseGlNumber]];
                        transaction.trOpponentID = @"";
                        transaction.trGlobalID = [NSNumber numberWithInt:-1];
                        
                        [playerAccount.transactions addObject:transaction];
                        [playerAccount saveTransaction];
                        [playerAccount sendTransactions:playerAccount.transactions];
                        
                        playerAccount.money -= product.dPrice;
                        [playerAccount saveMoney];
                        product.dCountOfUse =1;
                        [storeDataSource.arrItemsList replaceObjectAtIndex:indexPath.row withObject:product];
                        [DuelProductDownloaderController saveWeapon:storeDataSource.arrItemsList];
                        playerAccount.accountWeapon = product;
                        playerAccount.curentIdWeapon = product.dID;
                        [playerAccount saveWeapon];
                        
                        [storeDataSource reloadDataSource];
                        [tableView reloadData];
                    }                    
                };
                return;
            }
        }else{
            playerAccount.accountWeapon = product;
            playerAccount.curentIdWeapon = product.dID;
            [playerAccount saveWeapon];
            cell.buyProduct.enabled = YES;
            loadingView.hidden = YES;
        }
    }else if(storeDataSource.typeOfTable == StoreDataSourceTypeTablesDefenses){
        CDDefenseProduct *product = [storeDataSource.arrItemsList objectAtIndex:indexPath.row];
        if (product.dPrice==0) {
            purchesingProductIndex = indexPath.row;
            [[MKStoreManager sharedManager] buyFeature:product.dPurchaseUrl];
        }else{
            [duelProductDownloaderController buyProductID:product.dID transactionID:playerAccount.glNumber];
            duelProductDownloaderController.didFinishBlock = ^(NSError *error){
                cell.buyProduct.enabled = YES;
                loadingView.hidden = YES;
                if (!error) {
                    CDTransaction *transaction = [[CDTransaction alloc] init];
                    transaction.trDescription = [[NSString alloc] initWithFormat:@"BuyProductWinDefense"];
                    transaction.trType = [NSNumber numberWithInt:-1];
                    transaction.trMoneyCh = [NSNumber numberWithInt:-product.dPrice];
                    transaction.trLocalID = [NSNumber numberWithInt:[playerAccount increaseGlNumber]];
                    transaction.trOpponentID = @"";
                    transaction.trGlobalID = [NSNumber numberWithInt:-1];
                    
                    [playerAccount.transactions addObject:transaction];
                    [playerAccount saveTransaction];
                    [playerAccount sendTransactions:playerAccount.transactions];
                    
                    playerAccount.money -= product.dPrice;
                    [playerAccount saveMoney];
                    playerAccount.accountDefenseValue += product.dDefense;
                    [playerAccount saveDefense];
                    product.dCountOfUse +=1;
                    [storeDataSource.arrItemsList replaceObjectAtIndex:indexPath.row withObject:product];
                    [DuelProductDownloaderController saveDefense:storeDataSource.arrItemsList];
                    
                    [storeDataSource reloadDataSource];
                    [tableView reloadData];
                }
            };
        }
    }
    [storeDataSource reloadDataSource];
    [tableView reloadData];
}

#pragma mark IBAction
- (IBAction)weaponsButtonClick:(id)sender {
    if (storeDataSource.typeOfTable != StoreDataSourceTypeTablesWeapons) {
        storeDataSource.typeOfTable = StoreDataSourceTypeTablesWeapons;
        [storeDataSource reloadDataSource];
        [self startTableAnimation];
    }
}
- (IBAction)defenseButtonClick:(id)sender {
    if (storeDataSource.typeOfTable != StoreDataSourceTypeTablesDefenses) {
        storeDataSource.typeOfTable = StoreDataSourceTypeTablesDefenses;
        [storeDataSource reloadDataSource];
        [self startTableAnimation];
    }
}
- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark MKStoreKitDelegate

- (void)productPurchased
{
    if (storeDataSource.typeOfTable == StoreDataSourceTypeTablesWeapons) {
        CDWeaponProduct *product = [storeDataSource.arrItemsList objectAtIndex:purchesingProductIndex];
        product.dCountOfUse =1;
        [storeDataSource.arrItemsList replaceObjectAtIndex:purchesingProductIndex withObject:product];
        [DuelProductDownloaderController saveWeapon:storeDataSource.arrItemsList];
        playerAccount.accountWeapon = product;
        playerAccount.curentIdWeapon = product.dID;
        [playerAccount saveWeapon];
        
        [duelProductDownloaderController buyProductID:product.dID transactionID:-1];
    }else if(storeDataSource.typeOfTable == StoreDataSourceTypeTablesDefenses){
        CDDefenseProduct *product = [storeDataSource.arrItemsList objectAtIndex:purchesingProductIndex];
        playerAccount.accountDefenseValue += product.dDefense;
        [playerAccount saveDefense];
        product.dCountOfUse +=1;
        [storeDataSource.arrItemsList replaceObjectAtIndex:purchesingProductIndex withObject:product];
        [DuelProductDownloaderController saveDefense:storeDataSource.arrItemsList];
        
        [duelProductDownloaderController buyProductID:product.dID transactionID:-1];
    }
    
    [storeDataSource reloadDataSource];
    [tableView reloadData];
    
    purchesingProductIndex = -1;
    loadingView.hidden = YES;
    
    NSString *stringToGA = [NSString stringWithFormat:@"/buy_product_%d",purchesingProductIndex];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:stringToGA forKey:@"event"]];
}

- (void)productAPurchased
{
    [self productPurchased];
}

- (void)failed
{
    [storeDataSource reloadDataSource];
    [tableView reloadData];
    
    purchesingProductIndex = -1;
    loadingView.hidden = YES;
    
    NSString *stringToGA = [NSString stringWithFormat:@"/buy_product_fail_%d",purchesingProductIndex];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:stringToGA forKey:@"event"]];
}

#pragma mark 
-(void)dealloc;
{
    duelProductDownloaderController =nil;
    playerAccount = nil;
}

@end
