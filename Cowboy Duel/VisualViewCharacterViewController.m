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
    __weak IBOutlet ScrollViewSwitcher *scrollViewSwitcheLegth;
    __weak IBOutlet ScrollViewSwitcher *scrollViewSwitcheShoose;
    __weak IBOutlet UIButton *btnBack;
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
    
    scrollViewSwitcheLegth.rectForObjetc = (CGRect){0,0,165,200};
    scrollViewSwitcheLegth.arraySwitchObjects = [visualViewDataSource arrayLegth];
    scrollViewSwitcheLegth.curentObject = 0;
    scrollViewSwitcheLegth.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartLegth *visualViewCharacterPart = [scrollViewSwitcheLegth.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.length.image = [visualViewCharacterPart imageForObject];
        [AccountDataSource sharedInstance].visualViewLegth = curentIndex;
    };
    scrollViewSwitcheLegth.colorizeImage = visualViewCharacter.length;
    [scrollViewSwitcheLegth trimObjectsToView:visualViewCharacter.length];
    [scrollViewSwitcheLegth setMainControls];
    
    scrollViewSwitcheShoose.rectForObjetc = (CGRect){0,0,160,100};
    scrollViewSwitcheShoose.arraySwitchObjects = [visualViewDataSource arrayShoose];
    scrollViewSwitcheShoose.curentObject = 0;
    scrollViewSwitcheShoose.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartShoose *visualViewCharacterPart = [scrollViewSwitcheShoose.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.shoose.image = [visualViewCharacterPart imageForObject];
        [AccountDataSource sharedInstance].visualViewShoose = curentIndex;
    };
    scrollViewSwitcheShoose.colorizeImage = visualViewCharacter.shoose;
    [scrollViewSwitcheShoose trimObjectsToView:visualViewCharacter.shoose];
    [scrollViewSwitcheShoose setMainControls];
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
    [visualViewCharacter releaseComponents];
    visualViewCharacter = nil;
    [visualViewDataSource releaseComponents];
    visualViewDataSource = nil;
    btnBack = nil;
    scrollViewSwitcheLegth = nil;
    scrollViewSwitcheShoose = nil;
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
