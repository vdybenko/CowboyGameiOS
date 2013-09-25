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

@interface TopPlayersViewController : UIViewController <UITableViewDelegate,MemoryManagement>

@property (weak, nonatomic) IBOutlet UILabel *saloonTitle;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnFindMe;
@property (weak, nonatomic) IBOutlet UIButton *favoritesBtn;

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIView *offLineBackGround;
@property (weak, nonatomic) IBOutlet UIWebView *offLineText;

- (id)initWithAccount:(AccountDataSource *)userAccount;
-(IBAction)findMe:(id)sender;

@end
