//
//  BuilderViewController.m
//  Bounty Hunter
//
//  Created by Alex Novitsky on 5/6/13.
//
//
#import "ProfileViewController.h"
#import "BuilderViewController.h"
#import "AccountDataSource.h"
#import "DuelRewardLogicController.h"
#import "StartViewController.h"
#import "VisualViewDataSource.h"
#import "VisualViewCharacter.h"

@interface BuilderViewController ()
{
    SSServer *playerServer;
    AccountDataSource *playerAccount;
    ProfileViewController *profileViewController;
    BOOL isOpenSide;
    
    __weak IBOutlet VisualViewCharacter *visualViewCharacter;

}
@property (weak, nonatomic) IBOutlet UIView *gunView1;
@property (weak, nonatomic) IBOutlet UIView *sideView;
@property (weak, nonatomic) IBOutlet UIScrollView *gunsScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *hatsScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *jaketScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *shirtScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *faceScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *shoesScroll;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *defensLabel;
@property (weak, nonatomic) IBOutlet UILabel *attacLabel;

@end

@implementation BuilderViewController
@synthesize visualViewDataSource;
- (IBAction)touchCloseBtn:(id)sender {
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                     }];
    [self.navigationController popViewControllerAnimated:NO];
    
    [self releaseComponents];
}

- (IBAction)touchCloseSideView:(id)sender {
    [self sideCloseAnimation];
}

- (IBAction)touchHatBtn:(id)sender {
    self.hatsScroll.hidden = NO;
    [self sideOpenAnimation];
    
}
- (IBAction)touchFaceBtn:(id)sender {
    self.faceScroll.hidden = NO;
      [self sideOpenAnimation];
}
- (IBAction)touchShirtBtn:(id)sender {
    self.shirtScroll.hidden = NO;
      [self sideOpenAnimation];
}
- (IBAction)touchJaketBtn:(id)sender {
    self.jaketScroll.hidden = NO;
      [self sideOpenAnimation];
}
- (IBAction)touchShoesBtn:(id)sender {
    self.shoesScroll.hidden = NO;
      [self sideOpenAnimation];
}
- (IBAction)touchGunsBtn:(id)sender {
    self.gunsScroll.hidden = NO;
      [self sideOpenAnimation];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isOpenSide = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hatsScroll.pagingEnabled = YES;
    self.hatsScroll.contentSize = CGSizeMake(77, 600);
    
    playerAccount = [[AccountDataSource alloc] initWithLocalPlayer];
    self.moneyLabel.text =  [NSString stringWithFormat:@"%d",playerAccount.money];
    self.defensLabel.text = [NSString stringWithFormat:@"%d",playerAccount.accountDefenseValue];
    self.attacLabel.text = [NSString stringWithFormat:@"%d",playerServer.weapon + [DuelRewardLogicController countUpBuletsWithPlayerLevel:[playerServer.rank intValue]]];
}
 
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)sideOpenAnimation{
    if (!isOpenSide) {
        isOpenSide = YES;
    [UIView animateWithDuration:0.6 animations:^{
       CGRect frame = self.sideView.frame;
        frame.origin.x -= 100;
        self.sideView.frame = frame;
        
    }completion:^(BOOL finished) {
    }];

    }

}
-(void)sideCloseAnimation{
    if (isOpenSide) {
        isOpenSide = NO;
    [UIView animateWithDuration:0.6 animations:^{
        CGRect frame = self.sideView.frame;
        frame.origin.x += 100;
        self.sideView.frame = frame;
        
    }completion:^(BOOL finished) {
          self.hatsScroll.hidden = YES;
          self.jaketScroll.hidden = YES;
          self.faceScroll.hidden = YES;
          self.shoesScroll.hidden = YES;
          self.shirtScroll.hidden = YES;
          self.gunsScroll.hidden = YES;
        
    }];
    }
    
    
}
- (void)viewDidUnload {
    [self setGunView1:nil];
    [self setSideView:nil];
    [self setGunsScroll:nil];
    [self setHatsScroll:nil];
    [self setJaketScroll:nil];
    [self setShirtScroll:nil];
    [self setFaceScroll:nil];
    [self setShoesScroll:nil];
    [self setMoneyLabel:nil];
    [self setDefensLabel:nil];
    [self setAttacLabel:nil];
    [super viewDidUnload];
}
-(void)releaseComponents

{
    [self setGunView1:nil];
    [self setSideView:nil];
    [self setGunsScroll:nil];
    [self setHatsScroll:nil];
    [self setJaketScroll:nil];
    [self setShirtScroll:nil];
    [self setFaceScroll:nil];
    [self setShoesScroll:nil];
    [self setMoneyLabel:nil];
    [self setDefensLabel:nil];
    [self setAttacLabel:nil];

}
@end
