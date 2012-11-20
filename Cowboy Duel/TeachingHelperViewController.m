//
//  TeachingHelperViewController.m
//  Cowboy Duels
//
//  Created by Taras on 15.11.12.
//
//

#import "TeachingHelperViewController.h"
#import "UIView+Dinamic_BackGround.h"
#import "UIButton+Image+Title.h"
#import "DuelRewardLogicController.h"

static CGFloat const ANIMATION_TIME = 0.4f;
static CGFloat const DELAY_BETWEEN_ANIMATION = 3.f;

@interface TeachingHelperViewController ()
{
    AccountDataSource *opAccount;
    CGPoint pointStart;
    CGPoint pointForView;
    CGPoint pointForViewWithArrow;
}
@property (strong, nonatomic) IBOutlet UILabel *mainHelpLabel;
@property (strong, nonatomic) IBOutlet UILabel *labelBullets;

@property (strong, nonatomic) IBOutlet UIView *viewFire;
@property (strong, nonatomic) IBOutlet UIView *viewFireInside;
@property (strong, nonatomic) IBOutlet UILabel *labelFireDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelFireTitle;

@property (strong, nonatomic) IBOutlet UIView *viewSound;
@property (strong, nonatomic) IBOutlet UIView *viewHand;

@property (strong, nonatomic) IBOutlet UIButton *buttonBack;

@end

@implementation TeachingHelperViewController
@synthesize mainHelpLabel;
@synthesize labelBullets;
@synthesize viewFire;
@synthesize viewFireInside;
@synthesize labelFireDescription;
@synthesize viewSound;
@synthesize viewHand;
@synthesize buttonBack;
@synthesize labelFireTitle;

-(id)initWithOponentAccount:(AccountDataSource *)oponentAccount;
{
    self = [self initWithNibName:@"TeachingHelperController" bundle:[NSBundle mainBundle]];
    if (self) {
        opAccount = oponentAccount;
    }
    return self;
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    mainHelpLabel.text = NSLocalizedString(@"WAIT", @"");
    
    [buttonBack setTitleByLabel:@"BACK"];
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    [buttonBack changeColorOfTitleByLabel:btnColor];
    
    AccountDataSource *playerAccount = [AccountDataSource sharedInstance];
    int countBullets = [DuelRewardLogicController countUpBuletsWithOponentLevel:opAccount.accountLevel defense:opAccount.accountDefenseValue playerAtack:playerAccount.accountWeapon.dDamage];
    labelBullets.text=[NSString stringWithFormat:@"%d",countBullets];
    
    labelFireDescription.text = NSLocalizedString(@"SHOTS_DES", @"");
    labelFireTitle.text=[NSString stringWithFormat:@"%@ %d %@",NSLocalizedString(@"SHOTS1", @""),countBullets,NSLocalizedString(@"SHOTS2", @"")];

    [viewFireInside setDinamicHeightBackground];
    [viewSound setDinamicHeightBackground];
    [viewHand setDinamicHeightBackground];
    
    pointStart = CGPointMake(12, [[UIScreen mainScreen] bounds].size.height+10);
    pointForView = CGPointMake(12, pointStart.y-248);
    pointForViewWithArrow = CGPointMake(12, pointForView.y-8);
    
    CGRect frame = viewFire.frame;
    frame.origin = pointStart;
    viewFire.frame = frame;
    
    frame = viewSound.frame;
    frame.origin = pointStart;
    viewSound.frame = frame;
    
    frame = viewHand.frame;
    frame.origin = pointStart;
    viewHand.frame = frame;
    [self performSelector:@selector(firstAnimation) withObject:nil afterDelay:0.2f];
}

-(void)viewDidAppear:(BOOL)animated
{
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark

-(void)firstAnimation;
{
    [UIView animateWithDuration:ANIMATION_TIME
                     animations:^{
                         CGRect frame = viewFire.frame;
                         frame.origin = pointForViewWithArrow;
                         viewFire.frame = frame;
                     }];
    [self performSelector:@selector(secondAnimation) withObject:nil afterDelay:DELAY_BETWEEN_ANIMATION];
}

-(void)secondAnimation;
{
    [UIView animateWithDuration:ANIMATION_TIME
                     animations:^{
                         CGRect frame = viewFire.frame;
                         frame.origin = pointStart;
                         viewFire.frame = frame;
                         
                         mainHelpLabel.hidden = YES;
                     }
                     completion:^(BOOL finised){
                         [UIView animateWithDuration:ANIMATION_TIME
                                          animations:^{
                                              CGRect frame = viewSound.frame;
                                              frame.origin = pointForView;
                                              viewSound.frame = frame;
                                          }];
                     }];
    [self performSelector:@selector(thirdAnimation) withObject:nil afterDelay:DELAY_BETWEEN_ANIMATION];
}

-(void)thirdAnimation;
{
    [UIView animateWithDuration:ANIMATION_TIME
                     animations:^{
                         CGRect frame = viewSound.frame;
                         frame.origin = pointStart;
                         viewSound.frame = frame;
                     }
                     completion:^(BOOL finised){
                         [UIView animateWithDuration:ANIMATION_TIME
                                          animations:^{
                                              CGRect frame = viewHand.frame;
                                              frame.origin = pointForView;
                                              viewHand.frame = frame;
                                          }];
                     }];
    [self performSelector:@selector(fourthAnimation) withObject:nil afterDelay:DELAY_BETWEEN_ANIMATION];
}

-(void)fourthAnimation;
{
    [UIView animateWithDuration:ANIMATION_TIME
                     animations:^{
                         CGRect frame = viewHand.frame;
                         frame.origin = pointStart;
                         viewHand.frame = frame;
                     }];
   [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark

- (IBAction)buttonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    mainHelpLabel = nil;
    labelBullets = nil;
    viewFire = nil;
    labelFireDescription = nil;
    viewSound = nil;
    viewHand = nil;
}
@end
