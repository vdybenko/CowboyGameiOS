//
//  FunPageViewController.m
//  Cowboy Duels
//
//  Created by Sergey Sobol on 18.12.12.
//
//

#import "FunPageViewController.h"
#import "StartViewController.h"
#import "UIButton+Image+Title.h"


@interface FunPageViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation FunPageViewController
@synthesize webView;
@synthesize backButton;

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
    UIColor *buttonsTitleColor = [UIColor colorWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    [self.backButton setTitleByLabel:@"BACK" withColor:buttonsTitleColor fontSize:24];
    self.backButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    NSString *urlAddress = URL_COMM_FB_PAGE;
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)releaseComponents
{
    webView = nil;
    backButton = nil;
}
#pragma mark 

- (IBAction)backButtonClick:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self releaseComponents];
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
}
@end
