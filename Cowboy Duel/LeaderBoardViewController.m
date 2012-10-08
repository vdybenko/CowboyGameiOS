//
//  LeaderBoardViewController.m
//  Cowboy Duel 1
//
//  Created by AlexandrBezpalchuk on 11.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LeaderBoardViewController.h"
#import "UIView+Dinamic_BackGround.h"

@interface LeaderBoardViewController ()

@end

@implementation LeaderBoardViewController

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
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@", URL_LEADER_BOARD]];
                                     //@"http://m.platforma.webkate.com/app/?id=420"]];
    NSURLRequest *requestObject = [NSURLRequest requestWithURL:url];
    [leaderboardWebView loadRequest:requestObject];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated 
{
    [leadMainView setDinamicHeightBackground];
    
}

- (void)viewDidUnload
{
//    [leadMainView release];
    leadMainView = nil;
//    [leaderboardWebView release];
    leaderboardWebView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)exitLeaderBoard:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
