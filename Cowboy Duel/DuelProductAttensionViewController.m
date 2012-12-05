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
#import "UIImage+Save.h"
#import "UIButton+Image+Title.h"
#import "UIView+Frame.h"

@interface DuelProductAttensionViewController ()
{
    AccountDataSource *playerAccount;
    StoreProductCell *productCell;
    CDWeaponProduct *prod;
    UIViewController *parentVC;
}
@property (strong, nonatomic) IBOutlet UILabel *description;
@property (strong, nonatomic) IBOutlet UIView *frameView;

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIImageView *gunIcon;
@property (strong, nonatomic) IBOutlet UIView_Frame *gunIconFrame;
@property (strong, nonatomic) IBOutlet UILabel *goldTitle;
@property (strong, nonatomic) IBOutlet UILabel *gold;
@property (strong, nonatomic) IBOutlet UILabel *effectTitle;
@property (strong, nonatomic) IBOutlet UILabel *effect;
@property (strong, nonatomic) IBOutlet UIButton *buyButton;

@end

@implementation DuelProductAttensionViewController
@synthesize description;
@synthesize title;
@synthesize frameView;
@synthesize gunIcon;
@synthesize gunIconFrame;
@synthesize goldTitle;
@synthesize gold;
@synthesize effectTitle;
@synthesize effect;
@synthesize buyButton;

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
    
    TestAppDelegate *app = (TestAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.adBanner setHidden:YES];
    
    [frameView setDinamicHeightBackground];
    
    description.text = [NSString stringWithFormat:NSLocalizedString(@"ATTEN_TEXT", @""),playerMustShot];
        
    NSArray *arrItemsList = [DuelProductDownloaderController loadWeaponArray];
    
    if (playerAccount.curentIdWeapon==-1) {
        prod=[arrItemsList objectAtIndex:0];
    }else{
        if (playerAccount.curentIdWeapon == ((CDWeaponProduct*)[arrItemsList lastObject]).dID) {
            frameView.hidden = YES;
           //last gun
        }else{
            NSUInteger index=[playerAccount findObsByID](arrItemsList,playerAccount.curentIdWeapon);
            CDWeaponProduct *currentProd = [arrItemsList objectAtIndex:index];
            CDWeaponProduct *tempProduct = [arrItemsList objectAtIndex:++index];
            if(currentProd.dDamage > tempProduct.dDamage) [frameView setHidden:YES];
            else prod = tempProduct;
            //help for gun
        }
    }
    
    [title setFont: [UIFont fontWithName: @"DecreeNarrow" size:25]];
    title.text = prod.dName;
    
    gunIcon.image = [UIImage loadImageFullPath:[NSString stringWithFormat:@"%@/%@",[DuelProductDownloaderController getSavePathForDuelProduct],prod.dImageLocal]];
    
    effect.text = [NSString stringWithFormat:@"+%d",prod.dDamage];
    
    if (prod.dPrice == 0) {
        goldTitle.text=NSLocalizedString(@"Price:", @"");
        gold.text = [NSString stringWithFormat:@"%@",prod.dPurchasePrice];
    }else{
        goldTitle.text=NSLocalizedString(@"Golds:", @"");
        gold.text = [NSString stringWithFormat:@"%d",prod.dPrice];
    }
    
    [gold dinamicAttachToView:goldTitle withDirection:DirectionToAnimateRight];
    
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    if (prod.dCountOfUse == 0) {
        [buyButton setTitleByLabel:@"TRY_IT" withColor:buttonsTitleColor fontSize:24];
    }else{
        [buyButton setTitleByLabel:@"USE" withColor:buttonsTitleColor fontSize:24];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)closeButtonClick:(id)sender {
    [[UIAccelerometer sharedAccelerometer] setDelegate:parentVC];
    [parentVC dismissViewControllerAnimated:YES completion:Nil];
}

+ (BOOL)isAttensionNeedForOponent:(AccountDataSource*)oponentAccount;
{
    playerMustShot = [DuelRewardLogicController countUpBuletsWithOponentLevel:oponentAccount.accountLevel defense:oponentAccount.accountDefenseValue playerAtack:[AccountDataSource sharedInstance].accountWeapon.dDamage];
    oponentMustShot = [DuelRewardLogicController countUpBuletsWithOponentLevel:[AccountDataSource sharedInstance].accountLevel defense:[AccountDataSource sharedInstance].accountDefenseValue playerAtack:oponentAccount.accountWeapon.dDamage];
    DLog(@"Player must shot %d opponent must shot %d", playerMustShot, oponentMustShot);
    if ((playerMustShot-oponentMustShot)>=2){
        return YES;
    }else{
        return NO;
    }
}
#pragma mark - TableCellWithButton methods
- (IBAction)buyButtonClick:(id)sender {
    [playerAccount saveWeapon];
    playerAccount.isTryingWeapon = YES;
    playerAccount.accountWeapon = prod;
    [self closeButtonClick:Nil];
}
@end
