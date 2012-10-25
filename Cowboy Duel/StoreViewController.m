//
//  StoreViewController.m
//  Cowboy Duels
//
//  Created by Taras on 25.10.12.
//
//

#import "StoreViewController.h"

@interface StoreViewController ()
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
-(id)initWithAccount:(AccountDataSource *)userAccount;
{
    self = [super initWithNibName:@"StoreViewController" bundle:[NSBundle mainBundle]];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
}
- (IBAction)defenseButtonClick:(id)sender {
}
- (IBAction)backButtonClick:(id)sender {
}

@end
