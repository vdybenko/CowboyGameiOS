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
#import "CharacterPartGridCell.h"
#import "CDTransaction.h"
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
}
@property (weak, nonatomic) IBOutlet UIView *sideView;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *defensLabel;
@property (weak, nonatomic) IBOutlet UILabel *attacLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceOfItem;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    visualViewDataSource = [[VisualViewDataSource alloc] init];
    visualViewCharacter.visualViewDataSource = visualViewDataSource;
    arrObjects = [NSArray array];
    
    grid.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    grid.minEdgeInsets = UIEdgeInsetsMake(0,0,0,0);
    grid.itemSpacing = 10;
    
    grid.backgroundColor = [UIColor clearColor];
    grid.showsHorizontalScrollIndicator = NO;
    grid.showsVerticalScrollIndicator = NO;
    grid.dataSource = self;
    grid.actionDelegate = self;
    grid.delegate = self;
        
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
    [self setPriceOfItem:nil];
    [self setResultLabel:nil];
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
    return [arrObjects count]+4;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(78, 70);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CharacterPartGridCell * cell = nil;;
    cell = (CharacterPartGridCell *)[gridView dequeueReusableCellWithIdentifier:@"object"];
    
    if (cell == nil)
    {
        cell = [CharacterPartGridCell cell];;
    }
        
    int lastIndex = [self numberOfItemsInGMGridView:gridView]-1;
    int penultIndex = [self numberOfItemsInGMGridView:gridView]-2;
    
    if (index!=0 && index!=1 && index!=lastIndex && index!=penultIndex) {
        [cell setHidden:NO];
        [cell simpleBackGround];
        CDVisualViewCharacterPart *visualViewCharacterPart = [arrObjects objectAtIndex:index-2];
        cell.ivImage.image = [visualViewCharacterPart imageForObject];
    }else{
        [cell setHidden:YES];
    }
    return cell;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    int countOfElements = abs(scrollView.contentOffset.y/80);
    
    float questionOffset = 80 * countOfElements;
    
    int countObjects = [self numberOfItemsInGMGridView:grid];

    if ((questionOffset+40<=abs(scrollView.contentOffset.y))&&(countOfElements!=countObjects-5)) {
        countOfElements = countOfElements+1;
        questionOffset = 80 * countOfElements;
    }
    
    if (scrollView.contentOffset.y<0) {
        questionOffset = -questionOffset;
    }
    
    [scrollView setContentOffset:CGPointMake(0,questionOffset) animated:YES];
    
    if (curentObject !=  countOfElements){
        CharacterPartGridCell * cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
        [cell simpleBackGround];
        
        curentObject = countOfElements;
        
        cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
        [cell selectedBackGround];
        
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
            CharacterPartGridCell * cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
            [cell simpleBackGround];
            
            curentObject = countOfElements;
            
            cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
            [cell selectedBackGround];
            
            if (didFinishBlock) {
                didFinishBlock(curentObject);
            }
        }
    }
}

