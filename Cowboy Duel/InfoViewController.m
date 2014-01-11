//
//  InfoViewController.m
//  Bounty Hunter 1.2
//
//  Created by Taras on 02.12.13.
//
//

#import "InfoViewController.h"
#import "UIButton+Image+Title.h"
#import "UIView+Dinamic_BackGround.h"

@interface InfoViewController ()
{
    __weak IBOutlet UIView *vMain;
    __weak IBOutlet UIView *vContainer;
    __weak IBOutlet UILabel *lbMainText;
    __weak IBOutlet UIButton *btnMain;
    __weak IBOutlet UIButton *btnClose;
    __weak IBOutlet UIButton *btnBlackBack;
    UIInterfaceOrientation interfaceOrientation;
}
@end

@implementation InfoViewController
@synthesize blkFinish;

-(id)initMainWithButton:(BOOL)button;
{
    self = [super initWithNibName:@"InfoViewController" bundle:[NSBundle mainBundle]];
    
    if (self) {
        [self loadView];
        if (!button) {
            [btnMain setHidden:YES];
            CGRect frame = vMain.frame;
            frame.size.height = btnMain.frame.origin.y;
            vMain.frame = frame;
        }
        [vMain setDinamicHeightBackground];
    }
    return self;
}

-(id)initWithText:(NSString*)text interfaceOrientation:(UIInterfaceOrientation)pInterfaceOrientation;
{
    self = [self initMainWithButton:NO];
    
    if (self) {
        interfaceOrientation = pInterfaceOrientation;
        [lbMainText setText:text];
    }
    return self;
}
-(id)initWithText:(NSString*)text interfaceOrientation:(UIInterfaceOrientation)pInterfaceOrientation withButtonTitle:(NSString*)title block:(InfoViewControllerBlock)block;
{
    self = [self initMainWithButton:YES];
    
    if (self) {
        [lbMainText setText:text];

        UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
        [btnMain setTitleByLabel:title withColor:buttonsTitleColor fontSize:24];
        blkFinish = block;
        
        interfaceOrientation = pInterfaceOrientation;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    CGSize sizeMainScreen = [UIScreen mainScreen].bounds.size;
    
    CGRect frame = self.view.frame;
    if (interfaceOrientation==UIInterfaceOrientationPortrait) {
        vContainer.center = CGPointMake(sizeMainScreen.width/2, sizeMainScreen.height/2);
        frame.size = CGSizeMake(sizeMainScreen.width, sizeMainScreen.height);
    }else{
        vContainer.center = CGPointMake(sizeMainScreen.height/2, sizeMainScreen.width/2);
        frame.size = CGSizeMake(sizeMainScreen.height, sizeMainScreen.width);
    }
    self.view.frame = frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)pInterfaceOrientation{
    if (interfaceOrientation==UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationLandscapeRight;
    }
}

-(NSUInteger) supportedInterfaceOrientations{
    if (interfaceOrientation==UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskLandscape;
    }
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation{
    if (interfaceOrientation==UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationLandscapeRight;
    }
}

#pragma mark - IBAction
- (IBAction)btnBlackBackClick:(id)sender {
    [self btnCloseClick:Nil];
}
- (IBAction)btnCloseClick:(id)sender {
    [self.view removeFromSuperview];
}
- (IBAction)btnMainClick:(id)sender {
    if (blkFinish) {
        blkFinish();
    }
}

@end
