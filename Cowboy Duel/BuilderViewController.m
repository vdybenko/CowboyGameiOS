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
#import "VisualViewCharacter.h"
#import "CharacterPartGridCell.h"
#import "CDTransaction.h"
#import "Utils.h"
#import "UIButton+Image+Title.h"
#import "ProfileViewController.h"

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
    __weak IBOutlet UIButton *btnMyProfile;
    __weak IBOutlet UILabel *lbBuyBtn;
    __weak IBOutlet UIScrollView *buttonsScroll;
    __weak IBOutlet UIView *buttonsView;
    __weak IBOutlet UIView *moneyView;
    __weak IBOutlet UIView *animLostMoneyView;
    __weak IBOutlet UILabel *animLostMomeyLB;
   
    BOOL isAnimate;
    
    NSArray *arrObjects;
    
    CharacterPart typeOfCharacterPart;
    DuelProductDownloaderController *duelProductDownloaderController;
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
@synthesize curentObject;
@synthesize sideView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isOpenSide = NO;
        curentObject = 0;
        
        duelProductDownloaderController = [[DuelProductDownloaderController alloc] init];
        duelProductDownloaderController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    playerAccount = [AccountDataSource sharedInstance];
    
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    [self.closeBtn setTitleByLabel:@"Close" withColor:buttonsTitleColor fontSize:24];

    buttonsScroll.contentSize = CGSizeMake(self.suitsBtn.frame.size.width,  (self.suitsBtn.frame.size.height + 4) * 9);
    
    lbBuyBtn.text = NSLocalizedString(@"BUYIT", @"");
    self.backlightDefens.layer.cornerRadius = 10.f;
    
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

-(void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/BuilderVC" forKey:@"page"]];

}

-(void)refreshController;
{
    self.moneyLabel.text =  [NSString stringWithFormat:@"%d",playerAccount.money];
    self.defensLabel.text = [NSString stringWithFormat:@"%d",playerAccount.accountDefenseValue + [DuelRewardLogicController countUpBuletsWithPlayerLevel:playerAccount.accountLevel]];
    self.attacLabel.text = [NSString stringWithFormat:@"%d",playerAccount.accountAtackValue + [DuelRewardLogicController countUpBuletsWithPlayerLevel:playerAccount.accountLevel]];
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
    buttonsScroll = nil;
    buttonsView = nil;
    moneyView = nil;
    animLostMoneyView = nil;
    animLostMomeyLB = nil;
    btnMyProfile = nil;
    [super viewDidUnload];
}
-(void)releaseComponents
{
    [visualViewDataSource releaseComponents];
    visualViewDataSource = nil;
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
    
        if (typeOfCharacterPart == CharacterPartGun) {
            [cell rotateImage:YES];
        }else{
            [cell rotateImage:NO];
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
        
        [self grid:grid selectIndex:curentObject forType:typeOfCharacterPart];
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
        [sideView setUserInteractionEnabled:NO];
        
        if (curentObject !=  countOfElements){
            CharacterPartGridCell * cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
            [cell simpleBackGround];
            
            curentObject = countOfElements;
            
            cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
            [cell selectedBackGround];
            
            [self grid:grid selectIndex:curentObject forType:typeOfCharacterPart];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
{
    [sideView setUserInteractionEnabled:YES];
}

#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position;
{
    BOOL result = [self isCellValid:position];
    if (result && position!=curentObject+2) {
        float questionOffset = spaceForElements * (position-2);
        [sideView setUserInteractionEnabled:NO];
        [grid setContentOffset:CGPointMake(0,questionOffset) animated:YES];
        
        CharacterPartGridCell * cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
        [cell simpleBackGround];
        
        curentObject = position-2;
        
        cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
        [cell selectedBackGround];
        
        [self grid:gridView selectIndex:curentObject forType:typeOfCharacterPart];
    }
}

#pragma mark Animation
-(void)lostMoneyAnimation:(int)coast{
    if (animLostMoneyView.hidden) {
    animLostMoneyView.hidden = NO;
    CGRect frame1 = animLostMoneyView.frame;
    frame1.origin.y += 100;
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    animLostMomeyLB.textColor = buttonsTitleColor;
    animLostMomeyLB.text =  [NSString stringWithFormat:@"-%d",coast];
    [UIView animateWithDuration:1 animations:^{
        animLostMoneyView.frame = frame1;
        animLostMoneyView.alpha = 0;
    }completion:^(BOOL finished) {
        animLostMoneyView.alpha = 1;
        animLostMoneyView.hidden = YES;
        CGRect frame1 = animLostMoneyView.frame;
        frame1.origin.y -=100;
        animLostMoneyView.frame = frame1;
        
    }];
    }
}
-(void)backlightDefensAction
{
    [UIView animateWithDuration:0.5 animations:^{
        self.backlightDefens.alpha = 0.15;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.backlightDefens.alpha = 0.8;
        }completion:^(BOOL finished) {
            if (!self.backlightDefens.hidden) {
                [self backlightDefensAction];
            }
            
        }];
    }];
    
}
-(void)backlightAtacAction
{
    [UIView animateWithDuration:0.5 animations:^{
        self.backlightAtac.alpha = 0.05;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.backlightAtac.alpha = 0.8;
        }completion:^(BOOL finished) {
            if (!self.backlightAtac.hidden) {
                [self backlightAtacAction];
            }
        }];
    }];
}

