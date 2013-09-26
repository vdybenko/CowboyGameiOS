//
//  ListOfItemsViewController.h
//  platfor
//
//  Created by Taras on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayersOnLineDataSource.h"
#import "GameCenterViewController.h"
#import "OCPromptView.h"
#import "UIScrollView+AH3DPullRefresh.h"
#import "StartViewController.h"

@interface ListOfItemsViewController : UIViewController <UITableViewDelegate, UIAlertViewDelegate, TableCellWithButton, FBRequestDelegate, MemoryManagement>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnFav;
@property (weak, nonatomic) IBOutlet UIButton *btnLeaderBoard;

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) BOOL statusOnLine;
@property (weak, nonatomic)  NSTimer *updateTimer;

- (id)initWithAccount:(AccountDataSource *)userAccount OnLine:(BOOL) onLine;
-(void)startTableAnimation;
-(void)refreshController;
-(void)didRefreshController;

@end
