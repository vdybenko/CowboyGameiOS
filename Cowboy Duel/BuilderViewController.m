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

#define spaceForElements 78
#define spaceForCheck 39
@interface BuilderViewController ()
{
    SSServer *playerServer;
    AccountDataSource *playerAccount;
    ProfileViewController *profileViewController;
    BOOL isOpenSide;
    
    __weak IBOutlet VisualViewCharacter *visualViewCharacter;
    __weak IBOutlet UIView *vArrow;
    __weak IBOutlet GMGridView *grid;
    BOOL isAnimate;
    
    NSArray *arrObjects;
}
@property (weak, nonatomic) IBOutlet UIView *sideView;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *defensLabel;
@property (weak, nonatomic) IBOutlet UILabel *attacLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceOfItem;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIView *backlightDefens;
@property (weak, nonatomic) IBOutlet UIView *backlightAtac;

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
    
    //self.backlightDefens.clipsToBounds = YES;
    self.backlightDefens.layer.cornerRadius = 10.f;
    
    //self.backlightAtac.clipsToBounds = YES;
    self.backlightAtac.layer.cornerRadius = 10.f;
    
    visualViewDataSource = [[VisualViewDataSource alloc] init];
    visualViewCharacter.visualViewDataSource = visualViewDataSource;
    [visualViewCharacter refreshWithAccountPlayer:playerAccount];
    arrObjects = [NSArray array];
    
    grid.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    grid.minEdgeInsets = UIEdgeInsetsMake(0,0,0,0);
    grid.itemSpacing = 9;
    
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
    [self setBacklightDefens:nil];
    [self setBacklightAtac:nil];
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
    return CGSizeMake(69, 69);
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
        if (playerAccount.accountLevel < visualViewCharacterPart.levelLock) {
            cell.lockImg.hidden = NO;
        }else
        {
            cell.lockImg.hidden = YES;
        }
    }else{
        [cell setHidden:YES];
    }
    return cell;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    int countOfElements = abs(scrollView.contentOffset.y/80);
    
    float questionOffset = spaceForElements * countOfElements;
    
    int countObjects = [self numberOfItemsInGMGridView:grid];

    if ((questionOffset+spaceForCheck<=abs(scrollView.contentOffset.y))&&(countOfElements!=countObjects-5)) {
        countOfElements = countOfElements+1;
        questionOffset = spaceForElements * countOfElements;
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
        
        float questionOffset = spaceForElements * countOfElements;
        if (questionOffset+spaceForCheck<=abs(scrollView.contentOffset.y)) {
            countOfElements = countOfElements+1;
            questionOffset = spaceForElements * countOfElements;
        }
        
        [scrollView setContentOffset:CGPointMake(0,questionOffset) animated:YES];
        [grid setUserInteractionEnabled:NO];
        
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

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
{
    [grid setUserInteractionEnabled:YES];
}

#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position;
{
    int lastIndex = [self numberOfItemsInGMGridView:gridView]-1;
    int penultIndex = [self numberOfItemsInGMGridView:gridView]-2;
    if (position!=0 && position!=1 && position!=lastIndex && position!=penultIndex && position!=curentObject+2) {
        
        float questionOffset = spaceForElements * (position-2);
        [grid setUserInteractionEnabled:NO];
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
-(void)backlightDefensAction
{
    [UIView animateWithDuration:0.3 animations:^{
        self.backlightDefens.alpha = 0.15;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6 animations:^{
            self.backlightDefens.alpha = 0.3;
        }completion:^(BOOL finished) {
            if (!self.backlightDefens.hidden) {
                [self backlightDefensAction];
            }
            
        }];
    }];
    
}
-(void)backlightAtacAction
{
    [UIView animateWithDuration:0.3 animations:^{
        self.backlightAtac.alpha = 0.05;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.8 animations:^{
            self.backlightAtac.alpha = 0.3;
        }completion:^(BOOL finished) {
            
            if (!self.backlightAtac.hidden) {
                [self backlightAtacAction];
            }
        }];
    }];
}

-(void)sideOpenAnimation{
    if (!isOpenSide && self.sideView.frame.origin.x == 320) {
        [UIView animateWithDuration:0.6 animations:^{
            CGRect frame = self.sideView.frame;
            frame.origin.x -= 100;
            self.sideView.frame = frame;
            
        }completion:^(BOOL finished) {
             isOpenSide = YES;
        }];
        
    }
    
}
-(void)sideCloseAnimation{
        if (isOpenSide && self.sideView.frame.origin.x == 220) {
        self.backlightDefens.hidden = YES;
        self.backlightAtac.hidden = YES;

        [UIView animateWithDuration:0.6 animations:^{
            CGRect frame = self.sideView.frame;
            frame.origin.x += 100;
            self.sideView.frame = frame;
            
        }completion:^(BOOL finished) {
            isOpenSide = NO;
        }];
    }
}

-(void)setObjectsForIndex:(NSInteger)index;
{
    float questionOffset = spaceForElements * index;
    [grid setContentOffset:CGPointMake(0,questionOffset) animated:YES];
    [grid setUserInteractionEnabled:YES];
    if (curentObject !=  index){
        CharacterPartGridCell * cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
        [cell simpleBackGround];
        
        curentObject = index;
        
        cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
        [cell selectedBackGround];
        
        if (didFinishBlock) {
            didFinishBlock(curentObject);
        }
    }
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
    self.defensLabel.text = [NSString stringWithFormat:@"%d",playerAccount.accountDefenseValue];
    self.attacLabel.text = [NSString stringWithFormat:@"%d",playerServer.weapon + [DuelRewardLogicController countUpBuletsWithPlayerLevel:[playerServer.rank intValue]]];


   
    
}

- (IBAction)touchHatBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
    }
    
     __block AccountDataSource *playerAccountBlock = playerAccount;
    arrObjects = [visualViewDataSource arrayHead];
    __block id  selfBlock = self;
    __block id  arrObjBlock = arrObjects;
    __block VisualViewCharacter *viewCharacterBlock = visualViewCharacter;
    __block id  priceLbBlock = self.priceOfItem;
    __block id  bonus = self.resultLabel;
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
        
        CDVisualViewCharacterPartHead *cap = [arrObjBlock objectAtIndex:curentIndex];
       
           CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trDescription = @"BuyNewCap";
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:cap.money];
            transaction.trLocalID = [NSNumber numberWithInt:playerAccountBlock.glNumber];
            transaction.trOpponentID = @"";
            transaction.trGlobalID = [NSNumber numberWithInt:-1];
            
            [playerAccountBlock.transactions addObject:transaction];
            [playerAccountBlock saveTransaction];
            [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
            
            playerAccountBlock.money -= cap.money;
            [playerAccountBlock saveMoney];
            
            playerAccountBlock.visualViewCap = curentIndex;
            [playerAccountBlock saveVisualView];
            [selfBlock refreshController];
    };

    [grid reloadData];
    [grid setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewCap];
}
- (IBAction)touchFaceBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
        self.backlightDefens.hidden = NO;
        [self backlightDefensAction];
    }
    
    __block AccountDataSource *playerAccountBlock = playerAccount;
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
            [selfBlock tempDefens:cap.action];
        });
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartHead *cap = [arrObjBlock objectAtIndex:curentIndex];
        CDTransaction *transaction = [[CDTransaction alloc] init];
        transaction.trDescription = @"BuyNewFace";
        transaction.trType = [NSNumber numberWithInt:-1];
        transaction.trMoneyCh = [NSNumber numberWithInt:cap.money];
        transaction.trLocalID = [NSNumber numberWithInt:playerAccountBlock.glNumber];
        transaction.trOpponentID = @"";
        transaction.trGlobalID = [NSNumber numberWithInt:-1];
        
        [playerAccountBlock.transactions addObject:transaction];
        [playerAccountBlock saveTransaction];
        [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
        
        playerAccountBlock.money -= cap.money;
        [playerAccountBlock saveMoney];
        
        playerAccountBlock.visualViewHead = curentIndex;
        [playerAccountBlock saveVisualView];
        [selfBlock refreshController];
    };


    [grid reloadData];
    [grid setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewHead];
}
- (IBAction)touchShirtBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
        self.backlightDefens.hidden = NO;
        [self backlightDefensAction];
    }
    __block AccountDataSource *playerAccountBlock = playerAccount;
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
            [selfBlock tempDefens:cap.action];
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
    
        CDVisualViewCharacterPartBody *cap = [arrObjBlock objectAtIndex:curentIndex];
        CDTransaction *transaction = [[CDTransaction alloc] init];
        transaction.trDescription = @"BuyNewShirt";
        transaction.trType = [NSNumber numberWithInt:-1];
        transaction.trMoneyCh = [NSNumber numberWithInt:cap.money];
        transaction.trLocalID = [NSNumber numberWithInt:playerAccountBlock.glNumber];
        transaction.trOpponentID = @"";
        transaction.trGlobalID = [NSNumber numberWithInt:-1];
        
        [playerAccountBlock.transactions addObject:transaction];
        [playerAccountBlock saveTransaction];
        [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
        
        playerAccountBlock.money -= cap.money;
        [playerAccountBlock saveMoney];
        
        playerAccountBlock.visualViewBody = curentIndex;
        [playerAccountBlock saveVisualView];
        
        [selfBlock refreshController];
    };
    [grid reloadData];
    [grid setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewBody];
}
- (IBAction)touchJaketBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
        self.backlightDefens.hidden = NO;
        [self backlightDefensAction];
    }
    __block AccountDataSource *playerAccountBlock = playerAccount;
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
            [selfBlock tempDefens:cap.action];
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartJakets *cap = [arrObjBlock objectAtIndex:curentIndex];
        CDTransaction *transaction = [[CDTransaction alloc] init];
        transaction.trDescription = @"BuyNewJacket";
        transaction.trType = [NSNumber numberWithInt:-1];
        transaction.trMoneyCh = [NSNumber numberWithInt:cap.money];
        transaction.trLocalID = [NSNumber numberWithInt:playerAccountBlock.glNumber];
        transaction.trOpponentID = @"";
        transaction.trGlobalID = [NSNumber numberWithInt:-1];
        
        [playerAccountBlock.transactions addObject:transaction];
        [playerAccountBlock saveTransaction];
        [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
        
        playerAccountBlock.money -= cap.money;
        [playerAccountBlock saveMoney];
        
        playerAccountBlock.visualViewJackets = curentIndex;
        [playerAccountBlock saveVisualView];
        
        [selfBlock refreshController];
    };
    [grid reloadData];
    [grid setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewJackets];
}
- (IBAction)touchShoesBtn:(id)sender {
    if (!isOpenSide && self.backlightAtac.hidden) {
        [self sideOpenAnimation];
        self.backlightAtac.hidden = NO;
        [self backlightAtacAction];
    }
    __block AccountDataSource *playerAccountBlock = playerAccount;
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
            [selfBlock tempAtac:cap.action];
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartGuns *cap = [arrObjBlock objectAtIndex:curentIndex];
        CDTransaction *transaction = [[CDTransaction alloc] init];
        transaction.trDescription = @"BuyNewShoes";
        transaction.trType = [NSNumber numberWithInt:-1];
        transaction.trMoneyCh = [NSNumber numberWithInt:cap.money];
        transaction.trLocalID = [NSNumber numberWithInt:playerAccountBlock.glNumber];
        transaction.trOpponentID = @"";
        transaction.trGlobalID = [NSNumber numberWithInt:-1];
        
        [playerAccountBlock.transactions addObject:transaction];
        [playerAccountBlock saveTransaction];
        [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
        
        playerAccountBlock.money -= cap.money;
        [playerAccountBlock saveMoney];
        
        playerAccountBlock.visualViewShoose = curentIndex;
        [playerAccountBlock saveVisualView];
        
        [selfBlock refreshController];

    };
    [grid reloadData];
    [grid setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewShoose];
}
- (IBAction)touchGunsBtn:(id)sender {
    if (!isOpenSide && self.backlightAtac.hidden) {
        [self sideOpenAnimation];
        self.backlightAtac.hidden = NO;
        [self backlightAtacAction];
    }
    __block AccountDataSource *playerAccountBlock = playerAccount;
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
            [selfBlock tempAtac:cap.action];
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartGuns *cap = [arrObjBlock objectAtIndex:curentIndex];
        CDTransaction *transaction = [[CDTransaction alloc] init];
        transaction.trDescription = @"BuyNewGun";
        transaction.trType = [NSNumber numberWithInt:-1];
        transaction.trMoneyCh = [NSNumber numberWithInt:cap.money];
        transaction.trLocalID = [NSNumber numberWithInt:playerAccountBlock.glNumber];
        transaction.trOpponentID = @"";
        transaction.trGlobalID = [NSNumber numberWithInt:-1];
        
        [playerAccountBlock.transactions addObject:transaction];
        [playerAccountBlock saveTransaction];
        [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
        
        playerAccountBlock.money -= cap.money;
        [playerAccountBlock saveMoney];
        
        playerAccountBlock.visualViewGuns = curentIndex;
        [playerAccountBlock saveVisualView];
        
        [selfBlock refreshController];

    };
    [grid reloadData];
    [grid setUserInteractionEnabled:YES];
    [self sideOpenAnimation];
    [self setObjectsForIndex:playerAccount.visualViewGuns];
}
- (IBAction)touchPantsBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
        self.backlightDefens.hidden = NO;
        [self backlightDefensAction];
    }
    __block AccountDataSource *playerAccountBlock = playerAccount;
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
            [selfBlock tempDefens:cap.action];
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartLegs *cap = [arrObjBlock objectAtIndex:curentIndex];
        CDTransaction *transaction = [[CDTransaction alloc] init];
        transaction.trDescription = @"BuyNewPants";
        transaction.trType = [NSNumber numberWithInt:-1];
        transaction.trMoneyCh = [NSNumber numberWithInt:cap.money];
        transaction.trLocalID = [NSNumber numberWithInt:playerAccountBlock.glNumber];
        transaction.trOpponentID = @"";
        transaction.trGlobalID = [NSNumber numberWithInt:-1];
        
        [playerAccountBlock.transactions addObject:transaction];
        [playerAccountBlock saveTransaction];
        [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
        
        playerAccountBlock.money -= cap.money;
        [playerAccountBlock saveMoney];
        
        playerAccountBlock.visualViewLegs = curentIndex;
        [playerAccountBlock saveVisualView];
        
        [selfBlock refreshController];

    };
    [grid reloadData];
    [grid setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewLegs];
}
#pragma mark
- (IBAction)touchBuyBtn:(id)sender{
    if (didBuyAction) {
        didBuyAction(curentObject);
    }
    
}

-(void)refreshController;
{
    
}
-(void)tempDefens:(int)plusOnDefens
{
     self.defensLabel.text = [NSString stringWithFormat:@"%d",playerAccount.accountDefenseValue + plusOnDefens];
}
-(void)tempAtac:(int)plusOnAtac
{
     self.attacLabel.text = [NSString stringWithFormat:@"%d",playerServer.weapon + [DuelRewardLogicController countUpBuletsWithPlayerLevel:[playerServer.rank intValue]] + plusOnAtac];
}


@end
