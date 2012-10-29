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

@interface DuelProductWinViewController ()
{
    AccountDataSource *playerAccount;
}
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIView *frameView;
@property (strong, nonatomic) IBOutlet UILabel *ribbonLabel;
@property (strong, nonatomic) IBOutlet UILabel * coldTitle;
@property (strong, nonatomic) IBOutlet UILabel * gold;
@property (strong, nonatomic) IBOutlet UIImageView * gunImage;
@property (strong, nonatomic) IBOutlet UIButton * buyItButton;

@end

@implementation DuelProductWinViewController
@synthesize title;
@synthesize frameView;
@synthesize ribbonLabel;
@synthesize coldTitle;
@synthesize gold;
@synthesize gunImage;
@synthesize buyItButton;
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
    
    [title setFont: [UIFont fontWithName: @"DecreeNarrow" size:28]];
    title.text = NSLocalizedString(@"IT_HELP", @"");
    
    [ribbonLabel setFont: [UIFont fontWithName: @"DecreeNarrow" size:28]];
    
    [buyItButton setTitleByLabel:@"BUYITNOW"];
    UIColor *buttonsTitleColor = [[UIColor alloc] initWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    [buyItButton changeColorOfTitleByLabel:buttonsTitleColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)closeButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)BuyItButtonClick:(id)sender {
}

@end
