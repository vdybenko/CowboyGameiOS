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

@interface StoreViewController ()
{
    __weak AccountDataSource *playerAccount;
    DuelProductDownloaderController *duelProductDownloaderController;
    
    int purchesingProductIndex;
    BOOL bagFlag;
    
}
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnWeapons;
@property (weak, nonatomic) IBOutlet UIButton *btnDefenses;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnBag;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *btnBarriers;

@end

@implementation StoreViewController
#pragma mark - Instance initialization

@synthesize storeDataSource;
@synthesize title;
@synthesize tableView;
@synthesize btnBack;
@synthesize btnWeapons;
@synthesize btnDefenses;
@synthesize btnBarriers;
@synthesize btnBag;
@synthesize loadingView, bagFlag;

#pragma mark
-(id)initWithAccount:(AccountDataSource *)pUserAccount;
{
    self = [super initWithNibName:@"StoreViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        playerAccount = pUserAccount;
        duelProductDownloaderController = [[DuelProductDownloaderController alloc] init];
        duelProductDownloaderController.delegate = self;
        purchesingProductIndex =-1;
        storeDataSource = [[StoreDataSource alloc] initWithTable:Nil parentVC:self];
        storeDataSource.delegate = self;
        //bagFlag = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    storeDataSource.tableView = tableView;
    [tableView setDataSource:storeDataSource];
    title.text = NSLocalizedString(@"SHOP", @"");
    title.textColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    title.font = [UIFont fontWithName: @"DecreeNarrow" size:70];
    
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];

    [btnBack setTitleByLabel:@"BACK" withColor:buttonsTitleColor fontSize:40];
    [btnBag setTitleByLabel:@"BAG" withColor:buttonsTitleColor fontSize:40];
    [btnWeapons setTitleByLabel:@"WEAPONS" withColor:buttonsTitleColor fontSize:40];
    [btnBarriers setTitleByLabel:@"BARRIES" withColor:buttonsTitleColor fontSize:40];
    [btnDefenses setTitleByLabel:@"DEFENSES" withColor:buttonsTitleColor fontSize:40];
    
    [storeDataSource reloadDataSource];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MKStoreManager sharedManager].delegate = self;
    
    if (self.bagFlag) {
        title.text = NSLocalizedString(@"BAG", @"");
        [self.btnBag changeTitleByLabel:NSLocalizedString(@"SHOP", @"")];
        storeDataSource.bagFlag = bagFlag;
        [storeDataSource reloadDataSource];
        [storeDataSource setCellsHide:YES];
        [tableView reloadData];
        
        [self startTableAnimation];
    }
    
    [self startTableAnimation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/StoreVC" forKey:@"page"]];
}

-(void)refreshController;
{
    [storeDataSource reloadDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)releaseComponents
{
    [storeDataSource releaseComponents];
    storeDataSource = nil;
    title = nil;
    tableView = nil;
    btnWeapons = nil;
    btnDefenses = nil;
    btnBarriers = nil;
    btnBack = nil;
    btnBag = nil;
    loadingView = nil;
    playerAccount = nil;
    duelProductDownloaderController = nil;
}

#pragma mark

-(void)startTableAnimation;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
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
                [storeDataSource setCellsHide:NO];
                if ([tableView.visibleCells count]>i) {
                    UITableViewCell *cell = [tableView.visibleCells lastObject];
                    [cell setHidden:YES];
                    
                    UITableViewRowAnimation type;
                    if (storeDataSource.typeOfTable == StoreDataSourceTypeTablesWeapons)
                    {
                        type = UITableViewRowAnimationRight;
                    }else{
                        type = UITableViewRowAnimationLeft;
                    }
                    
                    [self.tableView beginUpdates];
                    
                    [tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:type];
                    
                    [self.tableView endUpdates];
                }
            });
            [NSThread sleepForTimeInterval:0.12];
        }
    });
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 168.f;
}

#pragma mark - TableCellWithButton methods

