//
//  ListOfItemsViewController.m
//  platfor
//
//  Created by Taras on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListOfItemsViewController.h"
#import "DuelStartViewController.h"
#import "UIView+Dinamic_BackGround.h"
#import "Reachability.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#import "UIButton+Image+Title.h"

@interface ListOfItemsViewController ()
{
    AccountDataSource *_playerAccount;
    GameCenterViewController *_gameCenterViewController;
    PlayersOnLineDataSource *_playersOnLineDataSource;
    StartViewController *startViewController;
    
    BOOL statusOnLine;
            
    NSIndexPath *_indexPath;
    
    IBOutlet UILabel *lbBackBtn;
    IBOutlet UILabel *lbInviteBtn;
    
    IBOutlet UILabel *saloonTitle;
    
    NSTimer *updateTimer;
}

-(NSString *) convertToJSParametr:(NSString *) pValue;
-(NSString *) HTMLImage:(NSString *) pValue;
@end

@implementation ListOfItemsViewController
@synthesize tableView, btnInvite, btnBack, activityIndicator, loadingView,statusOnLine, updateTimer;

#define SectionHeaderHeight 20

- (id)initWithGCVC:(GameCenterViewController *)GCVC Account:(AccountDataSource *)userAccount OnLine:(BOOL) onLine;
{
    self = [self initWithNibName:nil bundle:nil];
    
	if (self) {
        _gameCenterViewController = GCVC;
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
    
    [tableView setPullToRefreshHandler:^{
        [self refreshController];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/saloon_refresh_click" forKey:@"event"]];

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    btnInvite = nil;
    saloonTitle = nil;
    lbBackBtn = nil;
    lbInviteBtn = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshController];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:_playersOnLineDataSource selector:@selector(reloadDataSource) userInfo:nil repeats:YES];
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

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(UIView *) tableView:(UITableView *)pTableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pTableView.frame.size.width, 20)];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self clickButton:indexPath];
}

#pragma mark - Delegated methods

-(void)clickButton:(NSIndexPath *)indexPath;
{
    SSServer *player;
    player=[_playersOnLineDataSource.serverObjects objectAtIndex:indexPath.row];

    AccountDataSource *oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer];
    [oponentAccount setAccountID:(player.serverName) ? [NSString stringWithString:player.serverName]:@""];
    [oponentAccount setAccountName:player.displayName];
    [oponentAccount setAccountLevel:[player.rank integerValue]];
    [oponentAccount setAccountWins:[player.duelsWin intValue]];
    [oponentAccount setAvatar:player.fbImageUrl];
    [oponentAccount setBot:player.bot];
    [oponentAccount setMoney:[player.money integerValue]];
    [oponentAccount setSessionID:(player.sessionId) ? [NSString stringWithString:player.sessionId]:@""];
    
    if (player.bot) {
        if (player.weapon) [oponentAccount setCurentIdWeapon:player.weapon];
        else [oponentAccount setCurentIdWeapon:-1];
        [oponentAccount loadAccountWeapon];
        if (player.defense) [oponentAccount setAccountDefenseValue:player.defense];
        else [oponentAccount setAccountDefenseValue:0];
    }

    if ([player.sessionId isEqualToString:@"-1"]) {
        [_playerAccount.finalInfoTable removeAllObjects];
        int randomTime = arc4random() % 6;
        
        TeachingViewController *teachingViewController = [[TeachingViewController alloc] initWithTime:randomTime andAccount:_playerAccount andOpAccount:oponentAccount];
        [self.navigationController pushViewController:teachingViewController animated:YES];
        
        SSConnection *connection = [SSConnection sharedInstance];
        [connection sendData:@"" packetID:NETWORK_SET_UNAVIBLE ofLength:sizeof(int)];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/duel_teaching" forKey:@"event"]];
        return;
    }

    DuelStartViewController *duelStartViewController = [[DuelStartViewController alloc]initWithAccount:_playerAccount andOpAccount:oponentAccount opopnentAvailable:NO andServerType:NO andTryAgain:NO];
    duelStartViewController.serverName = player.serverName;
    
    duelStartViewController.delegate = _gameCenterViewController;
    _gameCenterViewController.duelStartViewController = duelStartViewController;
    
    [self.navigationController pushViewController:duelStartViewController animated:YES];
    PlayerOnLineCell *cell = (PlayerOnLineCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell hideIndicatorConnectin];
    
