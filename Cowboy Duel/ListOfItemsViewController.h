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
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIButton *btnInvite;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) BOOL statusOnLine;
@property (strong, nonatomic)  NSTimer *updateTimer;

- (id)initWithGCVC:(GameCenterViewController *)GCVC Account:(AccountDataSource *)userAccount OnLine:(BOOL) onLine;
-(void)startTableAnimation;
-(void)refreshController;
-(void)didRefreshController;

@end
