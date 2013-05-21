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
#import "Utils.h"
#import "UIButton+Image+Title.h"


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
    __weak IBOutlet UIButton *btnBuyMain;
    __weak IBOutlet UILabel *lbBuyBtn;
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
@property (weak, nonatomic) IBOutlet UIButton *hatsBtn;
@property (weak, nonatomic) IBOutlet UIButton *faceBtn;
@property (weak, nonatomic) IBOutlet UIButton *ShirtBtn;
@property (weak, nonatomic) IBOutlet UIButton *jaketsBtn;
@property (weak, nonatomic) IBOutlet UIButton *shoesBtn;
@property (weak, nonatomic) IBOutlet UIButton *gunsBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *PantsBtn;
@property (weak, nonatomic) IBOutlet UIButton *suitsBtn;

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

    playerAccount = [AccountDataSource sharedInstance];
//    To do delete
    playerAccount.money = 550;
    
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    [self.hatsBtn setTitleByLabel:@"Heats" withColor:buttonsTitleColor fontSize:24];
    [self.faceBtn setTitleByLabel:@"Faces" withColor:buttonsTitleColor fontSize:24];
    [self.ShirtBtn setTitleByLabel:@"Shirts" withColor:buttonsTitleColor fontSize:24];
    [self.jaketsBtn setTitleByLabel:@"Jakets" withColor:buttonsTitleColor fontSize:24];
    [self.PantsBtn setTitleByLabel:@"Pants" withColor:buttonsTitleColor fontSize:24];
    [self.shoesBtn setTitleByLabel:@"Shoes" withColor:buttonsTitleColor fontSize:24];
    [self.gunsBtn setTitleByLabel:@"Guns" withColor:buttonsTitleColor fontSize:24];
    [self.suitsBtn setTitleByLabel:@"Suit" withColor:buttonsTitleColor fontSize:24];
    [self.closeBtn setTitleByLabel:@"Close" withColor:buttonsTitleColor fontSize:24];
    
    lbBuyBtn.text = NSLocalizedString(@"BUYIT", @"");
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
    
    grid.dataSource = self;
    grid.actionDelegate = self;
    grid.delegate = self;
    
    if (IS_IPHONE_5) {
        CGRect frame = grid.frame;
        frame.size.height +=75;
        grid.frame = frame;
    }
    [self refreshController];
}

-(void)refreshController;
{
    self.moneyLabel.text =  [NSString stringWithFormat:@"%d",playerAccount.money];
    self.defensLabel.text = [NSString stringWithFormat:@"%d",playerAccount.accountDefenseValue + [DuelRewardLogicController countUpBuletsWithPlayerLevel:playerAccount.accountLevel]];
    self.attacLabel.text = [NSString stringWithFormat:@"%d",playerAccount.accountWeapon.dDamage + [DuelRewardLogicController countUpBuletsWithPlayerLevel:playerAccount.accountLevel]];
}

-(void)refreshControllerWithGrid;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshController];
        [grid reloadData];
    });
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
    [self setHatsBtn:nil];
    [self setFaceBtn:nil];
    [self setShirtBtn:nil];
    [self setJaketsBtn:nil];
    [self setShoesBtn:nil];
    [self setGunsBtn:nil];
    [self setCloseBtn:nil];
    [self setPantsBtn:nil];
    [self setSuitsBtn:nil];
    btnBuyMain = nil;
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

