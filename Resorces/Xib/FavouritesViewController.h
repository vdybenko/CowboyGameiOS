//
//  FavouritesViewController.h
//  Bounty Hunter
//
//  Created by AlexandrBezpalchuk on 07.02.13.
//
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"

@interface FavouritesViewController : UIViewController <UITableViewDelegate,MemoryManagement>

@property (strong, nonatomic) IBOutlet UIView *vOffLineBackGround;
@property (strong, nonatomic) IBOutlet UIWebView *wvOffLineText;
@property (weak, nonatomic) IBOutlet UITableView *tvFavTable;
@property (weak, nonatomic) IBOutlet UILabel *lbFavsTitle;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnOnLine;
@property (weak, nonatomic) IBOutlet UIButton *btnOffLine;
@property (weak, nonatomic) IBOutlet UIButton *leaderBoardBtn;


@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (id)initWithAccount:(AccountDataSource *)userAccount;
-(void) didRefreshController;
-(void) startTableAnimation;

- (IBAction)btnOfflineClicked:(id)sender;
@end