-(void)sideOpenAnimation{
    if (!isOpenSide && self.sideView.frame.origin.x == 321) {
        [UIView animateWithDuration:0.4 animations:^{
            CGRect frame = self.sideView.frame;
            frame.origin.x += 100;
            buttonsView.frame = frame;
            
        }completion:^(BOOL finished) {
            isOpenSide = YES;
            [UIView animateWithDuration:0.4 animations:^{
                CGRect frame = self.sideView.frame;
                frame.origin.x -= 100;
                self.sideView.frame = frame;
                
            }completion:^(BOOL finished) {
                isOpenSide = YES;
            }];

        }];
        
    }
    
}
-(void)sideCloseAnimation{
        if (isOpenSide && self.sideView.frame.origin.x == 221) {
        self.backlightDefens.hidden = YES;
        self.backlightAtac.hidden = YES;

        [UIView animateWithDuration:0.4 animations:^{
            CGRect frame = self.sideView.frame;
            frame.origin.x += 100;
            self.sideView.frame = frame;
            
        }completion:^(BOOL finished) {
            isOpenSide = NO;
            [UIView animateWithDuration:0.4 animations:^{
                CGRect frame = self.sideView.frame;
                frame.origin.x -= 100;
                buttonsView.frame = frame;
                
            }completion:^(BOOL finished) {

            }];

        }];
    }
}

-(void)setObjectsForIndex:(NSInteger)index;
{
    float questionOffset = spaceForElements * index;
    [grid setContentOffset:CGPointMake(0,questionOffset) animated:YES];
    [sideView setUserInteractionEnabled:YES];
    
    CharacterPartGridCell * cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
    [cell simpleBackGround];
    
    curentObject = index;
    
    cell = (CharacterPartGridCell*)[grid cellForItemAtIndex:curentObject+2];
    [cell selectedBackGround];
    
    [self grid:grid selectIndex:curentObject forType:typeOfCharacterPart];
}
#pragma mark BuilderViewControllerDelegate

