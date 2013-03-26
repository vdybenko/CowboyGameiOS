#import "VisualViewCharacterViewController.h"
#import "AccountDataSource.h"
#import "UIButton+Image+Title.h"
#import "VisualViewDataSource.h"
#import "VisualViewCharacter.h"
#import "ScrollViewSwitcher.h"

@interface VisualViewCharacterViewController ()
{
//    __weak IBOutlet UILabel *title;
//    __weak IBOutlet UIButton *btnBack;
//    __weak IBOutlet UIView *activityView;
//    __weak AccountDataSource *playerAccount;
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
    
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    [btnBack setTitleByLabel:@"BACK"];
    [btnBack changeColorOfTitleByLabel:buttonsTitleColor];
    
    [btnAccept setTitleByLabel:@"ACCEPT"];
    [btnAccept changeColorOfTitleByLabel:buttonsTitleColor];
    
    visualViewDataSource = [[VisualViewDataSource alloc] init];
    
    visualViewCharacter.visualViewDataSource = visualViewDataSource;
    [visualViewCharacter refreshWithAccountPlayer:[AccountDataSource sharedInstance]];
    
    scrollViewSwitcherCap.rectForObjetc = (CGRect){0,0,70,45};
    scrollViewSwitcherCap.arraySwitchObjects = [visualViewDataSource arrayCap];
    scrollViewSwitcherCap.curentObject = [AccountDataSource sharedInstance].visualViewCap;
    scrollViewSwitcherCap.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartCap *visualViewCharacterPart = [scrollViewSwitcherCap.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.cap.image = [visualViewCharacterPart imageForObject];
        [AccountDataSource sharedInstance].visualViewCap = curentIndex;
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
        [AccountDataSource sharedInstance].visualViewHead = curentIndex;
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
        [AccountDataSource sharedInstance].visualViewBody = curentIndex;
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
        [AccountDataSource sharedInstance].visualViewLegth = curentIndex;
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
        [AccountDataSource sharedInstance].visualViewShoose = curentIndex;
    };
    scrollViewSwitcherShoose.colorizeImage = visualViewCharacter.shoose;
    [scrollViewSwitcherShoose trimObjectsToView:visualViewCharacter.shoose];
    [scrollViewSwitcherShoose setMainControls];
    
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
    [super viewDidUnload];
}
-(void)refreshController;
{
}

- (void)releaseComponents
{
    [visualViewDataSource releaseComponents];
    visualViewDataSource = nil;
    [scrollViewSwitcherCap releaseComponents];
    scrollViewSwitcherCap = nil;
    [scrollViewSwitcherHead releaseComponents];
    scrollViewSwitcherHead = nil;
    [scrollViewSwitcherBody releaseComponents];
    scrollViewSwitcherBody = nil;
    [visualViewCharacter releaseComponents];
    visualViewCharacter = nil;
    btnBack = nil;
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
@end
