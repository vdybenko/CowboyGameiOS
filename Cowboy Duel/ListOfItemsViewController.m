//
//  ListOfItemsViewController.m
//  platfor
//
//  Created by Taras on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListOfItemsViewController.h"
#import "UIView+Dinamic_BackGround.h"
#import "Reachability.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#import "UIButton+Image+Title.h"
#import "ActiveDuelViewController.h"
#import "FavouritesViewController.h"
#import "FavouritesDataSource.h"
#import "TopPlayersViewController.h"
#import "StartViewController.h"
#import "UIViewController+popTO.h"

@interface ListOfItemsViewController ()
{
    __weak AccountDataSource *_playerAccount;
    PlayersOnLineDataSource *_playersOnLineDataSource;
    __weak AccountDataSource *oponentAccount;
    // AccountDataSource *playerAccount;
    BOOL statusOnLine;
            
    NSIndexPath *_indexPath;
    
    __weak IBOutlet UILabel *lbBackBtn;
    __weak IBOutlet UILabel *lbInviteBtn;
   
    __weak IBOutlet UILabel *lbFavoritesBtn;
    __weak IBOutlet UILabel *lbLeaderboardBtn;
    
    __weak IBOutlet UILabel *saloonTitle;
}

-(NSString *) convertToJSParametr:(NSString *) pValue;
-(NSString *) HTMLImage:(NSString *) pValue;
@end

@implementation ListOfItemsViewController
@synthesize tableView, btnBack, btnLeaderBoard, activityIndicator, loadingView,statusOnLine, updateTimer, btnFav;

#define SectionHeaderHeight 20

- (id)initWithAccount:(AccountDataSource *)userAccount OnLine:(BOOL) onLine;
{
    self = [self initWithNibName:nil bundle:nil];
    
	if (self) {
        _playerAccount = userAccount;
        statusOnLine=onLine;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [loadingView setHidden:NO];
    [activityIndicator startAnimating];
    
    _playersOnLineDataSource = [[PlayersOnLineDataSource alloc] initWithTable:tableView];
    _playersOnLineDataSource.delegate=self;
    _playersOnLineDataSource.statusOnLine = statusOnLine;
    
    tableView.delegate=self;
    tableView.dataSource=_playersOnLineDataSource;
    
    __block UIView *loadingViewB = loadingView;
    __block UIActivityIndicatorView *activityIndicatorB = activityIndicator;
    __block PlayersOnLineDataSource *_playersOnLineDataSourceB = _playersOnLineDataSource;

    [tableView setPullToRefreshHandler:^{
        [loadingViewB setHidden:NO];
        [activityIndicatorB startAnimating];
        _playersOnLineDataSourceB.statusOnLine = statusOnLine;
        [_playersOnLineDataSourceB reloadDataSource];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/ListOfItemsVC_refresh" forKey:@"page"]];
    }];
    
    saloonTitle.text = NSLocalizedString(@"SALYN", nil);
    
    saloonTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    saloonTitle.font = [UIFont fontWithName: @"DecreeNarrow" size:35];

    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    lbBackBtn.text = NSLocalizedString(@"BACK", nil);
    lbBackBtn.textColor = btnColor;
    lbBackBtn.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    lbInviteBtn.text = NSLocalizedString(@"INVITE", nil);
    lbInviteBtn.textColor = btnColor;
    lbInviteBtn.font = [UIFont fontWithName: @"DecreeNarrow" size:24];

    lbLeaderboardBtn.text = NSLocalizedString(@"LEAD", nil);
    lbLeaderboardBtn.textColor = btnColor;
    lbLeaderboardBtn.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    lbFavoritesBtn.text = NSLocalizedString(@"FavouritesTitle", nil);
    lbFavoritesBtn.textColor = btnColor;
    lbFavoritesBtn.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
}

- (void)viewDidUnload
{
   
    [self setBtnLeaderBoard:nil];
    lbFavoritesBtn = nil;
    lbLeaderboardBtn = nil;
    [self setBtnFav:nil];
    [super viewDidUnload];
    saloonTitle = nil;
    lbBackBtn = nil;
    lbInviteBtn = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    lbInviteBtn.enabled = FBSession.activeSession.isOpen;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshController];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:_playersOnLineDataSource selector:@selector(reloadDataSource) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/ListOfItemsVC" forKey:@"page"]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [updateTimer invalidate];
    updateTimer = nil;
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)releaseComponents
{
    tableView = nil;
    btnBack = nil;
    activityIndicator = nil;
    loadingView = nil;
    updateTimer = nil;
    _playerAccount = nil;
     _playersOnLineDataSource = nil;
    lbBackBtn = nil;
    lbInviteBtn = nil;
    saloonTitle = nil;
    updateTimer = nil;

}
#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(UIView *) tableView:(UITableView *)pTableView viewForHeaderInSection:(NSInteger)section
{
    @autoreleasepool {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pTableView.frame.size.width, 20)];
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.f;
}

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == ([pTableView numberOfRowsInSection:0]-1)) {
        [self inviteFriendsClick:Nil];
    }else{
        [self showOponentViewForIndexPath:indexPath duelButtonClick:NO];
    }
}

#pragma mark - Delegated methods

