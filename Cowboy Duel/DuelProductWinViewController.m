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
    AccountDataSource __weak *playerAccount;
    CDWeaponProduct *duelProduct;
    UIViewController *parentVC;
    DuelProductDownloaderController *duelProductDownloaderController;
}
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIView *frameView;
@property (weak, nonatomic) IBOutlet UILabel *ribbonLabel;
@property (weak, nonatomic) IBOutlet UILabel * goldTitle;
@property (weak, nonatomic) IBOutlet UILabel * gold;
@property (weak, nonatomic) IBOutlet UIImageView * gunImage;
@property (weak, nonatomic) IBOutlet UIImageView * gunImageMirror;
@property (weak, nonatomic) IBOutlet UIButton * buyItButton;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

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
        
        duelProductDownloaderController = [[DuelProductDownloaderController alloc] init];
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
    gunImage.transform = CGAffineTransformIdentity;
    CGFloat angle = M_PI * 0.15;
    gunImage.transform = CGAffineTransformMakeRotation(angle);
    
    gunImageMirror.clipsToBounds = YES;
    gunImageMirror.image = gunImageSaved;
    gunImageMirror.transform = CGAffineTransformIdentity;
    CGAffineTransform transformMirror = CGAffineTransformMakeScale(-1.0, 1.0);
    gunImageMirror.transform = CGAffineTransformRotate(transformMirror, angle);
    
    if (duelProduct.dCountOfUse == 0) {
        [buyItButton setTitleByLabel:@"BUYITNOW"];
    }else{
        [buyItButton setTitleByLabel:@"USE"];
    }
    
    UIColor *buttonsTitleColor = [[UIColor alloc] initWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    [buyItButton changeColorOfTitleByLabel:buttonsTitleColor];
    
    [ribbonLabel setFont: [UIFont fontWithName: @"DecreeNarrow" size:28]];
    if ([AccountDataSource sharedInstance].accountLevel<duelProduct.dLevelLock) {
        ribbonLabel.text = [NSString stringWithFormat:@"Lock level %d",duelProduct.dLevelLock];
        ribbonLabel.textColor = [UIColor yellowColor];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/DuelProductWinVC" forKey:@"page"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)releaseComponents
{
    playerAccount = nil;
    duelProduct = nil;
    title = nil;
    frameView = nil;
    ribbonLabel = nil;
    goldTitle = nil;
    gold = nil;
    gunImage = nil;
    gunImageMirror = nil;
    buyItButton = nil;
    loadingView = nil;
}

#pragma mark

- (IBAction)closeButtonClick:(id)sender {
    [parentVC dismissViewControllerAnimated:YES completion:Nil];
    [self releaseComponents];
}
- (IBAction)BuyItButtonClick:(id)sender {
    
    if (duelProduct.dCountOfUse == 0) {
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
            transaction.trOpponentID = @"";
            transaction.trGlobalID = [NSNumber numberWithInt:-1];
            
            [playerAccount.transactions addObject:transaction];
            [playerAccount sendTransactions:playerAccount.transactions];
            [playerAccount saveTransaction];
            
            [duelProductDownloaderController buyProductID:duelProduct.dID transactionID:playerAccount.glNumber];
            duelProductDownloaderController.didFinishBlock = ^(NSError *error){
                loadingView.hidden = YES;
                if (error) {
                    buyItButton.enabled = YES;
                }else{
                    playerAccount.money -= duelProduct.dPrice;
                    [playerAccount saveMoney];
                    playerAccount.accountWeapon = duelProduct;
                    playerAccount.curentIdWeapon = duelProduct.dID;
                    [playerAccount saveWeapon];
                    
                    duelProduct.dCountOfUse =1;
                    NSMutableArray *arrWeapon = [DuelProductDownloaderController loadWeaponArray];
                    NSUInteger index=[playerAccount findObsByID](arrWeapon,playerAccount.curentIdWeapon);
                    [arrWeapon replaceObjectAtIndex:index withObject:duelProduct];
                    [DuelProductDownloaderController saveWeapon:arrWeapon];
                }
            };
        }
    }else{
        playerAccount.accountWeapon = duelProduct;
        playerAccount.curentIdWeapon = duelProduct.dID;
        [playerAccount saveWeapon];
        [self closeButtonClick:nil];
    }
}
- (IBAction)GoToStoreClick:(id)sender {
    StoreViewController *svc=[[StoreViewController alloc] initWithAccount:playerAccount];
    [parentVC.navigationController pushViewController:svc animated:YES];
    [parentVC dismissViewControllerAnimated:YES completion:Nil];
    svc = nil;
}

#pragma mark MKStoreKitDelegate

- (void)productPurchased
{
    duelProduct.dCountOfUse =1;
    playerAccount.accountWeapon = duelProduct;
    playerAccount.curentIdWeapon = duelProduct.dID;
    [playerAccount saveWeapon];
    
    NSMutableArray *arrWeapon = [DuelProductDownloaderController loadWeaponArray];
    NSUInteger index=[playerAccount findObsByID](arrWeapon,playerAccount.curentIdWeapon);
    [arrWeapon replaceObjectAtIndex:index withObject:duelProduct];
    [DuelProductDownloaderController saveWeapon:arrWeapon];
    
    [duelProductDownloaderController buyProductID:duelProduct.dID transactionID:-1];
        
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/DuelProductWinVC_purchased" forKey:@"page"]];
    loadingView.hidden = YES;
}

- (void)failed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/DuelProductWinVC_fail" forKey:@"page"]];
    loadingView.hidden = YES;
    buyItButton.enabled = YES;
}


-(void)dealloc;
{
    playerAccount = nil;
    duelProduct = nil;
    parentVC = nil;
    duelProductDownloaderController = nil;
}

@end
