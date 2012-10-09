//
//  TableViewController.m
//  Test
//
//  Created by Sobol on 19.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TableViewController.h"


@implementation TableViewController
@synthesize delegate;
-(id)initWithSession:(GKSession *)session withPeer:(NSMutableArray *)peer
{
    UIImageView *imView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert_b.png"]];
    [self.view addSubview:imView];
    //peerTable = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    peerTable = [[UITableView alloc] initWithFrame:CGRectMake(70, 80, 190, 150)];
    [self.view addSubview:peerTable];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 300, 40)];
    titleLabel.text = @"Device to invite";
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:titleLabel];
    
    canselButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [canselButton setFrame:CGRectMake(80, 240, 160, 50)];
    [canselButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [canselButton addTarget:self action:@selector(canselButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:canselButton];
    
//    peerTable.delegate = self;
//    peerTable.dataSource = self;
    peerList = peer;
    gameSession = session;
    [self.view setHidden:NO];

    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





- (void) didReceiveInvitation:(GKSession *)session fromPeer:(NSString *)participantID;
{
	NSString *str = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Incoming", @""), participantID];
    if (alertView.visible) {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
	alertView = [[UIAlertView alloc] 
				 initWithTitle:str
				 message:NSLocalizedString(@"acceptInv", @"") 
				 delegate:self 
				 cancelButtonTitle:NSLocalizedString(@"Decline", @"")
				 otherButtonTitles:nil];
	[alertView addButtonWithTitle:NSLocalizedString(@"Accept", @"")]; 
	[alertView show];
}




#pragma mark -
#pragma mark UIAlertViewDelegate Methods

// User has reacted to the dialog box and chosen accept or reject.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
        // User accepted.  Open the game screen and accept the connection.
        DLog(@"INVITATION_OK");
        [delegate didAcceptInvitation];
        [self.view setHidden:YES];
    }
             
	else 
        [delegate didDeclineInvitation];	
}
@end
