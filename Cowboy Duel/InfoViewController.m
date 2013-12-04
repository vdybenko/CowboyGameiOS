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
    __weak IBOutlet UILabel *lbMainText;
    __weak IBOutlet UIButton *btnMain;
    __weak IBOutlet UIButton *btnClose;
    
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

-(id)initWithText:(NSString*)text;
{
    self = [self initMainWithButton:NO];
    
    if (self) {
        [lbMainText setText:text];
    }
    return self;
}
-(id)initWithText:(NSString*)text withButtonTitle:(NSString*)title block:(InfoViewControllerBlock)block;
{
    self = [self initMainWithButton:YES];
    
    if (self) {
        [lbMainText setText:text];

        UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
        [btnMain setTitleByLabel:title withColor:buttonsTitleColor fontSize:24];
        blkFinish = block;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