-(NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    if (IS_IPHONE_5) {
        return [arrObjects count]+5;
    }else{
        return [arrObjects count]+4;
    }
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
        cell = [CharacterPartGridCell cell];
    }
    
    BOOL result = [self isCellValid:index];
    if (result) {
        [cell setHidden:NO];
        [cell simpleBackGround];
        CDVisualViewCharacterPart *visualViewCharacterPart = [arrObjects objectAtIndex:index-2];
        
        if ([visualViewCharacterPart.nameForImage isEqualToString:@"clearePicture.png"]) {
            cell.ivImage.image = [UIImage imageNamed:@"сloseCross.png"];
        }else{
            cell.ivImage.image = [visualViewCharacterPart imageForObject];
        }
        
        if (playerAccount.accountLevel < visualViewCharacterPart.levelLock) {
            cell.lockImg.hidden = NO;
        }else{
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
    BOOL result = [self isCellValid:position];
    if (result && position!=curentObject+2) {
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
    
    CharacterPartGridCell * cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
    [cell simpleBackGround];
    
    curentObject = index;
    
    cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
    [cell selectedBackGround];
    
    if (didFinishBlock) {
        didFinishBlock(curentObject);
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
    [self cleanAll];
    [self sideCloseAnimation];
    
    [self refreshController];
}

- (IBAction)touchBuyBtn:(id)sender{
    if (didBuyAction) {
        didBuyAction(curentObject);
    }
}

- (IBAction)touchFaceBtn:(id)sender {
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
    
    //Сhoice
    didFinishBlock = ^(NSInteger curentIndex){
      CDVisualViewCharacterPartHead *head = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.head.image = head.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"$%d", head.money]];
            [bonus setText:[NSString stringWithFormat:@"0"]];
            BOOL isBtnForBuy = [selfBlock checkBtnBuy:head];
            if (!isBtnForBuy) {
                if (playerAccountBlock.visualViewHead==curentIndex) {
                    btnBuyMain.enabled = NO;
                }
            }
        });
    
        [selfBlock refreshController];
    };
    //Purchase
    didBuyAction = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartHead *head = [arrObjBlock objectAtIndex:curentIndex];
       
        BOOL partBought = [playerAccountBlock isProductBought:head.dId];
        if (partBought){
            playerAccountBlock.visualViewHead = curentIndex;
            [playerAccountBlock saveVisualView];
        }else{
           CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trDescription = @"BuyNewCap";
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:-head.money];
            transaction.trLocalID = [NSNumber numberWithInt:[playerAccountBlock increaseGlNumber]];
            transaction.trOpponentID = @"";
            transaction.trGlobalID = [NSNumber numberWithInt:-1];
            
            [playerAccountBlock.transactions addObject:transaction];
            [playerAccountBlock saveTransaction];
            [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
            
            playerAccountBlock.money -= head.money;
            [playerAccountBlock saveMoney];
            
            playerAccountBlock.visualViewHead = curentIndex;
            [selfBlock addProductToBought:head.dId];
        }
        
        [selfBlock refreshControllerWithGrid];
    };

    [grid reloadData];
    [grid setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewCap];
}
- (IBAction)touchHatBtn:(id)sender {
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
            [priceLbBlock setText:[NSString stringWithFormat:@"$%d", cap.money]];
            [bonus setText:[NSString stringWithFormat:@"+ %d",cap.action]];
            [selfBlock tempDefens:cap.action];
            BOOL isBtnForBuy = [selfBlock checkBtnBuy:cap];
            if (!isBtnForBuy) {
                if (playerAccountBlock.visualViewCap==curentIndex) {
                    btnBuyMain.enabled = NO;
                }
            }
        });
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartCap *cap = [arrObjBlock objectAtIndex:curentIndex];
        BOOL partBought = [playerAccountBlock isProductBought:cap.dId];
        if (partBought){
            playerAccountBlock.visualViewCap = curentIndex;
            [playerAccountBlock saveVisualView];
        }else{
            CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trDescription = @"BuyNewFace";
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:-cap.money];
            transaction.trLocalID = [NSNumber numberWithInt:[playerAccountBlock increaseGlNumber]];
            transaction.trOpponentID = @"";
            transaction.trGlobalID = [NSNumber numberWithInt:-1];
            
            [playerAccountBlock.transactions addObject:transaction];
            [playerAccountBlock saveTransaction];
            [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
            
            playerAccountBlock.money -= cap.money;
            [playerAccountBlock saveMoney];
            
            playerAccountBlock.visualViewCap = curentIndex;
            [selfBlock addProductToBought:cap.dId];
            
            [selfBlock refreshControllerWithGrid];
            [selfBlock setObjectsForIndex:playerAccountBlock.visualViewHead];
        }
        
        [selfBlock refreshControllerWithGrid];
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

        CDVisualViewCharacterPartBody *shirt = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.shirt.image = shirt.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"$%d", shirt.money]];
            [bonus setText:[NSString stringWithFormat:@"+ %d",shirt.action]];
            [selfBlock tempDefens:shirt.action];
            BOOL isBtnForBuy = [selfBlock checkBtnBuy:shirt];
            if (!isBtnForBuy) {
                if (playerAccountBlock.visualViewBody==curentIndex) {
                    btnBuyMain.enabled = NO;
                }
            }
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
    
        CDVisualViewCharacterPartBody *shirt = [arrObjBlock objectAtIndex:curentIndex];
        BOOL partBought = [playerAccountBlock isProductBought:shirt.dId];
        if (partBought){
            playerAccountBlock.visualViewBody = curentIndex;
            [playerAccountBlock saveVisualView];
        }else{
            CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trDescription = @"BuyNewShirt";
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:shirt.money];
            transaction.trLocalID = [NSNumber numberWithInt:[playerAccountBlock increaseGlNumber]];
            transaction.trOpponentID = @"";
            transaction.trGlobalID = [NSNumber numberWithInt:-1];
            
            [playerAccountBlock.transactions addObject:transaction];
            [playerAccountBlock saveTransaction];
            [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
            
            playerAccountBlock.money -= shirt.money;
            [playerAccountBlock saveMoney];
            
            playerAccountBlock.visualViewBody = curentIndex;
            [selfBlock addProductToBought:shirt.dId];
            
        }
        
        [selfBlock refreshControllerWithGrid];

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
        
        CDVisualViewCharacterPartJakets *jaket = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.jakets.image = jaket.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"$%d", jaket.money]];
            [bonus setText:[NSString stringWithFormat:@"+ %d",jaket.action]];
            [selfBlock tempDefens:jaket.action];
            BOOL isBtnForBuy = [selfBlock checkBtnBuy:jaket];
            if (!isBtnForBuy) {
                if (playerAccountBlock.visualViewJackets==curentIndex) {
                    btnBuyMain.enabled = NO;
                }
            }
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartJakets *jaket = [arrObjBlock objectAtIndex:curentIndex];
        
        BOOL partBought = [playerAccountBlock isProductBought:jaket.dId];
        if (partBought){
            playerAccountBlock.visualViewJackets = curentIndex;
            [playerAccountBlock saveVisualView];
        }else{
            CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trDescription = @"BuyNewJacket";
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:jaket.money];
            transaction.trLocalID = [NSNumber numberWithInt:[playerAccountBlock increaseGlNumber]];
            transaction.trOpponentID = @"";
            transaction.trGlobalID = [NSNumber numberWithInt:-1];
            
            [playerAccountBlock.transactions addObject:transaction];
            [playerAccountBlock saveTransaction];
            [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
            
            playerAccountBlock.money -= jaket.money;
            [playerAccountBlock saveMoney];
            
            playerAccountBlock.visualViewJackets = curentIndex;
            [selfBlock addProductToBought:jaket.dId];
            
        }
        
        [selfBlock refreshControllerWithGrid];

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
        
        CDVisualViewCharacterPartShoose *shoos = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.shoose.image = shoos.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"$%d", shoos.money] ];
            [bonus setText:[NSString stringWithFormat:@"+ %d",shoos.action]];
            [selfBlock tempAtac:shoos.action];
            BOOL isBtnForBuy = [selfBlock checkBtnBuy:shoos];
            if (!isBtnForBuy) {
                if (playerAccountBlock.visualViewShoose==curentIndex) {
                    btnBuyMain.enabled = NO;
                }
            }
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartShoose *shoose= [arrObjBlock objectAtIndex:curentIndex];
        
        BOOL partBought = [playerAccountBlock isProductBought:shoose.dId];
        if (partBought){
            playerAccountBlock.visualViewShoose = curentIndex;
            [playerAccountBlock saveVisualView];
        }else{
            CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trDescription = @"BuyNewShoes";
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:shoose.money];
            transaction.trLocalID = [NSNumber numberWithInt:[playerAccountBlock increaseGlNumber]];
            transaction.trOpponentID = @"";
            transaction.trGlobalID = [NSNumber numberWithInt:-1];
            
            [playerAccountBlock.transactions addObject:transaction];
            [playerAccountBlock saveTransaction];
            [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
            
            playerAccountBlock.money -= shoose.money;
            [playerAccountBlock saveMoney];
            
            playerAccountBlock.visualViewShoose = curentIndex;
            [selfBlock addProductToBought:shoose.dId];
            
        }
        [selfBlock refreshControllerWithGrid];

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
        
        CDVisualViewCharacterPartGuns *gun = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.gun.image = gun.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"$%d", gun.money] ];
            [bonus setText:[NSString stringWithFormat:@"+ %d",gun.action] ];
            [selfBlock tempAtac:gun.action];
            BOOL isBtnForBuy = [selfBlock checkBtnBuy:gun];
            if (!isBtnForBuy) {
                if (playerAccountBlock.visualViewGuns==curentIndex) {
                    btnBuyMain.enabled = NO;
                }
            }
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartGuns *gun = [arrObjBlock objectAtIndex:curentIndex];
        BOOL partBought = [playerAccountBlock isProductBought:gun.dId];
        if (partBought){
            playerAccountBlock.visualViewGuns = curentIndex;
            [playerAccountBlock saveVisualView];
        }else{
            CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trDescription = @"BuyNewGun";
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:gun.money];
            transaction.trLocalID = [NSNumber numberWithInt:[playerAccountBlock increaseGlNumber]];
            transaction.trOpponentID = @"";
            transaction.trGlobalID = [NSNumber numberWithInt:-1];
            
            [playerAccountBlock.transactions addObject:transaction];
            [playerAccountBlock saveTransaction];
            [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
            
            playerAccountBlock.money -= gun.money;
            [playerAccountBlock saveMoney];
            
            playerAccountBlock.visualViewGuns = curentIndex;
            [selfBlock addProductToBought:gun.dId];
            
        }
        [selfBlock refreshControllerWithGrid];

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
        
        CDVisualViewCharacterPartLegs *legs = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.length.image = legs.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"$%d", legs.money]];
            [bonus setText:[NSString stringWithFormat:@"+ %d",legs.action]];
            [selfBlock tempDefens:legs.action];
            BOOL isBtnForBuy = [selfBlock checkBtnBuy:legs];
            if (!isBtnForBuy) {
                if (playerAccountBlock.visualViewLegs==curentIndex) {
                    btnBuyMain.enabled = NO;
                }
            }
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartLegs *legs = [arrObjBlock objectAtIndex:curentIndex];
        BOOL partBought = [playerAccountBlock isProductBought:legs.dId];
        if (partBought){
            playerAccountBlock.visualViewLegs = curentIndex;
            [playerAccountBlock saveVisualView];
        }else{
            CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trDescription = @"BuyNewPants";
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:legs.money];
            transaction.trLocalID = [NSNumber numberWithInt:[playerAccountBlock increaseGlNumber]];
            transaction.trOpponentID = @"";
            transaction.trGlobalID = [NSNumber numberWithInt:-1];
            
            [playerAccountBlock.transactions addObject:transaction];
            [playerAccountBlock saveTransaction];
            [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
            
            playerAccountBlock.money -= legs.money;
            [playerAccountBlock saveMoney];
            
            playerAccountBlock.visualViewLegs = curentIndex;
            [selfBlock addProductToBought:legs.dId];
            
        }
        [selfBlock refreshControllerWithGrid];

    };
    [grid reloadData];
    [grid setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewLegs];
}
- (IBAction)touchSuitsBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
        self.backlightDefens.hidden = NO;
        [self backlightDefensAction];
        [self cleanForSuits];
    }
    __block AccountDataSource *playerAccountBlock = playerAccount;
    arrObjects = [visualViewDataSource arraySuits];
    __block id  selfBlock = self;
    __block id  arrObjBlock = arrObjects;
    __block VisualViewCharacter *viewCharacterBlock = visualViewCharacter;
    __block id  priceLbBlock = self.priceOfItem;
    __block id  bonus = self.resultLabel;
    
    didFinishBlock = ^(NSInteger curentIndex){
        
        CDVisualViewCharacterPartSuits *suit = [arrObjBlock objectAtIndex:curentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            viewCharacterBlock.suits.image = suit.imageForObject;
            [priceLbBlock setText:[NSString stringWithFormat:@"$%d", suit.money]];
            [bonus setText:[NSString stringWithFormat:@"+ %d",suit.action]];
            [selfBlock tempDefens:suit.action];
            BOOL isBtnForBuy = [selfBlock checkBtnBuy:suit];
            if (!isBtnForBuy) {
                if (playerAccountBlock.visualViewSuits==curentIndex) {
                    btnBuyMain.enabled = NO;
                }
            }
        });
        [selfBlock refreshController];
    };
    didBuyAction = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartSuits *suit = [arrObjBlock objectAtIndex:curentIndex];
        
        BOOL partBought = [playerAccountBlock isProductBought:suit.dId];
        if (partBought){
            playerAccountBlock.visualViewSuits = curentIndex;
            [playerAccountBlock saveVisualView];
        }else{
            CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trDescription = @"BuyNewSuits";
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:suit.money];
            transaction.trLocalID = [NSNumber numberWithInt:[playerAccountBlock increaseGlNumber]];
            transaction.trOpponentID = @"";
            transaction.trGlobalID = [NSNumber numberWithInt:-1];
            
            [playerAccountBlock.transactions addObject:transaction];
            [playerAccountBlock saveTransaction];
            [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
            
            playerAccountBlock.money -= suit.money;
            [playerAccountBlock saveMoney];
            
            playerAccountBlock.visualViewSuits = curentIndex;
            [selfBlock addProductToBought:suit.dId];
        }
        
        [selfBlock refreshControllerWithGrid];

    };
    [grid reloadData];
    [grid setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewSuits];
}

