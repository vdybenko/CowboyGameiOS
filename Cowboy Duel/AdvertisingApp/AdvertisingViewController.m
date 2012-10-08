//
//  AdvertisingViewController.m
//  Cowboy Duel 1
//
//  Created by Taras on 05.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdvertisingViewController.h"
#import "UIView+Dinamic_BackGround.h"

@implementation AdvertisingViewController

-(id)init;
{
    self = [super initWithNibName:@"AdvertisingViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        _collectionAppWrapper=[[CollectionAppWrapper alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [bodyView setDinamicHeightBackground];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark interface metods
 
-(IBAction)btnAppStoreClick:(id)sender;
{
    [CollectionAppWrapper runAppStore:_AppCurentForShow.cdAppStoreURL];
}

-(IBAction)btnSkipClick:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) setInformationAboutApp;
{
    
}
@end
