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

//added in hope for sound appearence
#import "StartViewController.h"


@interface ListOfItemsViewController : UIViewController <UITableViewDelegate, UIAlertViewDelegate, TableCellWithButton, FBRequestDelegate>{
    
    AccountDataSource *_playerAccount;
    GameCenterViewController *_gameCenterViewController;
    PlayersOnLineDataSource *_playersOnLineDataSource;
    StartViewController *startViewController;
    
    BOOL statusOnLine;
    
    IBOutlet UITableView * tableView;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnRefresh;
    IBOutlet UIButton *btnInvite;
    
    IBOutlet UIView *loadingView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *saloonTitle;
    
    NSIndexPath *_indexPath;
    
    IBOutlet UILabel *lbBackBtn;
    IBOutlet UILabel *lbInviteBtn;
    
    IBOutlet UIView *offLineBackGround;
    IBOutlet UIWebView *offLineText;
    
    NSTimer *updateTimer;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIButton *btnInvite;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIView *offLineBackGround;
@property (strong, nonatomic) IBOutlet UIWebView *offLineText;

@property (nonatomic) BOOL statusOnLine;
@property (strong, nonatomic)  NSTimer *updateTimer;

//@property (nonatomic, retain) IBOutlet UIView *viewGround;


- (id)initWithGCVC:(GameCenterViewController *)GCVC Account:(AccountDataSource *)userAccount OnLine:(BOOL) onLine;
- (void)updateServerList;
- (void)checkInternetStatus:(BOOL)status;
- (void)checkOnline;
-(void)startTableAnimation;

@end
