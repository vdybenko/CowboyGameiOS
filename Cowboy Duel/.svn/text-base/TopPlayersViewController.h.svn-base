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

@interface TopPlayersViewController : UIViewController <UITableViewDelegate>{
    
    AccountDataSource *_playerAccount;
    TopPlayersDataSource *_playersTopDataSource;
        
    IBOutlet UITableView * tableView;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnFindMe;
    IBOutlet UIView *loadingView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *saloonTitle;
    
    NSIndexPath *_indexPath;
    
    IBOutlet UIView *offLineBackGround;
    IBOutlet UIWebView *offLineText;
    
    NSTimer *updateTimer;
    
    NSMutableData *receivedData;
    NSMutableArray * arrItemsListForFindMe;

}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIButton *btnFindMe;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIView *offLineBackGround;
@property (strong, nonatomic) IBOutlet UIWebView *offLineText;

@property (strong, nonatomic)  NSTimer *updateTimer;

//@property (nonatomic, retain) IBOutlet UIView *viewGround;


- (id)initWithAccount:(AccountDataSource *)userAccount;
- (void)updateServerList;
-(IBAction)findMe:(id)sender;
-(void)getMyPositionInLeaderboard;

@end
