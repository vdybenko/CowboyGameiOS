//
//  AdvertisingNewViewController.m
//  Cowboy Duels
//
//  Created by Sergey Sobol on 05.11.12.
//
//

#import "AdvertisingNewViewController.h"
#import "UIView+Dinamic_BackGround.h"

@interface AdvertisingNewViewController ()


@end

@implementation AdvertisingNewViewController
@synthesize advertisingNeed;
-(id)initWithNib
{
    self = [self initWithNibName:@"AdvertisingNewViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
         collectionAppWrapper=[[CollectionAppWrapper alloc] init];
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.bodyView setDinamicHeightBackground];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark interface metods

- (IBAction)btnAppStoreClick:(id)sender {
     [CollectionAppWrapper runAppStore:appCurentForShow.cdAppStoreURL];
}

-(IBAction)btnSkipClick:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload {
    [self setBodyView:nil];
    [self setWebBody:nil];
    [self setBtnAppStore:nil];
    [self setTitleView:nil];
    [super viewDidUnload];
}
@end
