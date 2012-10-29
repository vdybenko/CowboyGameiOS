//
//  DuelProductAttensionViewController.m
//  Cowboy Duels
//
//  Created by Taras on 26.10.12.
//
//

#import "DuelProductAttensionViewController.h"
#import "StoreProductCell.h"
#import "StoreDataSource.h"
#import "DuelProductDownloaderController.h"
#import "UIView+Dinamic_BackGround.h"

@interface DuelProductAttensionViewController ()
{
    AccountDataSource *playerAccount;
    StoreProductCell *productCell;
}
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIView *frameView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation DuelProductAttensionViewController
@synthesize title;
@synthesize frameView;
- (id)initWithAccount:(AccountDataSource*)account;
{
    self = [super initWithNibName:Nil bundle:Nil];
    if (self) {
        playerAccount = account;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [frameView setDinamicHeightBackground];
    StoreProductCell *cell = [StoreProductCell cell];
    [cell initMainControls];
    
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:DUEL_PRODUCTS_WEAPONS];
    NSArray *arrItemsList = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    
    CDDuelProduct *prod=[arrItemsList objectAtIndex:0];
    [cell populateWithProduct:prod targetToBuyButton:self cellType:StoreDataSourceTypeTablesWeapons];
    CGRect frame= cell.frame;
    frame.origin.x = 0;
    frame.origin.y = frameView.frame.origin.y + frameView.frame.size.height-10;
    cell.frame = frame;
    [self.view insertSubview:cell belowSubview:frameView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)closeButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
