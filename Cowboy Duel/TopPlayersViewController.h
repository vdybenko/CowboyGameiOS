//
//  ListOfItemsViewController.h
//  platfor
//
//  Created by Taras on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"

@class TopPlayersDataSource;

@interface TopPlayersViewController : UIViewController <UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *saloonTitle;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIButton *btnFindMe;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIView *offLineBackGround;
@property (strong, nonatomic) IBOutlet UIWebView *offLineText;

@property (strong, nonatomic)  NSTimer *updateTimer;

- (id)initWithAccount:(AccountDataSource *)userAccount;
-(IBAction)findMe:(id)sender;

@end