-(void)clickButton:(NSIndexPath *)indexPath;
{
    if (![[StartViewController sharedInstance] connectedToWiFi]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", @"AlertView")
                                                            message:NSLocalizedString(@"Internet_down", @"AlertView")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"AlertView")
                                                  otherButtonTitles: nil];
        alertView = 0;
        [alertView show];
        alertView = nil;
        return;
    }

    StoreProductCell *cell=(StoreProductCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.buyProduct.enabled = NO;
    
    [self activityShow];
    
    switch (storeDataSource.typeOfTable) {
        case StoreDataSourceTypeTablesWeapons:
        {
            CDWeaponProduct *product = [storeDataSource.arrItemsList objectAtIndex:indexPath.row];
            if (product.dCountOfUse==0 && product.dID!=-1) {
                if (product.dPrice==0) {
                    purchesingProductIndex = indexPath.row;
                    [[MKStoreManager sharedManager] buyFeature:product.dPurchaseUrl];
                }else{
                    [duelProductDownloaderController buyProductID:product.dID transactionID:playerAccount.glNumber];
                    duelProductDownloaderController.didFinishBlock = ^(NSError *error){
                        self.view.userInteractionEnabled = YES;
                        if (!error) {
                            CDTransaction *transaction = [[CDTransaction alloc] init];
                            transaction.trDescription = @"BuyProductWeapon";
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
                        }
                    };
                    return;
                }
            }else{
                playerAccount.accountWeapon = product;
                playerAccount.curentIdWeapon = product.dID;
                [playerAccount saveWeapon];
                cell.buyProduct.enabled = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self activityHide];
                });
                
                [storeDataSource reloadDataSource];
                [tableView reloadData];
            }
        
            break;
        }
            
        case StoreDataSourceTypeTablesDefenses:
        {
            CDDefenseProduct *product = [storeDataSource.arrItemsList objectAtIndex:indexPath.row];
            if (product.dPrice==0) {
                purchesingProductIndex = indexPath.row;
                [[MKStoreManager sharedManager] buyFeature:product.dPurchaseUrl];
            }else{
                [duelProductDownloaderController buyProductID:product.dID transactionID:playerAccount.glNumber];
                duelProductDownloaderController.didFinishBlock = ^(NSError *error){
                    cell.buyProduct.enabled = YES;
                    if (!error) {
                        CDTransaction *transaction = [[CDTransaction alloc] init];
                        transaction.trDescription = @"BuyProductWinDefense";
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
                    }
                };
            }

            break;
        }

        case StoreDataSourceTypeTablesBarrier:
        {
            CDBarrierDuelProduct *product = [storeDataSource.arrItemsList objectAtIndex:indexPath.row];
            if (product.dPrice==0) {
                purchesingProductIndex = indexPath.row;
                [[MKStoreManager sharedManager] buyFeature:product.dPurchaseUrl];
            }else{
                [duelProductDownloaderController buyProductID:product.dID transactionID:playerAccount.glNumber];
                duelProductDownloaderController.didFinishBlock = ^(NSError *error){
                    cell.buyProduct.enabled = YES;
                    if (!error) {
                        CDTransaction *transaction = [[CDTransaction alloc] init];
                        transaction.trDescription = @"BuyProductWinBarier";
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
                        //playerAccount.accountDefenseValue += product.dDefense;
                      //  [playerAccount saveDefense];
                        product.dCountOfUse +=1;
                        [storeDataSource.arrItemsList replaceObjectAtIndex:indexPath.row withObject:product];
                        [DuelProductDownloaderController saveBarrier:storeDataSource.arrItemsList];
                    }
                };
            }

            break;
        }

            
        default:
            break;
    }
    
}

#pragma mark DuelProductDownloaderControllerDelegate

-(void)didFinishDownloadWithType:(DuelProductDownloaderType)type error:(NSError *)error;
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        [storeDataSource reloadDataSource];
        [tableView reloadData];
        
        [self activityHide];
    });
}

#pragma mark IBAction
- (IBAction)weaponsButtonClick:(id)sender {
    if (storeDataSource.typeOfTable != StoreDataSourceTypeTablesWeapons) {
    
        storeDataSource.typeOfTable = StoreDataSourceTypeTablesWeapons;
        [storeDataSource reloadDataSource];
        [storeDataSource setCellsHide:YES];
        [tableView reloadData];
        [self startTableAnimation];
    }
}
- (IBAction)defenseButtonClick:(id)sender {
    if (storeDataSource.typeOfTable != StoreDataSourceTypeTablesDefenses) {
    
        storeDataSource.typeOfTable = StoreDataSourceTypeTablesDefenses;
        [storeDataSource reloadDataSource];
        [storeDataSource setCellsHide:YES];
        [tableView reloadData];
        [self startTableAnimation];
    }
}
- (IBAction)barrierButtonClick:(id)sender {
    if (storeDataSource.typeOfTable != StoreDataSourceTypeTablesBarrier) {
        
        storeDataSource.typeOfTable = StoreDataSourceTypeTablesBarrier;
        [storeDataSource reloadDataSource];
        [storeDataSource setCellsHide:YES];
        [tableView reloadData];
        [self startTableAnimation];
    }

}

- (IBAction)bagButtonClick:(id)sender {
    if (bagFlag) {
        bagFlag = NO;
        title.text = NSLocalizedString(@"SHOP", @"");
        [self.btnBag changeTitleByLabel:NSLocalizedString(@"BAG", @"")];
    }
    else
    {
        bagFlag = YES;
        title.text = NSLocalizedString(@"BAG", @"");
        [self.btnBag changeTitleByLabel:NSLocalizedString(@"SHOP", @"")];
    }
    
    storeDataSource.bagFlag = bagFlag;
    [storeDataSource reloadDataSource];
    [storeDataSource setCellsHide:YES];
    [tableView reloadData];
    
    [self startTableAnimation];
}

- (IBAction)backButtonClick:(id)sender {
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                     }];
    [self.navigationController popViewControllerAnimated:NO];
    [self releaseComponents];
}

#pragma mark Activity view

-(void)activityShow;
{    
    loadingView.hidden = NO;
    self.view.userInteractionEnabled = NO;
}

-(void)activityHide;
{
    [self.loadingView setHidden:YES];
    self.view.userInteractionEnabled = YES;
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
    
    loadingView.hidden = YES;
    self.view.userInteractionEnabled = YES;
    
    NSString *stringToGA = [NSString stringWithFormat:@"/StoreVC_buy_product_%d",purchesingProductIndex];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:stringToGA forKey:@"page"]];
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
    self.view.userInteractionEnabled = YES;
    
    NSString *stringToGA = [NSString stringWithFormat:@"/StoreVC_buy_product_fail_%d",purchesingProductIndex];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:stringToGA forKey:@"page"]];
}

-(void)dealloc
{

}
- (void)viewDidUnload {
    [self setBtnBarriers:nil];
    [super viewDidUnload];
}
@end
