//
//  DuelProductWinViewController.m
//  Cowboy Duels
//
//  Created by Taras on 29.10.12.
//
//

#import "DuelProductWinViewController.h"
#import "UIView+Dinamic_BackGround.h"
#import "UIButton+Image+Title.h"
#import "UIImage+Save.h"
#import "DuelProductDownloaderController.h"
#import "StoreViewController.h"

@interface DuelProductWinViewController ()
{
    AccountDataSource *playerAccount;
    CDDuelProduct *duelProduct;
    UIViewController *parentVC;
}
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIView *frameView;
@property (strong, nonatomic) IBOutlet UILabel *ribbonLabel;
@property (strong, nonatomic) IBOutlet UILabel * goldTitle;
@property (strong, nonatomic) IBOutlet UILabel * gold;
@property (strong, nonatomic) IBOutlet UIImageView * gunImage;
@property (strong, nonatomic) IBOutlet UIButton * buyItButton;

@end

@implementation DuelProductWinViewController
@synthesize title;
@synthesize frameView;
@synthesize ribbonLabel;
@synthesize goldTitle;
@synthesize gold;
@synthesize gunImage;
@synthesize buyItButton;

- (id)initWithAccount:(AccountDataSource*)account duelProduct:(CDDuelProduct*)product parentVC:(UIViewController*)vc;
{
    self = [super initWithNibName:Nil bundle:Nil];
    if (self) {
        playerAccount = account;
        duelProduct = product;
        parentVC = vc;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [frameView setDinamicHeightBackground];
    
    [title setFont: [UIFont fontWithName: @"DecreeNarrow" size:28]];
    title.text = NSLocalizedString(@"IT_HELP", @"");
    
    gunImage.clipsToBounds = YES;
    gunImage.image = [UIImage loadImageFullPath:[NSString stringWithFormat:@"%@/%@.png",[DuelProductDownloaderController getSavePathForDuelProduct],[duelProduct saveNameImage]]];
    
    [ribbonLabel setFont: [UIFont fontWithName: @"DecreeNarrow" size:28]];
    ribbonLabel.text = duelProduct.dName;
    
    [buyItButton setTitleByLabel:@"BUYITNOW"];
    UIColor *buttonsTitleColor = [[UIColor alloc] initWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    [buyItButton changeColorOfTitleByLabel:buttonsTitleColor];
    
    gold.text = [NSString stringWithFormat:@"%d",duelProduct.dPrice];
    [goldTitle dinamicAttachToView:gold withDirection:DirectionToAnimateRight];
    goldTitle.text = NSLocalizedString(@"Gold", @"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)closeButtonClick:(id)sender {
    [parentVC dismissViewControllerAnimated:YES completion:Nil];
}
- (IBAction)BuyItButtonClick:(id)sender {
}
- (IBAction)GoToStoreClick:(id)sender {
    StoreViewController *svc=[[StoreViewController alloc] initWithAccount:playerAccount];
    [parentVC.navigationController pushViewController:svc animated:YES];
    [parentVC dismissViewControllerAnimated:YES completion:Nil];
}

@end
