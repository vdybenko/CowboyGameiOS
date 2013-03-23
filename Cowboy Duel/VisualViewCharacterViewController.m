#import "VisualViewCharacterViewController.h"
#import "AccountDataSource.h"
#import "UIButton+Image+Title.h"
#import "VisualViewDataSource.h"
#import "VisualViewCharacter.h"
#import "ScrollViewSwitcher.h"

@interface VisualViewCharacterViewController ()
{
//    __weak IBOutlet UILabel *title;
//    __weak IBOutlet UIButton *btnBack;
//    __weak IBOutlet UIView *activityView;
//    __weak AccountDataSource *playerAccount;
    __weak IBOutlet VisualViewCharacter *visualViewCharacter;
    __weak IBOutlet UICollectionView *collectionView;
    __weak IBOutlet ScrollViewSwitcher *scrollViewSwitcher;
}
@end

@implementation VisualViewCharacterViewController
@synthesize visualViewDataSource;
#pragma mark - Instance initialization

-(id)init;
{
    self = [super initWithNibName:@"VisualViewCharacterViewController" bundle:[NSBundle mainBundle]];
    if (self) {
//        playerAccount = [AccountDataSource sharedInstance];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    visualViewDataSource = [[VisualViewDataSource alloc] initWithCollectionView:collectionView];
    collectionView.dataSource = visualViewDataSource;
//    title.text = NSLocalizedString(@"SHOP", @"");
//    title.textColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
//    title.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
//    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
//    [btnBack setTitleByLabel:@"BACK"];
//    [btnBack changeColorOfTitleByLabel:buttonsTitleColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog(@"VisualViewCharacterViewController didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
//    title = nil;
//    btnBack = nil;
//    activityView = nil;
//    visualViewCharacter = nil;
    collectionView = nil;
    scrollViewSwitcher = nil;
    [super viewDidUnload];
}
-(void)refreshController;
{
}

- (void)releaseComponents
{
    [visualViewDataSource releaseComponents];
    visualViewDataSource = nil;
//    title = nil;
//    btnBack = nil;
//    activityView = nil;
//    playerAccount = nil;
    visualViewCharacter = nil;
}

#pragma mark IBAction

- (IBAction)btnBackClick:(id)sender {
}
@end
