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
}
@property (strong, nonatomic) IBOutlet UILabel *title;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIButton *btnWeapons;
@property (strong, nonatomic) IBOutlet UIButton *btnDefenses;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
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
-(id)initWithAccount:(AccountDataSource *)pUserAccount;
{
    self = [super initWithNibName:@"StoreViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        playerAccount = pUserAccount;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.f;
}

#pragma mark - TableCellWithButton methods

-(void)clickButton:(NSIndexPath *)indexPath;
{
    if (storeDataSource.typeOfTable == StoreDataSourceTypeTablesWeapons) {
        CDWeaponProduct *product = [storeDataSource.arrItemsList objectAtIndex:indexPath.row];
//        if (product.dPrice==0) {
            if (NO) {
           
        }else{
            playerAccount.money -= product.dPrice;
            [playerAccount saveMoney];
            product.dCountOfUse +=1;
            [storeDataSource.arrItemsList replaceObjectAtIndex:indexPath.row withObject:product];
            [DuelProductDownloaderController saveWeapon:storeDataSource.arrItemsList];
            playerAccount.accountWeapon = product;
            playerAccount.curentIdWeapon = product.dID;
            [playerAccount saveWeapon];
        }
    }else if(storeDataSource.typeOfTable == StoreDataSourceTypeTablesDefenses){
        CDDefenseProduct *product = [storeDataSource.arrItemsList objectAtIndex:indexPath.row];
        if (product.dPrice==0) {
            
        }else{
            playerAccount.money -= product.dPrice;
            playerAccount.accountDefenseValue += product.dDefense;
            [playerAccount saveMoney];
        }
    }
}

#pragma mark IBAction
- (IBAction)weaponsButtonClick:(id)sender {
    if (storeDataSource.typeOfTable != StoreDataSourceTypeTablesWeapons) {
        storeDataSource.typeOfTable = StoreDataSourceTypeTablesWeapons;
        [storeDataSource reloadDataSource];
        [tableView reloadData];
    }
}
- (IBAction)defenseButtonClick:(id)sender {
    if (storeDataSource.typeOfTable != StoreDataSourceTypeTablesDefenses) {
        storeDataSource.typeOfTable = StoreDataSourceTypeTablesDefenses;
        [storeDataSource reloadDataSource];
        [tableView reloadData];
    }
}
- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
