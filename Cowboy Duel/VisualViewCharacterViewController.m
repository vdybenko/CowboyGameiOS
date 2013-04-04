#import "VisualViewCharacterViewController.h"
#import "AccountDataSource.h"
#import "UIButton+Image+Title.h"
#import "VisualViewDataSource.h"
#import "VisualViewCharacter.h"
#import "ScrollViewSwitcher.h"
#import "DuelProductDownloaderController.h"

@interface VisualViewCharacterViewController ()
{
    __weak AccountDataSource *playerAccount;
    __weak IBOutlet VisualViewCharacter *visualViewCharacter;
    __weak IBOutlet ScrollViewSwitcher *scrollViewSwitcherCap;
    __weak IBOutlet ScrollViewSwitcher *scrollViewSwitcherHead;
    __weak IBOutlet ScrollViewSwitcher *scrollViewSwitcherBody;
    __weak IBOutlet ScrollViewSwitcher *scrollViewSwitcherLegth;
    __weak IBOutlet ScrollViewSwitcher *scrollViewSwitcherShoose;
    __weak IBOutlet UIButton *btnBack;
    __weak IBOutlet UIButton *btnAccept;
    
    __weak IBOutlet UIView *rightSideView;
    __weak IBOutlet UIView *leftSideView;
    
    __weak IBOutlet UILabel *lbMoneyCap;
    __weak IBOutlet UILabel *lbActionCap;
    __weak IBOutlet UILabel *lbMoneyHead;
    __weak IBOutlet UILabel *lbActionHead;
    __weak IBOutlet UILabel *lbMoneyBody;
    __weak IBOutlet UILabel *lbActionBody;
    __weak IBOutlet UILabel *lbMoneyLegth;
    __weak IBOutlet UILabel *lbActionLegth;
    __weak IBOutlet UILabel *lbMoneyShoose;
    __weak IBOutlet UILabel *lbActionShoose;
    
    __weak IBOutlet UILabel *userMoney;
    __weak IBOutlet UILabel *moneyForBuy;
    __weak IBOutlet UIView *loadingView;
    
    int visualViewCapSelect;
    int visualViewHeadSelect;
    int visualViewBodySelect;
    int visualViewLegthSelect;
    int visualViewShooseSelect;
    int sumToBuy;
    NSMutableDictionary *dicOfProductsToSend;
    
    DuelProductDownloaderController *duelProductDownloaderController;
    
}
@end

@implementation VisualViewCharacterViewController
@synthesize visualViewDataSource;
#pragma mark - Instance initialization

