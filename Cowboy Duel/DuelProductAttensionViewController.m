//
//  DuelProductAttensionViewController.m
//  Cowboy Duels
//
//  Created by Taras on 26.10.12.
//
//

#import "DuelProductAttensionViewController.h"
#import "StoreProductCell.h"
#import "DuelProductDownloaderController.h"
#import "FXLabel.h"
#import "UIView+Dinamic_BackGround.h"
#import "CDWeaponProduct.h"
#import "DuelRewardLogicController.h"

@interface DuelProductAttensionViewController ()
{
    AccountDataSource *playerAccount;
    StoreProductCell *productCell;
    CDDuelProduct *prod;
    UIViewController *parentVC;
}
@property (strong, nonatomic) IBOutlet FXLabel *title;
@property (strong, nonatomic) IBOutlet UIView *frameView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation DuelProductAttensionViewController
@synthesize title;
@synthesize frameView;
@synthesize webView;

static int playerMustShot;
static int oponentMustShot;

- (id)initWithAccount:(AccountDataSource*)account parentVC:(UIViewController*)vc;
{
    self = [super initWithNibName:Nil bundle:Nil];
    if (self) {
        playerAccount = account;
        parentVC = vc;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [frameView setDinamicHeightBackground];
    StoreProductCell *cell = [StoreProductCell cellAttension];
    [cell initMainControlsWithNarrowBackGround];
    
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:DUEL_PRODUCTS_WEAPONS];
    NSArray *arrItemsList = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    
    prod=[arrItemsList objectAtIndex:0];
    [cell populateWithProduct:prod targetToBuyButton:self cellType:StoreDataSourceTypeTablesWeapons];
    CGRect frame= cell.frame;
    frame.origin.x = 0;
    frame.origin.y = frameView.frame.origin.y + frameView.frame.size.height-14;
    cell.frame = frame;
    [self.view insertSubview:cell belowSubview:frameView];
    
    title.text = NSLocalizedString(@"Atten", @"");
    [title setAdjustsFontSizeToFitWidth:YES];
    [title setShadowColor:[UIColor colorWithRed:1.f green:253.f/255.f blue:178.f/255.f alpha:1]];
    [title setShadowOffset:CGSizeMake(0, 0)];
    title.shadowBlur=2.f;
    title.font = [UIFont fontWithName: @"MyriadPro-Bold" size:55];
    [title setGradientEndColor:[UIColor colorWithRed:1.0f green:140.f/255.f blue:0 alpha:1.0]];
    [title setGradientStartColor:[UIColor colorWithRed:1.0f green:181.f/255.f blue:0 alpha:1.0]];
    title.shadowOffset = CGSizeZero;
    title.innerShadowColor = [UIColor colorWithRed:137.f/255.f green:81.f/255.f blue:0.f alpha:1];
    title.innerShadowOffset = CGSizeMake(1.0f, 1.0f);
    
    [webView setOpaque:NO];
    [webView.scrollView setScrollEnabled:NO];
    [webView setBackgroundColor:[UIColor clearColor]];
    NSString *webTesxt = [NSString stringWithFormat:@"%@%d%@%d%@",NSLocalizedString(@"ATTEN_WEB_TEXT1", @""),playerMustShot,NSLocalizedString(@"ATTEN_WEB_TEXT2", @""),oponentMustShot,NSLocalizedString(@"ATTEN_WEB_TEXT3", @"")];
    [webView loadHTMLString:webTesxt baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

-(void)viewWillAppear:(BOOL)animated
{
    webView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)closeButtonClick:(id)sender {
    [parentVC dismissViewControllerAnimated:YES completion:Nil];
}

+ (BOOL)isAttensionNeedForOponent:(AccountDataSource*)oponentAccount;
{
    playerMustShot = [DuelRewardLogicController countUpBuletsWithOponentLevel:oponentAccount.accountLevel defense:oponentAccount.accountDefenseValue playerAtack:[AccountDataSource sharedInstance].accountWeapon.dDamage];
    oponentMustShot = [DuelRewardLogicController countUpBuletsWithOponentLevel:[AccountDataSource sharedInstance].accountLevel defense:[AccountDataSource sharedInstance].accountDefenseValue playerAtack:oponentAccount.accountWeapon.dDamage];
    
    if ((playerMustShot-oponentMustShot)>=2) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark - TableCellWithButton methods

-(void)buyButtonClick:(id)sender;
{
    playerAccount.accountWeapon = ((CDWeaponProduct*)prod);
    [self closeButtonClick:Nil];
}

@end
