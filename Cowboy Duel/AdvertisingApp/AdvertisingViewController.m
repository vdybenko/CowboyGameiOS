//
//  AdvertisingViewController.m
//  Cowboy Duel 1
//
//  Created by Taras on 05.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdvertisingViewController.h"
#import "UIView+Dinamic_BackGround.h"

@interface AdvertisingViewController()

@end

@implementation AdvertisingViewController
@synthesize view;
@synthesize bodyView;
@synthesize titleView;
@synthesize webBody;
@synthesize _btnAppStore;

-(id)init;
{
    self = [super initWithNibName:@"AdvertisingViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        _collectionAppWrapper=[[CollectionAppWrapper alloc] init];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [bodyView setDinamicHeightBackground];
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
@end