-(id)init;
{
    self = [super initWithNibName:@"VisualViewCharacterViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        playerAccount = [AccountDataSource sharedInstance];
        dicOfProductsToSend = [NSMutableDictionary dictionary];
        sumToBuy = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    duelProductDownloaderController = [[DuelProductDownloaderController alloc] init];

    visualViewCapSelect = playerAccount.visualViewCap;
    visualViewHeadSelect = playerAccount.visualViewHead;
    visualViewBodySelect = playerAccount.visualViewBody;
    visualViewLegthSelect = playerAccount.visualViewLegth;
    visualViewShooseSelect = playerAccount.visualViewShoose;
    
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    [btnBack setTitleByLabel:@"BACK"];
    [btnBack changeColorOfTitleByLabel:buttonsTitleColor];
    
    [btnAccept setTitleByLabel:@"ACCEPT"];
    [btnAccept changeColorOfTitleByLabel:buttonsTitleColor];
    btnAccept.enabled = NO;
    
    userMoney.text = [NSString stringWithFormat:@"%d",playerAccount.money];
    moneyForBuy.text = [NSString stringWithFormat:@"%d",sumToBuy];
    
    visualViewDataSource = [[VisualViewDataSource alloc] init];    
    visualViewCharacter.visualViewDataSource = visualViewDataSource;
    [visualViewCharacter refreshWithAccountPlayer:playerAccount];
    
    scrollViewSwitcherCap.rectForObjetc = CGRectMake(0,0,70,45);
    scrollViewSwitcherCap.arraySwitchObjects = [visualViewDataSource arrayCap];
    scrollViewSwitcherCap.curentObject = playerAccount.visualViewCap;
    scrollViewSwitcherCap.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartCap *visualViewCharacterPart = [scrollViewSwitcherCap.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.cap.image = [visualViewCharacterPart imageForObject];
        visualViewCapSelect = curentIndex;
        
        [self refreshController];
    };
    [scrollViewSwitcherCap trimObjectsToView:visualViewCharacter.cap];
    [scrollViewSwitcherCap setMainControls];
    
    scrollViewSwitcherHead.rectForObjetc = CGRectMake(0,0,70,45);
    scrollViewSwitcherHead.arraySwitchObjects = [visualViewDataSource arrayHead];
    scrollViewSwitcherHead.curentObject = playerAccount.visualViewHead;
    scrollViewSwitcherHead.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartHead *visualViewCharacterPart = [scrollViewSwitcherHead.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.head.image = [visualViewCharacterPart imageForObject];
        visualViewHeadSelect = curentIndex;
        
        [self refreshController];
    };
    [scrollViewSwitcherHead trimObjectsToView:visualViewCharacter.head];
    [scrollViewSwitcherHead setMainControls];

    scrollViewSwitcherBody.rectForObjetc = CGRectMake(0,0,200,155);
    scrollViewSwitcherBody.arraySwitchObjects = [visualViewDataSource arrayBody];
    scrollViewSwitcherBody.curentObject = playerAccount.visualViewBody;
    scrollViewSwitcherBody.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartBody *visualViewCharacterPart = [scrollViewSwitcherBody.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.body.image = [visualViewCharacterPart imageForObject];
       visualViewBodySelect = curentIndex;
        
        [self refreshController];
    };
    [scrollViewSwitcherBody trimObjectsToView:visualViewCharacter.body];
    [scrollViewSwitcherBody setMainControls];
    
    scrollViewSwitcherLegth.rectForObjetc = CGRectMake(0,0,165,200);
    scrollViewSwitcherLegth.arraySwitchObjects = [visualViewDataSource arrayLegth];
    scrollViewSwitcherLegth.curentObject = playerAccount.visualViewLegth;
    scrollViewSwitcherLegth.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartLegth *visualViewCharacterPart = [scrollViewSwitcherLegth.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.length.image = [visualViewCharacterPart imageForObject];
        visualViewLegthSelect = curentIndex;
        
        [self refreshController];
    };
    [scrollViewSwitcherLegth trimObjectsToView:visualViewCharacter.length];
    [scrollViewSwitcherLegth setMainControls];
    
    scrollViewSwitcherShoose.rectForObjetc = CGRectMake(0,0,160,100);
    scrollViewSwitcherShoose.arraySwitchObjects = [visualViewDataSource arrayShoose];
    scrollViewSwitcherShoose.curentObject = playerAccount.visualViewShoose;
    scrollViewSwitcherShoose.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartShoose *visualViewCharacterPart = [scrollViewSwitcherShoose.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.shoose.image = [visualViewCharacterPart imageForObject];
        visualViewShooseSelect = curentIndex;
        
        [self refreshController];
    };
    [scrollViewSwitcherShoose trimObjectsToView:visualViewCharacter.shoose];
    [scrollViewSwitcherShoose setMainControls];
    
    [self fillCap];
    [self fillHead];
    [self fillBody];
    [self fillLegth];
    [self fillShoose];
    
    int iPhone5Delta = [UIScreen mainScreen].bounds.size.height - 480;
    //    deltas for 5 iPhone
    if (iPhone5Delta>0) {
        iPhone5Delta = 25;
        
        CGRect frame = leftSideView.frame;
        frame.origin.y += iPhone5Delta;
        [leftSideView setFrame:frame];
        
        frame = rightSideView.frame;
        frame.origin.y += iPhone5Delta;
        [rightSideView setFrame:frame];
        
        frame = visualViewCharacter.frame;
        frame.origin.y += iPhone5Delta;
        [visualViewCharacter setFrame:frame];
        
        frame = scrollViewSwitcherCap.frame;
        frame.origin.y += iPhone5Delta;
        [scrollViewSwitcherCap setFrame:frame];
        
        frame = scrollViewSwitcherHead.frame;
        frame.origin.y += iPhone5Delta;
        [scrollViewSwitcherHead setFrame:frame];
        
        frame = scrollViewSwitcherBody.frame;
        frame.origin.y += iPhone5Delta;
        [scrollViewSwitcherBody setFrame:frame];
        
        frame = scrollViewSwitcherLegth.frame;
        frame.origin.y += iPhone5Delta;
        [scrollViewSwitcherLegth setFrame:frame];
        
        frame = scrollViewSwitcherShoose.frame;
        frame.origin.y += iPhone5Delta;
        [scrollViewSwitcherShoose setFrame:frame];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog(@"VisualViewCharacterViewController didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {

    [scrollViewSwitcherCap releaseComponents];
    scrollViewSwitcherCap = nil;
    [scrollViewSwitcherHead releaseComponents];
    scrollViewSwitcherHead = nil;
    [scrollViewSwitcherBody releaseComponents];
    scrollViewSwitcherBody = nil;
    [scrollViewSwitcherLegth releaseComponents];
    scrollViewSwitcherLegth = nil;
    [scrollViewSwitcherShoose releaseComponents];
    scrollViewSwitcherShoose = nil;
    [visualViewCharacter releaseComponents];
    visualViewCharacter = nil;
    [visualViewDataSource releaseComponents];
    visualViewDataSource = nil;
    btnBack = nil;
    scrollViewSwitcherLegth = nil;
    scrollViewSwitcherShoose = nil;
    btnAccept = nil;
    rightSideView = nil;
    leftSideView = nil;
    userMoney = nil;
    lbMoneyCap = nil;
    lbActionCap = nil;
    lbMoneyHead = nil;
    lbActionHead = nil;
    lbMoneyBody = nil;
    lbActionBody = nil;
    lbMoneyLegth = nil;
    lbActionLegth = nil;
    lbMoneyShoose = nil;
    lbActionShoose = nil;
    loadingView = nil;
    moneyForBuy = nil;
    [super viewDidUnload];
}

- (void)releaseComponents
{
    [self viewDidUnload];
    duelProductDownloaderController = nil;
    [dicOfProductsToSend removeAllObjects];
    dicOfProductsToSend = nil;
}

#pragma mark IBAction
- (IBAction)btnAcceptClick:(id)sender {
    
    loadingView.hidden = NO;
    [playerAccount increaseGlNumber];
    for (int i=1; i<[dicOfProductsToSend count]-1; i++) {
        int ID = [[[dicOfProductsToSend allValues] objectAtIndex:i] integerValue];
        [duelProductDownloaderController buyProductID:ID transactionID:playerAccount.glNumber];
    }
    
    int ID = [[[dicOfProductsToSend allValues] objectAtIndex:0] integerValue];
    [duelProductDownloaderController buyProductID:ID transactionID:playerAccount.glNumber];
    __block AccountDataSource *playerAccountBlock = playerAccount;
    __block UIView *loadingViewBlock = loadingView;
    duelProductDownloaderController.didFinishBlock = ^(NSError *error){
        if (!error) {
            CDTransaction *transaction = [[CDTransaction alloc] init];
            transaction.trDescription = @"CharacterBuilder";
            transaction.trType = [NSNumber numberWithInt:-1];
            transaction.trMoneyCh = [NSNumber numberWithInt:sumToBuy];
            transaction.trLocalID = [NSNumber numberWithInt:playerAccountBlock.glNumber];
            transaction.trOpponentID = @"";
            transaction.trGlobalID = [NSNumber numberWithInt:-1];
            
            [playerAccountBlock.transactions addObject:transaction];
            [playerAccountBlock saveTransaction];
            [playerAccountBlock sendTransactions:playerAccountBlock.transactions];
            
            playerAccountBlock.money -= sumToBuy;
            [playerAccountBlock saveMoney];
            
            playerAccountBlock.visualViewCap = visualViewCapSelect;
            playerAccountBlock.visualViewHead = visualViewHeadSelect;
            playerAccountBlock.visualViewBody = visualViewBodySelect;
            playerAccountBlock.visualViewLegth = visualViewLegthSelect;
            playerAccountBlock.visualViewShoose = visualViewShooseSelect;
            
            [playerAccountBlock saveVisualView];
            [self refreshController];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                loadingViewBlock.hidden = YES;
            });
            
        }
    };
}

- (IBAction)btnBackClick:(id)sender {
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                     }];
    [self.navigationController popViewControllerAnimated:NO];
    
    playerAccount.visualViewCap = visualViewCapSelect;
    playerAccount.visualViewHead = visualViewHeadSelect;
    playerAccount.visualViewBody = visualViewBodySelect;
    playerAccount.visualViewLegth = visualViewLegthSelect;
    playerAccount.visualViewShoose = visualViewShooseSelect;
    
    [self releaseComponents];
}