-(void) grid:(GMGridView*)pGrid selectIndex:(NSInteger)index forType:(CharacterPart)type;
{
    CDVisualViewCharacterPartSuits *part = [arrObjects objectAtIndex:index];
    
    [self.priceOfItem setText:[NSString stringWithFormat:@"%d", part.money]];
    BOOL isBtnForBuy = [self checkBtnBuy:part];
    
    CharacterPartGridCell *cell = (CharacterPartGridCell*)[pGrid cellForItemAtIndex:curentObject+2];
    if (![cell.lockImg isHidden]) {
        btnBuyMain.alpha = 0.4;
        btnBuyMain.enabled = YES;
    }
    
    switch (type) {
        case CharacterPartCap:
            visualViewCharacter.cap.image = part.imageForObject;
            [self.resultLabel setText:[NSString stringWithFormat:@"+ %d",part.action]];
            if (!isBtnForBuy) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"VV_CAP_VALUE"]==index) {
                    btnBuyMain.alpha = 0.4;
                    btnBuyMain.enabled = NO;
                }
            }
            playerAccount.visualViewCap = index;
            break;
        case CharacterPartFace:
            visualViewCharacter.head.image = part.imageForObject;
            [self.resultLabel setText:[NSString stringWithFormat:@"+ %d",part.action]];
            if (!isBtnForBuy) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"VV_HEAD_VALUE"]==index) {
                    btnBuyMain.alpha = 0.4;
                    btnBuyMain.enabled = NO;
                }
            }
            playerAccount.visualViewHead = index;
            break;
        case CharacterPartGun:
            
            visualViewCharacter.gun.image = part.imageForObject;
            [self.resultLabel setText:[NSString stringWithFormat:@"+ %d",part.action]];
            if (!isBtnForBuy) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"VV_GUN_VALUE"]==index) {
                    btnBuyMain.alpha = 0.4;
                    btnBuyMain.enabled = NO;
                }
            }
            
            playerAccount.visualViewGuns = index;

            break;
        case CharacterPartJaket:
            visualViewCharacter.jakets.image = part.imageForObject;
            [self.resultLabel setText:[NSString stringWithFormat:@"+ %d",part.action]];
            if (!isBtnForBuy) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"VV_SHIRTS_VALUE"]==index) {
                    btnBuyMain.alpha = 0.4;
                    btnBuyMain.enabled = NO;
                }
            }
            playerAccount.visualViewJackets = index;

            break;
        case CharacterPartLegs:
            visualViewCharacter.length.image = part.imageForObject;
            [self.resultLabel setText:[NSString stringWithFormat:@"+ %d",part.action]];
            if (!isBtnForBuy) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"VV_LEGS_VALUE"]==index) {
                    btnBuyMain.alpha = 0.4;
                    btnBuyMain.enabled = NO;
                }
            }
            playerAccount.visualViewLegs = index;

            break;
        case CharacterPartShirt:
            visualViewCharacter.shirt.image = part.imageForObject;
            [self.resultLabel setText:[NSString stringWithFormat:@"+ %d",part.action]];
            if (!isBtnForBuy) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"VV_BODY_VALUE"]==index) {
                    btnBuyMain.alpha = 0.4;
                    btnBuyMain.enabled = NO;
                }
            }
            playerAccount.visualViewBody = index;

            break;
        case CharacterPartShoose:
            visualViewCharacter.shoose.image = part.imageForObject;
            [self.resultLabel setText:[NSString stringWithFormat:@"+ %d",part.action]];
            if (!isBtnForBuy) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"VV_SHOOSE_VALUE"]==index) {
                    btnBuyMain.alpha = 0.4;
                    btnBuyMain.enabled = NO;
                }
            }
            playerAccount.visualViewShoose = index;

            break;
        case CharacterPartSuit:
            visualViewCharacter.suits.image = part.imageForObject;
            
            [self.resultLabel setText:[NSString stringWithFormat:@"+ %d",part.action]];
            if (!isBtnForBuy) {
                if (playerAccount.visualViewSuits==index) {
                    btnBuyMain.alpha = 0.4;
                    btnBuyMain.enabled = NO;
                }
            }
            playerAccount.visualViewSuits = index;
            
            break;
        default :
            break;
    }
    [playerAccount recountDefenseAndAtack];
    [self refreshController];
}

