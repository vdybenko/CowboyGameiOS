#import "VisualViewCharacterViewController.h"
#import "AccountDataSource.h"
#import "UIButton+Image+Title.h"
#import "VisualViewDataSource.h"
#import "VisualViewCharacter.h"
#import "ScrollViewSwitcher.h"

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
    
    int visualViewCapSaved;
    int visualViewHeadSaved;
    int visualViewBodySaved;
    int visualViewLegthSaved;
    int visualViewShooseSaved;
}
@end

@implementation VisualViewCharacterViewController
@synthesize visualViewDataSource;
#pragma mark - Instance initialization

-(id)init;
{
    self = [super initWithNibName:@"VisualViewCharacterViewController" bundle:[NSBundle mainBundle]];
    if (self) {
//        playerAccount = [AccountDataSource sharedInstance];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    playerAccount = [AccountDataSource sharedInstance];
    visualViewCapSaved = playerAccount.visualViewCap;
    visualViewHeadSaved = playerAccount.visualViewHead;
    visualViewBodySaved = playerAccount.visualViewBody;
    visualViewLegthSaved = playerAccount.visualViewLegth;
    visualViewShooseSaved = playerAccount.visualViewShoose;
    
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    [btnBack setTitleByLabel:@"BACK"];
    [btnBack changeColorOfTitleByLabel:buttonsTitleColor];
    
    [btnAccept setTitleByLabel:@"ACCEPT"];
    [btnAccept changeColorOfTitleByLabel:buttonsTitleColor];
    
    userMoney.text = [NSString stringWithFormat:@"%d",playerAccount.money];

    
    visualViewDataSource = [[VisualViewDataSource alloc] init];    
    visualViewCharacter.visualViewDataSource = visualViewDataSource;
    [visualViewCharacter refreshWithAccountPlayer:playerAccount];
    
    scrollViewSwitcherCap.rectForObjetc = (CGRect){0,0,70,45};
    scrollViewSwitcherCap.arraySwitchObjects = [visualViewDataSource arrayCap];
    scrollViewSwitcherCap.curentObject = [AccountDataSource sharedInstance].visualViewCap;
    scrollViewSwitcherCap.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartCap *visualViewCharacterPart = [scrollViewSwitcherCap.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.cap.image = [visualViewCharacterPart imageForObject];
        playerAccount.visualViewCap = curentIndex;
        
        [self fillCap];
    };
    scrollViewSwitcherCap.colorizeImage = visualViewCharacter.cap;
    [scrollViewSwitcherCap trimObjectsToView:visualViewCharacter.cap];
    [scrollViewSwitcherCap setMainControls];
    
    scrollViewSwitcherHead.rectForObjetc = (CGRect){0,0,70,45};
    scrollViewSwitcherHead.arraySwitchObjects = [visualViewDataSource arrayHead];
    scrollViewSwitcherHead.curentObject = 0;
    scrollViewSwitcherHead.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartHead *visualViewCharacterPart = [scrollViewSwitcherHead.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.head.image = [visualViewCharacterPart imageForObject];
        playerAccount.visualViewHead = curentIndex;
        
        [self fillHead];
    };
    scrollViewSwitcherHead.colorizeImage = visualViewCharacter.head;
    [scrollViewSwitcherHead trimObjectsToView:visualViewCharacter.head];
    [scrollViewSwitcherHead setMainControls];

    scrollViewSwitcherBody.rectForObjetc = (CGRect){0,0,200,155};
    scrollViewSwitcherBody.arraySwitchObjects = [visualViewDataSource arrayBody];
    scrollViewSwitcherBody.curentObject = 0;
    scrollViewSwitcherBody.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartBody *visualViewCharacterPart = [scrollViewSwitcherBody.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.body.image = [visualViewCharacterPart imageForObject];
        playerAccount.visualViewBody = curentIndex;
        
        [self fillBody];
    };
    scrollViewSwitcherBody.colorizeImage = visualViewCharacter.body;
    [scrollViewSwitcherBody trimObjectsToView:visualViewCharacter.body];
    [scrollViewSwitcherBody setMainControls];
    
    scrollViewSwitcherLegth.rectForObjetc = (CGRect){0,0,165,200};
    scrollViewSwitcherLegth.arraySwitchObjects = [visualViewDataSource arrayLegth];
    scrollViewSwitcherLegth.curentObject = 0;
    scrollViewSwitcherLegth.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartLegth *visualViewCharacterPart = [scrollViewSwitcherLegth.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.length.image = [visualViewCharacterPart imageForObject];
        playerAccount.visualViewLegth = curentIndex;
        
        [self fillLegth];
    };
    scrollViewSwitcherLegth.colorizeImage = visualViewCharacter.length;
    [scrollViewSwitcherLegth trimObjectsToView:visualViewCharacter.length];
    [scrollViewSwitcherLegth setMainControls];
    
    scrollViewSwitcherShoose.rectForObjetc = (CGRect){0,0,160,100};
    scrollViewSwitcherShoose.arraySwitchObjects = [visualViewDataSource arrayShoose];
    scrollViewSwitcherShoose.curentObject = 0;
    scrollViewSwitcherShoose.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartShoose *visualViewCharacterPart = [scrollViewSwitcherShoose.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.shoose.image = [visualViewCharacterPart imageForObject];
        playerAccount.visualViewShoose = curentIndex;
        
        [self fillShoose];
    };
    scrollViewSwitcherShoose.colorizeImage = visualViewCharacter.shoose;
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
    [super viewDidUnload];
}
-(void)refreshController;
{
}

- (void)releaseComponents
{
    [self viewDidUnload];
}

#pragma mark IBAction
- (IBAction)btnAcceptClick:(id)sender {
}

- (IBAction)btnBackClick:(id)sender {
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                     }];
    [self.navigationController popViewControllerAnimated:NO];
    [[AccountDataSource sharedInstance] saveVisualView];
    [self releaseComponents];
}