// Не удалять!!!
//    _indexPath=indexPath;
//    UIAlertView *baseAlert= [[UIAlertView alloc] initWithTitle:@"Message" message:NSLocalizedString(@"BotMText", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"BotMCANS", nil) otherButtonTitles:NSLocalizedString(@"BotMBtn", nil),nil];
//    
//    if ([baseAlert respondsToSelector:@selector(setAlertViewStyle:)]) {
//        [baseAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
//        [baseAlert show];
//    }else {
//        OCPromptView *alert=[[OCPromptView alloc] initWithPrompt:@"Message" delegate:self cancelButtonTitle:NSLocalizedString(@"BotMCANS", nil) acceptButtonTitle:NSLocalizedString(@"BotMBtn", nil)];
//        [alert show];
//    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        CDPlayerOnLine *_player;    
        _player=[_playersOnLineDataSource.arrItemsList objectAtIndex:_indexPath.row];
        
        AccountDataSource *oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer];
        [oponentAccount setAccountName:@"TestName"];
        DuelStartViewController *duelStartViewController = [[DuelStartViewController alloc]initWithAccount:_playerAccount andOpAccount:oponentAccount opopnentAvailable:NO andServerType:NO andTryAgain:NO];
        [self.navigationController pushViewController:duelStartViewController animated:YES];
        duelStartViewController.delegate = _gameCenterViewController;
        _gameCenterViewController.duelStartViewController = duelStartViewController;
        
        NSString *convertString=_player.dAuth;
        NSUInteger bufferCount = sizeof(char) * ([convertString length] + 1);
        char *utf8Buffer = malloc(bufferCount);
        [convertString getCString:utf8Buffer 
                        maxLength:bufferCount 
                         encoding:NSUTF8StringEncoding];
        char *_hostName = strdup(utf8Buffer);
        
        if ([alertView respondsToSelector:@selector(setAlertViewStyle:)]) {
            [_gameCenterViewController startClientWithName:_hostName AndMessage:[[alertView textFieldAtIndex:0]text]]; 
        }else {
            NSString *entered = [(OCPromptView *)alertView enteredText];
            [_gameCenterViewController startClientWithName:_hostName AndMessage:entered];
        }
    }
    else
    {
        [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];  
    }
}

#pragma mark - Interface methods

-(IBAction)backToMenu:(id)sender;
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)inviteFriendsClick:(id)sender {
    if([[OGHelper sharedInstance] isAuthorized]){
        [loadingView setHidden:NO];
        [activityIndicator startAnimating];
        [btnInvite setEnabled:NO];
        
        [[OGHelper sharedInstance] getFriendsHowDontUseAppDelegate:self];
    }else{
        [[LoginAnimatedViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusInvaitFriends];
        [[LoginAnimatedViewController sharedInstance] loginButtonClick:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/invait_friends" forKey:@"event"]];
}

-(void)refreshController;
{
    //[_playersOnLineDataSource reloadRandomId];
    [loadingView setHidden:NO];
    [activityIndicator startAnimating];
    [btnInvite setEnabled:NO];
    _playersOnLineDataSource.statusOnLine = statusOnLine;
    [_playersOnLineDataSource reloadDataSource];
}

-(void)didRefreshController
{
    [loadingView setHidden:YES];
    [activityIndicator stopAnimating];
    [btnInvite setEnabled:YES];
    [tableView reloadData];
    [self.tableView refreshFinished];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FirstRunSalun_v2.2"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstRunSalun_v2.2"];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_playersOnLineDataSource.serverObjects count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    [btnInvite setEnabled:YES];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [[OGHelper sharedInstance] request:request didFailWithError:error];
    [loadingView setHidden:YES];
    [activityIndicator stopAnimating];
    [btnInvite setEnabled:YES];
}

@end
