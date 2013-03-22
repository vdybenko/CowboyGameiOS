#import "VisualViewCharacterViewController.h"
#import "AccountDataSource.h"
#import "UIButton+Image+Title.h"

@interface VisualViewCharacterViewController ()
{
    __weak IBOutlet UITableView *tableView;
    __weak IBOutlet UILabel *title;
    __weak IBOutlet UIButton *btnBack;
    __weak IBOutlet UIView *activityView;
    __weak AccountDataSource *playerAccount;
}
@end

@implementation VisualViewCharacterViewController
@synthesize visualViewDataSource;
#pragma mark - Instance initialization

-(id)init;
{
    self = [super initWithNibName:Nil bundle:Nil];
    if (self) {
        playerAccount = [AccountDataSource sharedInstance];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	visualViewDataSource.tableView = tableView;
    [tableView setDataSource:visualViewDataSource];
    title.text = NSLocalizedString(@"SHOP", @"");
    title.textColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    title.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    [btnBack setTitleByLabel:@"BACK"];
    [btnBack changeColorOfTitleByLabel:buttonsTitleColor];
    
    [visualViewDataSource reloadDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog(@"VisualViewCharacterViewController didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    tableView = nil;
    title = nil;
    btnBack = nil;
    activityView = nil;
    [super viewDidUnload];
}
-(void)refreshController;
{
    [visualViewDataSource reloadDataSource];
}

- (void)releaseComponents
{
    [visualViewDataSource releaseComponents];
    visualViewDataSource = nil;
    tableView = nil;
    title = nil;
    btnBack = nil;
    activityView = nil;
    playerAccount = nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.f;
}


#pragma mark IBAction

- (IBAction)btnBackClick:(id)sender {
}
@end
