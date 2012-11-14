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
#import <QuartzCore/QuartzCore.h>

@interface DuelProductWinViewController ()
{
    AccountDataSource *playerAccount;
    CDWeaponProduct *duelProduct;
    UIViewController *parentVC;
    DuelProductDownloaderController *duelProductDownloaderController;
}
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIView *frameView;
@property (strong, nonatomic) IBOutlet UILabel *ribbonLabel;
@property (strong, nonatomic) IBOutlet UILabel * goldTitle;
@property (strong, nonatomic) IBOutlet UILabel * gold;
@property (strong, nonatomic) IBOutlet UIImageView * gunImage;
@property (strong, nonatomic) IBOutlet UIImageView * gunImageMirror;
@property (strong, nonatomic) IBOutlet UIButton * buyItButton;
@property (strong, nonatomic) IBOutlet UIView *loadingView;

@end

@implementation DuelProductWinViewController
@synthesize title;
@synthesize frameView;
@synthesize ribbonLabel;
@synthesize goldTitle;
@synthesize gold;
@synthesize gunImage;
@synthesize gunImageMirror;
@synthesize buyItButton;
@synthesize loadingView;

#pragma mark
- (id)initWithAccount:(AccountDataSource*)account duelProduct:(CDWeaponProduct*)product parentVC:(UIViewController*)vc;
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
    
    UIImage *gunImageSaved = [UIImage loadImageFullPath:[NSString stringWithFormat:@"%@/%@",[DuelProductDownloaderController getSavePathForDuelProduct],duelProduct.dImageLocal]];
    gunImage.clipsToBounds = YES;
    gunImage.image = gunImageSaved;
    
    gunImageMirror.clipsToBounds = YES;
    gunImageMirror.image = gunImageSaved;
    gunImageMirror.transform = CGAffineTransformIdentity;
    gunImageMirror.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    
    [buyItButton setTitleByLabel:@"BUYITNOW"];
    UIColor *buttonsTitleColor = [[UIColor alloc] initWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    [buyItButton changeColorOfTitleByLabel:buttonsTitleColor];
    
    [ribbonLabel setFont: [UIFont fontWithName: @"DecreeNarrow" size:28]];
    if ([AccountDataSource sharedInstance].accountLevel>duelProduct.dLevelLock) {
        ribbonLabel.text = [NSString stringWithFormat:@"Lock level %d",duelProduct.dLevelLock];
        ribbonLabel.textColor = [UIColor redColor];
        buyItButton.enabled = NO;
    }else{
        ribbonLabel.text = duelProduct.dName;
    }
    
    if (duelProduct.dPrice == 0) {
        goldTitle.text = NSLocalizedString(@"Price", @"");
    }else{
        goldTitle.text = NSLocalizedString(@"Gold", @"");
        gold.text = [NSString stringWithFormat:@"%d",duelProduct.dPrice];
    }
    [goldTitle dinamicAttachToView:gold withDirection:DirectionToAnimateRight];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MKStoreManager sharedManager].delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark

- (IBAction)closeButtonClick:(id)sender {
    [parentVC dismissViewControllerAnimated:YES completion:Nil];
}
- (IBAction)BuyItButtonClick:(id)sender {
    if (duelProduct.dPrice==0) {
        loadingView.hidden = NO;
        [[MKStoreManager sharedManager] buyFeature:duelProduct.dPurchaseUrl];
    }else{
        buyItButton.enabled = NO;
        CDTransaction *transaction = [[CDTransaction alloc] init];
        transaction.trDescription = [[NSString alloc] initWithFormat:@"BuyProductWin"];
        transaction.trType = [NSNumber numberWithInt:-1];
        transaction.trMoneyCh = [NSNumber numberWithInt:-duelProduct.dPrice];
        transaction.trLocalID = [NSNumber numberWithInt:[playerAccount increaseGlNumber]];
        [playerAccount.transactions addObject:transaction];
        [playerAccount sendTransactions:playerAccount.transactions];
        [playerAccount saveTransaction];
        
        playerAccount.money -= duelProduct.dPrice;
        [playerAccount saveMoney];
        playerAccount.accountWeapon = duelProduct;
        playerAccount.curentIdWeapon = duelProduct.dID;
        [playerAccount saveWeapon];
        
        [duelProductDownloaderController buyProductID:duelProduct.dID transactionID:playerAccount.glNumber];
        duelProductDownloaderController.didFinishBlock = ^(NSError *error){
            buyItButton.enabled = YES;
        };
        
        duelProduct.dCountOfUse =1;
        NSMutableArray *arrWeapon = [DuelProductDownloaderController loadWeaponArray];
        NSUInteger index=[playerAccount findObs](arrWeapon,playerAccount.curentIdWeapon);
        [arrWeapon replaceObjectAtIndex:index withObject:duelProduct];
        [DuelProductDownloaderController saveWeapon:arrWeapon];
        
        [self closeButtonClick:nil];
    }
}
- (IBAction)GoToStoreClick:(id)sender {
    StoreViewController *svc=[[StoreViewController alloc] initWithAccount:playerAccount];
    [parentVC.navigationController pushViewController:svc animated:YES];
    [parentVC dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark MKStoreKitDelegate

- (void)productPurchased
{
    duelProduct.dCountOfUse =1;
    playerAccount.accountWeapon = duelProduct;
    playerAccount.curentIdWeapon = duelProduct.dID;
    [playerAccount saveWeapon];
    
    NSMutableArray *arrWeapon = [DuelProductDownloaderController loadWeaponArray];
    NSUInteger index=[playerAccount findObs](arrWeapon,playerAccount.curentIdWeapon);
    [arrWeapon replaceObjectAtIndex:index withObject:duelProduct];
    [DuelProductDownloaderController saveWeapon:arrWeapon];
    
    [duelProductDownloaderController buyProductID:duelProduct.dID transactionID:-1];
        
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/buy_product_win" forKey:@"event"]];
    loadingView.hidden = YES;
}

- (void)failed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/buy_product_fail" forKey:@"event"]];
    loadingView.hidden = YES;
}


-(void)dealloc;
{
    playerAccount = nil;
    duelProduct = nil;
    parentVC = nil;
    duelProductDownloaderController = nil;
}

@end