#pragma mark

-(void)tempDefens:(int)plusOnDefens
{
     self.defensLabel.text = [NSString stringWithFormat:@"%d",playerAccount.accountDefenseValue + plusOnDefens];
}
-(void)tempAtac:(int)plusOnAtac
{
     self.attacLabel.text = [NSString stringWithFormat:@"%d",playerServer.weapon + [DuelRewardLogicController countUpBuletsWithPlayerLevel:[playerServer.rank intValue]] + plusOnAtac];
}

-(BOOL) isCellValid:(NSInteger)position
{
    int lastIndex = [self numberOfItemsInGMGridView:grid]-1;
    int penultIndex = lastIndex-1;
    
    if (IS_IPHONE_5){
        int penultPenultIndex = lastIndex-2;
        if (position!=0 && position!=1 && position!=lastIndex && position!=penultIndex && position!=penultPenultIndex){
            return YES;
        }else{
            return NO;
        }
    }else{
        if (position!=0 && position!=1 && position!=lastIndex && position!=penultIndex){
            return YES;
        }else{
            return NO;
        }
    }
}

-(BOOL) checkBtnBuy:(CDVisualViewCharacterPart*)part
{
    BOOL partBought = [playerAccount isProductBought:part.dId];
        if (partBought || (part.money==0)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                lbBuyBtn.text = NSLocalizedString(@"USE", @"");

                btnBuyMain.enabled = YES;
            });
            return NO;
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                lbBuyBtn.text = NSLocalizedString(@"BUYIT", @"");

                if (part.money>playerAccount.money) {
                    btnBuyMain.enabled = NO;
                }else{
                    btnBuyMain.enabled = YES;
                }
            });
            return YES;
        }
}

