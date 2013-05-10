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
    __weak IBOutlet UICollectionView *vCollection;
    
    GMGridView *grid;
    NSArray *arrObjects;
}
@property (weak, nonatomic) IBOutlet UIView *sideView;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *defensLabel;
@property (weak, nonatomic) IBOutlet UILabel *attacLabel;

@end

@implementation BuilderViewController
@synthesize visualViewDataSource;

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
    
    visualViewDataSource = [[VisualViewDataSource alloc] init];
    visualViewCharacter.visualViewDataSource = visualViewDataSource;
    arrObjects = [NSArray array];
    
    grid = [[GMGridView alloc] initWithFrame:CGRectMake(20, 8, 78, 423)];
    grid.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    grid.minEdgeInsets = UIEdgeInsetsMake(0,0,0,0);
    grid.itemSpacing = 0;
    
    grid.backgroundColor = [UIColor clearColor];
    grid.showsHorizontalScrollIndicator = NO;
    grid.showsVerticalScrollIndicator = NO;
    grid.dataSource = self;
    grid.delegate = self;
    
    [self.sideView addSubview:grid];
    
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
- (void)viewDidUnload {
    [self setSideView:nil];
    [self setMoneyLabel:nil];
    [self setDefensLabel:nil];
    [self setAttacLabel:nil];
    vCollection = nil;
    [super viewDidUnload];
}
-(void)releaseComponents

{
    [self setSideView:nil];
    [self setMoneyLabel:nil];
    [self setDefensLabel:nil];
    [self setAttacLabel:nil];

}
#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return 30;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(78, 70);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    GMGridViewCell * cell = nil;;
    cell = [gridView dequeueReusableCellWithIdentifier:@"object"];
    
    if (cell == nil)
    {
        cell = [[GMGridViewCell alloc] init];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 78, 70)];
        cell.contentView = view;
        [cell.contentView setUserInteractionEnabled:NO];
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 78, 70)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:imageView];
    
//    CDVisualViewCharacterPart *visualViewCharacterPart = [arrObjects objectAtIndex:index];
//    imageView.image = [visualViewCharacterPart imageForObject];
    
    return cell;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    
//    NSInteger curentObjectIndexScrool = abs(scrollView.contentOffset.x/self.frame.size.width);
//    if (curentObject!=curentObjectIndexScrool) {
//        curentObject = curentObjectIndexScrool;
//        if (didFinishBlock) {
//            didFinishBlock(curentObject);
//        }
//    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
//    if (self.lastQuestionOffset > scrollView.contentOffset.x)
//        self.currentPage = MAX(self.currentPage - 1, 0);
//    else if (self.lastQuestionOffset < scrollView.contentOffset.x)
//        self.currentPage = MIN(self.currentPage + 1, 2);
//    
//    float questionOffset = 290.0 * self.currentPage;
//    self.lastQuestionOffset = questionOffset;
//    [self.collectionView setContentOffset:CGPointMake(questionOffset, 0) animated:YES];
}

#pragma mark Animation
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
            
        }];
    }
    
    
}

-(void)setObjectsForIndex:(NSInteger)index;
{
    [grid scrollToObjectAtIndex:index atScrollPosition:GMGridViewScrollPositionNone animated:NO];
}
#pragma mark IBAction 
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
    
}
- (IBAction)touchFaceBtn:(id)sender {
    
}
- (IBAction)touchShirtBtn:(id)sender {
    
}
- (IBAction)touchJaketBtn:(id)sender {
    
}
- (IBAction)touchShoesBtn:(id)sender {
    
}
- (IBAction)touchGunsBtn:(id)sender {
    
}
#pragma mark

@end