#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position;
{
    int lastIndex = [self numberOfItemsInGMGridView:gridView]-1;
    int penultIndex = [self numberOfItemsInGMGridView:gridView]-2;
    
    if (position!=0 && position!=1 && position!=lastIndex && position!=penultIndex && position!=curentObject+2) {
        
        float questionOffset = 80 * (position-2);
        
        [grid setContentOffset:CGPointMake(0,questionOffset) animated:YES];
        
        CharacterPartGridCell * cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
        [cell simpleBackGround];
        
        curentObject = position-2;
        
        cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
        [cell selectedBackGround];
        
        if (didFinishBlock) {
            didFinishBlock(curentObject);
        }
    }
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
    __block id  selfBlock = self;
    __block id  arrObjBlock = arrObjects;
    __block VisualViewCharacter *viewCharacterBlock = visualViewCharacter;
    __block id  priceLbBlock = self.priceOfItem;
     __block id  bonus = self.resultLabel;
   // __block id  bonus = self.resultLabel;
    didFinishBlock = ^(NSInteger curentIndex){
      CDVisualViewCharacterPartHead *cap = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.head.image = cap.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"%d", cap.money]];
            [bonus setText:[NSString stringWithFormat:@"0"]];
        });
        [selfBlock refreshController];

    };
    didBuyAction = ^(NSInteger curentIndex){
       
        [selfBlock refreshController];
    };

    [grid reloadData];
    [self sideOpenAnimation];

}
- (IBAction)touchFaceBtn:(id)sender {
    arrObjects = [visualViewDataSource arrayCap];
    __block id  selfBlock = self;
    __block id  arrObjBlock = arrObjects;
    __block VisualViewCharacter *viewCharacterBlock = visualViewCharacter;
    __block id  priceLbBlock = self.priceOfItem;
    __block id  bonus = self.resultLabel;

    didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartCap *cap = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.cap.image = cap.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"%d", cap.money]];
            [bonus setText:[NSString stringWithFormat:@"+ %d",cap.action]];

        });
        [selfBlock refreshController];
        
    };
    didBuyAction = ^(NSInteger curentIndex){
        [selfBlock refreshController];
    };


    [grid reloadData];
    [self sideOpenAnimation];

}
- (IBAction)touchShirtBtn:(id)sender {
    __block id  priceLbBlock = self.priceOfItem;
    __block id  bonus = self.resultLabel;

    arrObjects = [visualViewDataSource arrayBody];
    __block id  selfBlock = self;
    __block id  arrObjBlock = arrObjects;
    __block VisualViewCharacter *viewCharacterBlock = visualViewCharacter;
    didFinishBlock = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartBody *cap = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.body.image = cap.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"%d", cap.money]];
            [bonus setText:[NSString stringWithFormat:@"+ %d",cap.action]];
          


        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        
        [selfBlock refreshController];
    };
    [grid reloadData];
    [self sideOpenAnimation];
}
- (IBAction)touchJaketBtn:(id)sender {
    arrObjects = [visualViewDataSource arrayJakets];
    __block id  selfBlock = self;
    __block id  arrObjBlock = arrObjects;
    __block VisualViewCharacter *viewCharacterBlock = visualViewCharacter;
    __block id  priceLbBlock = self.priceOfItem;
    __block id  bonus = self.resultLabel;

    didFinishBlock = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartJakets *cap = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.shirt.image = cap.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"%d", cap.money]];
            [bonus setText:[NSString stringWithFormat:@"+ %d",cap.action]];

        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
      
        [selfBlock refreshController];
    };
    [grid reloadData];
    [self sideOpenAnimation];
}
- (IBAction)touchShoesBtn:(id)sender {
    arrObjects = [visualViewDataSource arrayShoose];
    __block id  selfBlock = self;
    __block id  arrObjBlock = arrObjects;
    __block VisualViewCharacter *viewCharacterBlock = visualViewCharacter;
    __block id  priceLbBlock = self.priceOfItem;
    __block id  bonus = self.resultLabel;

    didFinishBlock = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartShoose *cap = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.shoose.image = cap.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"%d", cap.money] ];
            [bonus setText:[NSString stringWithFormat:@"+ %d",cap.action]];
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        
        [selfBlock refreshController];
    };
    [grid reloadData];
    [self sideOpenAnimation];
}
- (IBAction)touchGunsBtn:(id)sender {
    arrObjects = [visualViewDataSource arrayGuns];
    __block id  selfBlock = self;
    __block id  arrObjBlock = arrObjects;
    __block VisualViewCharacter *viewCharacterBlock = visualViewCharacter;
    __block id  priceLbBlock = self.priceOfItem;
    __block id  bonus = self.resultLabel;

    didFinishBlock = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartGuns *cap = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.gun.image = cap.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"%d", cap.money] ];
            [bonus setText:[NSString stringWithFormat:@"+ %d",cap.action] ];
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        
        [selfBlock refreshController];
    };
    [grid reloadData];
    [self sideOpenAnimation];
}
- (IBAction)touchPantsBtn:(id)sender {
    arrObjects = [visualViewDataSource arrayLegs];
    __block id  selfBlock = self;
    __block id  arrObjBlock = arrObjects;
    __block VisualViewCharacter *viewCharacterBlock = visualViewCharacter;
    __block id  priceLbBlock = self.priceOfItem;
    __block id  bonus = self.resultLabel;

    didFinishBlock = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartLegs *cap = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.length.image = cap.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"%d", cap.money]];
            [bonus setText:[NSString stringWithFormat:@"+ %d",cap.action]];
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        
        [selfBlock refreshController];
    };
    [grid reloadData];
    [self sideOpenAnimation];
}
#pragma mark
- (IBAction)touchBuyBtn:(id)sender {
    
    
}

-(void)refreshController;
{
    
}

@end