#pragma mark
-(void)refreshController;
{
    sumToBuy = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fillCap];
        [self fillHead];
        [self fillBody];
        [self fillLegth];
        [self fillShoose];
        if (sumToBuy && (sumToBuy<=playerAccount.money)) {
            btnAccept.enabled = YES;
        }else{
            btnAccept.enabled = NO;
        }
        userMoney.text = [NSString stringWithFormat:@"%d",playerAccount.money];
        moneyForBuy.text = [NSString stringWithFormat:@"%d",sumToBuy];
    });
}


-(void)fillCap
{
    CDVisualViewCharacterPartCap *visualViewCharacterPart = [scrollViewSwitcherCap.arraySwitchObjects objectAtIndex:visualViewCapSelect];
    lbMoneyCap.text = [NSString stringWithFormat:@"$%d",visualViewCharacterPart.money];
    lbActionCap.text = [NSString stringWithFormat:@"+%d %@",visualViewCharacterPart.action,NSLocalizedString(@"defence", @"")];
    UIColor *color;
    if (playerAccount.visualViewCap==visualViewCapSelect) {
        color = [UIColor blackColor];
        [dicOfProductsToSend removeObjectForKey:@"cap"];
    }else{
        CDVisualViewCharacterPartCap *visualViewCharacterPartSaved = [scrollViewSwitcherCap.arraySwitchObjects objectAtIndex:playerAccount.visualViewCap];
        if (visualViewCharacterPart.action>visualViewCharacterPartSaved.action) {
            color = [UIColor greenColor];
        }else{
            color = [UIColor redColor];
        }
        sumToBuy+=visualViewCharacterPart.money;
        [dicOfProductsToSend setObject:[NSNumber numberWithInt:visualViewCharacterPart.dId] forKey:@"cap"];
    }
    lbActionCap.textColor = color;
}