-(void)addProductToBought:(NSInteger)index{
    NSNumber *num = [NSNumber numberWithInteger:index];
    [playerAccount.arrayOfBoughtProducts addObject:num];
    [playerAccount saveVisualView];
}

-(void)cleanForSuits
{

    CDVisualViewCharacterPartCap *visualViewCharacterPartCap = [[visualViewDataSource arrayCap] objectAtIndex:0];
    visualViewCharacter.cap.image = [visualViewCharacterPartCap imageForObject];
    visualViewCharacterPartCap = nil;
    
    CDVisualViewCharacterPartBody *visualViewCharacterPartBody = [[visualViewDataSource arrayBody] objectAtIndex:0];
     visualViewCharacter.shirt.image = [visualViewCharacterPartBody imageForObject];
    visualViewCharacterPartBody = nil;
    
    CDVisualViewCharacterPartJakets *visualViewCharacterPartJakets = [[visualViewDataSource arrayJakets] objectAtIndex:0];
     visualViewCharacter.jakets.image = [visualViewCharacterPartJakets imageForObject];
    visualViewCharacterPartJakets = nil;
    
    CDVisualViewCharacterPartShoose *visualViewCharacterPartShoose = [[visualViewDataSource arrayShoose] objectAtIndex:0];
     visualViewCharacter.shoose.image = [visualViewCharacterPartShoose imageForObject];
    visualViewCharacterPartShoose = nil;
    
    CDVisualViewCharacterPartLegs *visualViewCharacterPartLegs = [[visualViewDataSource arrayLegs] objectAtIndex:0];
     visualViewCharacter.length.image = [visualViewCharacterPartLegs imageForObject];
    visualViewCharacterPartLegs = nil;
    
    CDVisualViewCharacterPartSuits *visualViewCharacterPartSuits = [[visualViewDataSource arraySuits] objectAtIndex:0];
     visualViewCharacter.suits.image = [visualViewCharacterPartSuits imageForObject];
    visualViewCharacterPartSuits = nil;


}

-(void)cleanAll
{
    [visualViewCharacter refreshWithAccountPlayer:playerAccount];
}
@end