-(void) grid:(GMGridView*)grid buyProductForIndex:(NSInteger)index forType:(CharacterPart)type;
{
    CDVisualViewCharacterPart *part = [arrObjects objectAtIndex:index];

    NSString *stType = [self stringForType:type];
    
    BOOL partBought = [playerAccount isProductBought:part.dId];
    
    if (partBought || part.money==0){
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"/BuilderVC_use_it_%@",stType] forKey:@"page"]];
    }else{
        //    block by level
        NSString *stType = [self stringForType:typeOfCharacterPart];
        
        CDVisualViewCharacterPart *part = [arrObjects objectAtIndex:curentObject];
        
        if (playerAccount.accountLevel < part.levelLock) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"/BuilderVC_block_level_%@",stType] forKey:@"page"]];
            return;
        }
        //  less money
        if (part.money>playerAccount.money) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"/BuilderVC_insufficiently_money_%@",stType] forKey:@"page"]];
            return;
        }

        
        [duelProductDownloaderController buyProductID:part.dId transactionID:playerAccount.glNumber];
        
        CDTransaction *transaction = [[CDTransaction alloc] init];
        transaction.trDescription = [NSString stringWithFormat:@"/BuyPart_%@_%d",stType,part.dId];
        transaction.trType = [NSNumber numberWithInt:-1];
        transaction.trMoneyCh = [NSNumber numberWithInt:-part.money];
        transaction.trLocalID = [NSNumber numberWithInt:[playerAccount increaseGlNumber]];
        transaction.trOpponentID = @"";
        transaction.trGlobalID = [NSNumber numberWithInt:-1];
        
        [playerAccount.transactions addObject:transaction];
        [playerAccount saveTransaction];
        [playerAccount sendTransactions:playerAccount.transactions];
        
        playerAccount.money -= part.money;
        [self lostMoneyAnimation:part.money];
        [playerAccount saveMoney];
        
        [self addProductToBought:part.dId];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"/BuilderVC_buy_%@",stType] forKey:@"page"]];
    }
    switch (type) {
        case CharacterPartCap:
            playerAccount.visualViewCap = index;
            break;
        case CharacterPartFace:
            playerAccount.visualViewHead = index;
            break;
        case CharacterPartGun:
            playerAccount.visualViewGuns = index;
            break;
        case CharacterPartJaket:
            playerAccount.visualViewJackets = index;
            break;
        case CharacterPartLegs:
            playerAccount.visualViewLegs = index;
            break;
        case CharacterPartShirt:
            playerAccount.visualViewBody = index;
            break;
        case CharacterPartShoose:
            playerAccount.visualViewShoose = index;
            break;
        case CharacterPartSuit:
            playerAccount.visualViewSuits = index;
            break;
        default :
            break;
    }
    [playerAccount recountDefenseAndAtack];
    [playerAccount saveVisualView];
    
    [[StartViewController sharedInstance] modifierUser:playerAccount];
    
    [self setObjectsForIndex:index];
    [self refreshControllerWithGrid];
}

#pragma mark DuelProductDownloaderControllerDelegate

-(void)didFinishDownloadWithType:(DuelProductDownloaderType)type error:(NSError *)error;
{
    
}

#pragma mark IBAction
- (IBAction)touchCloseBtn:(id)sender {
    
    [self touchCloseSideView:Nil];
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                     }];
    [self.navigationController popViewControllerAnimated:NO];
//    [self releaseComponents];
}

- (IBAction)touchCloseSideView:(id)sender {
    [playerAccount loadVisualView];
    [self cleanAll];
    [self sideCloseAnimation];
    [self refreshController];
}

- (IBAction)touchBuyBtn:(id)sender{    
    [self grid:grid buyProductForIndex:curentObject forType:typeOfCharacterPart];
}

- (IBAction)touchFaceBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
        self.backlightAtac.hidden = NO;
        [self backlightAtacAction];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/BuilderVC_face" forKey:@"page"]];
    }
    
    arrObjects = [visualViewDataSource arrayHead];
    typeOfCharacterPart = CharacterPartFace;
    
    [grid reloadData];
    [sideView setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewHead];
}
- (IBAction)touchHatBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
        self.backlightDefens.hidden = NO;
        [self backlightDefensAction];
        [self cleanForClothes];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/BuilderVC_hat" forKey:@"page"]];
    }
    
    arrObjects = [visualViewDataSource arrayCap];
    typeOfCharacterPart = CharacterPartCap;

    [grid reloadData];
    [sideView setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewCap];

}
- (IBAction)touchShirtBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
        self.backlightDefens.hidden = NO;
        [self backlightDefensAction];
        [self cleanForClothes];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/BuilderVC_shirt" forKey:@"page"]];
    }
    
    typeOfCharacterPart = CharacterPartShirt;

    arrObjects = [visualViewDataSource arrayBody];
    
    [grid reloadData];
    [sideView setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewBody];
}
- (IBAction)touchJaketBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
        self.backlightDefens.hidden = NO;
        [self backlightDefensAction];
        [self cleanForClothes];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/BuilderVC_jacket" forKey:@"page"]];
    }
    
    typeOfCharacterPart = CharacterPartJaket;
    
    arrObjects = [visualViewDataSource arrayJakets];

    [grid reloadData];
    [sideView setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewJackets];
}
- (IBAction)touchShoesBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
        self.backlightDefens.hidden = NO;
        [self backlightDefensAction];
        [self cleanForClothes];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/BuilderVC_shoes" forKey:@"page"]];
    }
    
    typeOfCharacterPart = CharacterPartShoose;
    
    arrObjects = [visualViewDataSource arrayShoose];

    [grid reloadData];
    [sideView setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewShoose];
}
- (IBAction)touchGunsBtn:(id)sender {
    if (!isOpenSide && self.backlightAtac.hidden) {
        [self sideOpenAnimation];
        self.backlightAtac.hidden = NO;
        [self backlightAtacAction];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/BuilderVC_gun" forKey:@"page"]];
    }
    
    typeOfCharacterPart = CharacterPartGun;
    
    arrObjects = [visualViewDataSource arrayGuns];

    [grid reloadData];
    [sideView setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewGuns];
}
- (IBAction)touchPantsBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
        self.backlightDefens.hidden = NO;
        [self backlightDefensAction];
        [self cleanForClothes];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/BuilderVC_pants" forKey:@"page"]];
    }
    
    typeOfCharacterPart = CharacterPartLegs;
    
    arrObjects = [visualViewDataSource arrayLegs];

    [grid reloadData];
    [sideView setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewLegs];
}
- (IBAction)touchSuitsBtn:(id)sender {
    if (!isOpenSide && self.backlightDefens.hidden) {
        [self sideOpenAnimation];
        self.backlightDefens.hidden = NO;
        [self backlightDefensAction];
        [self cleanForSuits];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/BuilderVC_suit" forKey:@"page"]];
    }
    
    typeOfCharacterPart = CharacterPartSuit;
    
    arrObjects = [visualViewDataSource arraySuits];
    
    [grid reloadData];
    [sideView setUserInteractionEnabled:YES];
    [self setObjectsForIndex:playerAccount.visualViewSuits];
}

