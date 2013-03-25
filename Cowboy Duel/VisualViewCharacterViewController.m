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
    };
    [scrollViewSwitcherCap trimObjectsToView:visualViewCharacter.cap];
    [scrollViewSwitcherCap setMainControls];
    
    scrollViewSwitcherHead.rectForObjetc = (CGRect){0,0,70,45};
    scrollViewSwitcherHead.arraySwitchObjects = [visualViewDataSource arrayHead];
    scrollViewSwitcherHead.curentObject = 0;
    scrollViewSwitcherHead.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartHead *visualViewCharacterPart = [scrollViewSwitcherHead.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.head.image = [visualViewCharacterPart imageForObject];
    };
    [scrollViewSwitcherHead trimObjectsToView:visualViewCharacter.head];
    [scrollViewSwitcherHead setMainControls];

    scrollViewSwitcherBody.rectForObjetc = (CGRect){0,0,183,312};
    scrollViewSwitcherBody.arraySwitchObjects = [visualViewDataSource arrayBody];
    scrollViewSwitcherBody.curentObject = 0;
    scrollViewSwitcherBody.didFinishBlock = ^(NSInteger curentIndex){
        CDVisualViewCharacterPartBody *visualViewCharacterPart = [scrollViewSwitcherBody.arraySwitchObjects objectAtIndex:curentIndex];
        visualViewCharacter.body.image = [visualViewCharacterPart imageForObject];
    };
    [scrollViewSwitcherBody trimObjectsToView:visualViewCharacter.body];
    [scrollViewSwitcherBody setMainControls];
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
    [self releaseComponents];
}
@end