-(void)clickButton:(NSIndexPath *)indexPath;
{
    [self showOponentViewForIndexPath:indexPath duelButtonClick:YES];
}

-(void)showOponentViewForIndexPath:(NSIndexPath *)indexPath duelButtonClick:(BOOL)duelButtonClick
{
    SSServer *player;
    player=[_playersOnLineDataSource.serverObjects objectAtIndex:indexPath.row];
    
    oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer];
    [oponentAccount setAccountID:(player.serverName) ? [NSString stringWithString:player.serverName]:@""];
    [oponentAccount setAccountName:player.displayName];
    [oponentAccount setAccountLevel:[player.rank integerValue]];
    [oponentAccount setAccountWins:[player.duelsWin intValue]];
    [oponentAccount setAvatar:player.fbImageUrl];
    [oponentAccount setBot:player.bot];
    [oponentAccount setMoney:[player.money integerValue]];
    [oponentAccount setSessionID:(player.sessionId) ? [NSString stringWithString:player.sessionId]:@""];
    
//
    if (player.bot) {
        if (player.weapon)
            [oponentAccount setAccountAtackValue:player.weapon];
        else
            [oponentAccount setAccountAtackValue:0];
        if (player.defense)
            [oponentAccount setAccountDefenseValue:player.defense];
        else
            [oponentAccount setAccountDefenseValue:0];
        
        oponentAccount.visualViewCap = rand() % 4;
        oponentAccount.visualViewHead = rand() % 3;
        oponentAccount.visualViewBody = rand() % 3;
        oponentAccount.visualViewJackets = rand() % 3;
        oponentAccount.visualViewLegs = rand() % 3;
        oponentAccount.visualViewShoose = rand() % 2;
        oponentAccount.visualViewGuns = rand() % 3;
    }
    
    ProfileViewController *profileViewController = [[ProfileViewController alloc] initForOponent:oponentAccount andOpponentServer:player];
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:profileViewController animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                     }];
    
    if (duelButtonClick) {
        if ([oponentAccount isPlayerForPractice]) {
            [profileViewController startVisualLoading];
        }

        [profileViewController performSelector:@selector(duelButtonClick:) withObject:nil afterDelay:1.0];
    }
    profileViewController = nil;
}

#pragma mark - Interface methods

-(IBAction)backToMenu:(id)sender;
{
    [self.navigationController popViewControllerAnimated:YES];
    [self releaseComponents];
}

- (IBAction)inviteFriendsClick:(id)sender {
    if([[OGHelper sharedInstance] isAuthorized]){
        [loadingView setHidden:NO];
        [activityIndicator startAnimating];
        
        [[OGHelper sharedInstance] getFriendsHowDontUseAppDelegate:self];
    }else{
        [loadingView setHidden:NO];
        [activityIndicator startAnimating];
        
        [[StartViewController sharedInstance] clickLogin:Nil];
        
        [self backToMenu:Nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/ListOfItemsVC_invait" forKey:@"page"]];
}

-(void)refreshController;
{
    [loadingView setHidden:NO];
    [activityIndicator startAnimating];
    _playersOnLineDataSource.statusOnLine = statusOnLine;
    [_playersOnLineDataSource reloadDataSource];
}

-(void)didRefreshController
{
    [loadingView setHidden:YES];
    [activityIndicator stopAnimating];
    [tableView reloadData];
    [self.tableView refreshFinished];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FirstRunSalun_v2.2"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstRunSalun_v2.2"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if([_playersOnLineDataSource.serverObjects count]) [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_playersOnLineDataSource.serverObjects count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)startTableAnimation;
{
    int countOfCells=[_playersOnLineDataSource.arrItemsList count];
    int maxIndex;
    if (countOfCells<5) {
        maxIndex=countOfCells;
    }else {
        maxIndex=5;
    }
    for (int i=0; i<maxIndex; i++) {
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:i inSection:0];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableViewCell *cell = [tableView.visibleCells lastObject];
            [cell setHidden:YES];
            [tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationBottom];
        });
        [NSThread sleepForTimeInterval:0.25];
    }
}

#pragma mark FConnect Methods

- (void)request:(FBRequest *)request didLoad:(id)result {
    NSArray *friendToInvait = [[OGHelper sharedInstance] getFriendsHowDontUseAppRequest:request didLoad:result];
    [[OGHelper sharedInstance] apiDialogRequestsSendToNonUsers:friendToInvait];
    [loadingView setHidden:YES];
    [activityIndicator stopAnimating];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    //[[OGHelper sharedInstance] request:request didFailWithError:error];
    [loadingView setHidden:YES];
    [activityIndicator stopAnimating];
}
- (IBAction)leaderBoardTouch:(id)sender {
   TopPlayersViewController *topPlayersViewController =[[TopPlayersViewController alloc] initWithAccount:_playerAccount];
    [self.navigationController pushViewController:topPlayersViewController animated:YES];
    topPlayersViewController = nil;
}
- (IBAction)favoritListTouch:(id)sender {
    FavouritesViewController *favVC = [[FavouritesViewController alloc] initWithAccount:_playerAccount];
    [self.navigationController pushViewController:favVC animated:YES];
    favVC = nil;
}



@end
