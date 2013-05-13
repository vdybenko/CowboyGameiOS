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
    __weak IBOutlet UIView *vArrow;
    __weak IBOutlet GMGridView *grid;
    
    NSArray *arrObjects;
    
    float lastQuestionOffset;
    int currentPage;
}
@property (weak, nonatomic) IBOutlet UIView *sideView;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *defensLabel;
@property (weak, nonatomic) IBOutlet UILabel *attacLabel;

@end

@implementation BuilderViewController
@synthesize visualViewDataSource;
@synthesize didFinishBlock;
@synthesize didBuyAction;
@synthesize curentObject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isOpenSide = NO;
        curentObject = 0;
        lastQuestionOffset = 0;
        currentPage = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    visualViewDataSource = [[VisualViewDataSource alloc] init];
    visualViewCharacter.visualViewDataSource = visualViewDataSource;
    arrObjects = [NSArray array];
    
    arrObjects = [visualViewDataSource arrayCap];
    
//    grid = [[GMGridView alloc] initWithFrame:CGRectMake(20, 8, 78, 423)];
    grid.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    grid.minEdgeInsets = UIEdgeInsetsMake(0,0,0,0);
    grid.itemSpacing = 10;
    
    grid.backgroundColor = [UIColor clearColor];
    grid.showsHorizontalScrollIndicator = NO;
    grid.showsVerticalScrollIndicator = NO;
    grid.dataSource = self;
    grid.actionDelegate = self;
    grid.delegate = self;
    
//    [self.sideView insertSubview:grid belowSubview:vArrow];
    
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
    vArrow = nil;
    grid = nil;
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
    return 30+4;
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
    
    int lastIndex = [self numberOfItemsInGMGridView:gridView]-1;
    int penultIndex = [self numberOfItemsInGMGridView:gridView]-2;
    
    if (index!=0 && index!=1 && index!=lastIndex && index!=penultIndex) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 78, 70)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
        
        if ([arrObjects count]) {
            int indexr = random() % 4;
            CDVisualViewCharacterPart *visualViewCharacterPart = [arrObjects objectAtIndex:indexr];
            imageView.image = [visualViewCharacterPart imageForObject];
        }
    }    
    return cell;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    int countOfElements = abs(scrollView.contentOffset.y/80);
    
    float questionOffset = 80 * countOfElements;
    if (questionOffset+40<=abs(scrollView.contentOffset.y)) {
        curentObject = countOfElements+1;
        questionOffset = 80 * curentObject;
    }else{
        curentObject = countOfElements;
    }
    if (scrollView.contentOffset.y<0) {
        questionOffset = -questionOffset;
    }
    
    [scrollView setContentOffset:CGPointMake(0,questionOffset) animated:YES];
    
    if (curentObject !=  countOfElements){
        curentObject = countOfElements;
        if (didFinishBlock) {
            didFinishBlock(curentObject);
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if (!decelerate) {
        int countOfElements = abs(scrollView.contentOffset.y/80);
        
        float questionOffset = 80 * countOfElements;
        if (questionOffset+40<=abs(scrollView.contentOffset.y)) {
            countOfElements = countOfElements+1;
            questionOffset = 80 * countOfElements;
        }
        
        if (scrollView.contentOffset.y<0) {
            questionOffset = -questionOffset;
        }
        
        [scrollView setContentOffset:CGPointMake(0,questionOffset) animated:YES];
        
        if (curentObject !=  countOfElements){
            curentObject = countOfElements;
            
            if (didFinishBlock) {
                didFinishBlock(curentObject);
            }
        }
    }
}

#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position;
{
    [grid scrollToObjectAtIndex:position atScrollPosition:GMGridViewScrollPositionNone animated:YES];
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
    arrObjects = [visualViewDataSource arrayHead];
    didFinishBlock = ^(NSInteger curentIndex){
       
        
    [self refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        
        [self refreshController];
    };


}
- (IBAction)touchFaceBtn:(id)sender {
    arrObjects = [visualViewDataSource arrayCap];
    didFinishBlock = ^(NSInteger curentIndex){
        
        
        [self refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        
        [self refreshController];
    };


}
- (IBAction)touchShirtBtn:(id)sender {
    arrObjects = [visualViewDataSource arrayBody];
    didFinishBlock = ^(NSInteger curentIndex){
        
        
        [self refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        
        [self refreshController];
    };


}
- (IBAction)touchJaketBtn:(id)sender {
    arrObjects = [visualViewDataSource arrayJakets];
    didFinishBlock = ^(NSInteger curentIndex){
        
        
        [self refreshController];
    };

}
- (IBAction)touchShoesBtn:(id)sender {
    arrObjects = [visualViewDataSource arrayShoose];
    didFinishBlock = ^(NSInteger curentIndex){
        
        
        [self refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        
        [self refreshController];
    };


}
- (IBAction)touchGunsBtn:(id)sender {
    arrObjects = [visualViewDataSource arrayGuns];
    didFinishBlock = ^(NSInteger curentIndex){
        
        
        [self refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        
        [self refreshController];
    };


}
- (IBAction)touchPantsBtn:(id)sender {
     arrObjects = [visualViewDataSource arrayLegs];
    didFinishBlock = ^(NSInteger curentIndex){
        
        
        [self refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        
        [self refreshController];
    };


}
#pragma mark

-(void)refreshController;
{
    
}

@end
