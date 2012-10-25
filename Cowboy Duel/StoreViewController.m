//
//  StoreViewController.m
//  Cowboy Duels
//
//  Created by Taras on 25.10.12.
//
//

#import "StoreViewController.h"

@interface StoreViewController ()
{
    AccountDataSource *userAccount;
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
        userAccount = pUserAccount;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     storeDataSource = [[StoreDataSource alloc] initWithTable:tableView parentVC:self];
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

#pragma mark IBAction
- (IBAction)weaponsButtonClick:(id)sender {
    if (storeDataSource.typeOfTable != StoreDataSourceTypeTablesWeapons) {
        storeDataSource.typeOfTable = StoreDataSourceTypeTablesWeapons;
        [tableView reloadData];
    }
}
- (IBAction)defenseButtonClick:(id)sender {
    if (storeDataSource.typeOfTable != StoreDataSourceTypeTablesDefenses) {
        storeDataSource.typeOfTable = StoreDataSourceTypeTablesDefenses;
        [tableView reloadData];
    }
}
- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
