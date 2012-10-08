//
//  TableViewController.h
//  Test
//
//  Created by Sobol on 19.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DuelViewController.h"


@interface TableViewController : UIViewController<DuelViewControllerDelegate> {
    UITableView *peerTable;
    int count;
    NSMutableArray *peerList;
    GKSession *gameSession;
    UIAlertView *alertView;
    UIButton *canselButton;
    
}
@property(unsafe_unretained)id<DuelViewControllerDelegate> delegate;

-(id)initWithSession:(GKSession *)session
            withPeer:(NSMutableArray *)peer;

//-(void)showTable;

@end