- (IBAction)btnMyProfileClick:(id)sender {
    profileViewController = [[ProfileViewController alloc] initWithAccount:playerAccount];
    [profileViewController setNeedAnimation:YES];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2.5f];
    
    [self.view addSubview:profileViewController.view];
    
    [UIView commitAnimations];
}

#pragma mark

-(void)tempDefens:(int)plusOnDefens
{
     self.defensLabel.text = [NSString stringWithFormat:@"%d",playerAccount.accountDefenseValue + [DuelRewardLogicController countUpBuletsWithPlayerLevel:playerAccount.accountLevel]];
}
-(void)tempAtac:(int)plusOnAtac
{
     self.attacLabel.text = [NSString stringWithFormat:@"%d",playerAccount.accountAtackValue + [DuelRewardLogicController countUpBuletsWithPlayerLevel:playerAccount.accountLevel]];
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
        lbBuyBtn.text = NSLocalizedString(@"USE", @"");
        
        btnBuyMain.alpha = 1.0;
        btnBuyMain.enabled = YES;
        return NO;
    }else{
        lbBuyBtn.text = NSLocalizedString(@"BUYIT", @"");
        
        if (part.money>playerAccount.money) {
            btnBuyMain.alpha = 0.4;
        }else{
            btnBuyMain.alpha = 1.0;
        }
        btnBuyMain.enabled = YES;
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
    playerAccount.visualViewCap = 0;
    playerAccount.visualViewBody = 0;
    playerAccount.visualViewJackets = 0;
    playerAccount.visualViewLegs = 0;
    playerAccount.visualViewShoose = 0;
    
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

-(void)cleanForClothes
{
    playerAccount.visualViewSuits = 0;
    
    CDVisualViewCharacterPartSuits *visualViewCharacterPartSuits = [[visualViewDataSource arraySuits] objectAtIndex:0];
    visualViewCharacter.suits.image = [visualViewCharacterPartSuits imageForObject];
    visualViewCharacterPartSuits = nil;
}

-(void)cleanAll
{
    [visualViewCharacter refreshWithAccountPlayer:playerAccount];
}

-(NSString*)stringForType:(CharacterPart)type
{
    NSString *stType = @"";
    switch (type) {
        case CharacterPartCap:
            stType = @"Cap";
            break;
        case CharacterPartFace:
            stType = @"Face";
            break;
        case CharacterPartGun:
            stType = @"Gun";
            break;
        case CharacterPartJaket:
            stType = @"Jaket";
            break;
        case CharacterPartLegs:
            stType = @"Legs";
            break;
        case CharacterPartShirt:
            stType = @"Shirt";
            break;
        case CharacterPartShoose:
            stType = @"Shoose";
            break;
        case CharacterPartSuit:
            stType = @"Suit";
            break;
        default :
            break;
    }
    return stType;
}
#pragma mark -
-(void)dealloc
{
    [self releaseComponents];
}
@end