#pragma mark
-(void)fillCap
{
    CDVisualViewCharacterPartCap *visualViewCharacterPart = [scrollViewSwitcherCap.arraySwitchObjects objectAtIndex:playerAccount.visualViewCap];
    lbMoneyCap.text = [NSString stringWithFormat:@"$%d",visualViewCharacterPart.money];
    lbActionCap.text = [NSString stringWithFormat:@"+%d %@",visualViewCharacterPart.action,NSLocalizedString(@"defence", @"")];
    UIColor *color;
    if (playerAccount.visualViewCap==visualViewCapSaved) {
        color = [UIColor blackColor];
    }else{
        CDVisualViewCharacterPartCap *visualViewCharacterPartSaved = [scrollViewSwitcherCap.arraySwitchObjects objectAtIndex:visualViewCapSaved];
        if (visualViewCharacterPart.action>visualViewCharacterPartSaved.action) {
            color = [UIColor greenColor];
        }else{
            color = [UIColor redColor];
        }
    }
    lbActionCap.textColor = color;
}

-(void)fillHead
{
    CDVisualViewCharacterPartHead *visualViewCharacterPart = [scrollViewSwitcherHead.arraySwitchObjects objectAtIndex:playerAccount.visualViewHead];
    lbMoneyHead.text = [NSString stringWithFormat:@"$%d",visualViewCharacterPart.money];
}
 
-(void)fillBody
{
    CDVisualViewCharacterPartBody *visualViewCharacterPart = [scrollViewSwitcherBody.arraySwitchObjects objectAtIndex:playerAccount.visualViewBody];
    lbMoneyBody.text = [NSString stringWithFormat:@"$%d",visualViewCharacterPart.money];
    lbActionBody.text = [NSString stringWithFormat:@"+%d %@",visualViewCharacterPart.action,NSLocalizedString(@"defence", @"")];
    UIColor *color;
    if (playerAccount.visualViewBody==visualViewBodySaved) {
        color = [UIColor blackColor];
    }else{
        CDVisualViewCharacterPartBody *visualViewCharacterPartSaved = [scrollViewSwitcherBody.arraySwitchObjects objectAtIndex:visualViewBodySaved];
        if (visualViewCharacterPart.action>visualViewCharacterPartSaved.action) {
            color = [UIColor greenColor];
        }else{
            color = [UIColor redColor];
        }
    }
    lbActionBody.textColor = color;
}

-(void)fillLegth
{
    CDVisualViewCharacterPartLegth *visualViewCharacterPart = [scrollViewSwitcherLegth.arraySwitchObjects objectAtIndex:playerAccount.visualViewLegth];
    lbMoneyLegth.text = [NSString stringWithFormat:@"$%d",visualViewCharacterPart.money];
    lbActionLegth.text = [NSString stringWithFormat:@"+%d %@",visualViewCharacterPart.action,NSLocalizedString(@"defence", @"")];
    UIColor *color;
    if (playerAccount.visualViewLegth==visualViewLegthSaved) {
        color = [UIColor blackColor];
    }else{
        CDVisualViewCharacterPartLegth *visualViewCharacterPartSaved = [scrollViewSwitcherLegth.arraySwitchObjects objectAtIndex:visualViewLegthSaved];
        if (visualViewCharacterPart.action>visualViewCharacterPartSaved.action) {
            color = [UIColor greenColor];
        }else{
            color = [UIColor redColor];
        }
    }
    lbActionLegth.textColor = color;
}

-(void)fillShoose
{
    CDVisualViewCharacterPartShoose *visualViewCharacterPart = [scrollViewSwitcherShoose.arraySwitchObjects objectAtIndex:playerAccount.visualViewShoose];
    lbMoneyShoose.text = [NSString stringWithFormat:@"$%d",visualViewCharacterPart.money];
    lbActionShoose.text = [NSString stringWithFormat:@"+%d %@",visualViewCharacterPart.action,NSLocalizedString(@"defence", @"")];
    UIColor *color;
    if (playerAccount.visualViewShoose==visualViewShooseSaved) {
        color = [UIColor blackColor];
    }else{
        CDVisualViewCharacterPartShoose *visualViewCharacterPartSaved = [scrollViewSwitcherShoose.arraySwitchObjects objectAtIndex:visualViewShooseSaved];
        if (visualViewCharacterPart.action>visualViewCharacterPartSaved.action) {
            color = [UIColor greenColor];
        }else{
            color = [UIColor redColor];
        }
    }
    lbActionShoose.textColor = color;
}

@end