-(void)fillHead
{
    CDVisualViewCharacterPartHead *visualViewCharacterPart = [scrollViewSwitcherHead.arraySwitchObjects objectAtIndex:visualViewHeadSelect];
    lbMoneyHead.text = [NSString stringWithFormat:@"$%d",visualViewCharacterPart.money];
    if (playerAccount.visualViewHead==visualViewHeadSelect) {
        [dicOfProductsToSend removeObjectForKey:@"head"];
    }else{
        sumToBuy+=visualViewCharacterPart.money;
        [dicOfProductsToSend setObject:[NSNumber numberWithInt:visualViewCharacterPart.dId] forKey:@"head"];
    }
}
 
-(void)fillBody
{
    CDVisualViewCharacterPartBody *visualViewCharacterPart = [scrollViewSwitcherBody.arraySwitchObjects objectAtIndex:visualViewBodySelect];
    lbMoneyBody.text = [NSString stringWithFormat:@"$%d",visualViewCharacterPart.money];
    lbActionBody.text = [NSString stringWithFormat:@"+%d %@",visualViewCharacterPart.action,NSLocalizedString(@"defence", @"")];
    UIColor *color;
    if (playerAccount.visualViewBody==visualViewBodySelect) {
        color = [UIColor blackColor];
        [dicOfProductsToSend removeObjectForKey:@"body"];
    }else{
        CDVisualViewCharacterPartBody *visualViewCharacterPartSaved = [scrollViewSwitcherBody.arraySwitchObjects objectAtIndex:playerAccount.visualViewBody];
        if (visualViewCharacterPart.action>visualViewCharacterPartSaved.action) {
            color = [UIColor greenColor];
        }else{
            color = [UIColor redColor];
        }
        sumToBuy+=visualViewCharacterPart.money;
        [dicOfProductsToSend setObject:[NSNumber numberWithInt:visualViewCharacterPart.dId] forKey:@"body"];
    }
    lbActionBody.textColor = color;
}

-(void)fillLegth
{
    CDVisualViewCharacterPartLegth *visualViewCharacterPart = [scrollViewSwitcherLegth.arraySwitchObjects objectAtIndex:visualViewLegthSelect];
    lbMoneyLegth.text = [NSString stringWithFormat:@"$%d",visualViewCharacterPart.money];
    lbActionLegth.text = [NSString stringWithFormat:@"+%d %@",visualViewCharacterPart.action,NSLocalizedString(@"defence", @"")];
    UIColor *color;
    if (playerAccount.visualViewLegth==visualViewLegthSelect) {
        color = [UIColor blackColor];
        [dicOfProductsToSend removeObjectForKey:@"legth"];
    }else{
        CDVisualViewCharacterPartLegth *visualViewCharacterPartSaved = [scrollViewSwitcherLegth.arraySwitchObjects objectAtIndex:playerAccount.visualViewLegth];
        if (visualViewCharacterPart.action>visualViewCharacterPartSaved.action) {
            color = [UIColor greenColor];
        }else{
            color = [UIColor redColor];
        }
        sumToBuy+=visualViewCharacterPart.money;
        [dicOfProductsToSend setObject:[NSNumber numberWithInt:visualViewCharacterPart.dId] forKey:@"legth"];
    }
    lbActionLegth.textColor = color;
}

-(void)fillShoose
{
    CDVisualViewCharacterPartShoose *visualViewCharacterPart = [scrollViewSwitcherShoose.arraySwitchObjects objectAtIndex:visualViewShooseSelect];
    lbMoneyShoose.text = [NSString stringWithFormat:@"$%d",visualViewCharacterPart.money];
    lbActionShoose.text = [NSString stringWithFormat:@"+%d %@",visualViewCharacterPart.action,NSLocalizedString(@"defence", @"")];
    UIColor *color;
    if (playerAccount.visualViewShoose==visualViewShooseSelect) {
        color = [UIColor blackColor];
        [dicOfProductsToSend removeObjectForKey:@"shoose"];
    }else{
        CDVisualViewCharacterPartShoose *visualViewCharacterPartSaved = [scrollViewSwitcherShoose.arraySwitchObjects objectAtIndex:playerAccount.visualViewShoose];
        if (visualViewCharacterPart.action>visualViewCharacterPartSaved.action) {
            color = [UIColor greenColor];
        }else{
            color = [UIColor redColor];
        }
        sumToBuy+=visualViewCharacterPart.money;
        [dicOfProductsToSend setObject:[NSNumber numberWithInt:visualViewCharacterPart.dId] forKey:@"shoose"];
    }
    lbActionShoose.textColor = color;
}

@end
