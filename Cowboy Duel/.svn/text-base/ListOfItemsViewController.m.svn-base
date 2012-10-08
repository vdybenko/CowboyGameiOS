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


@interface ListOfItemsViewController (Private)
-(NSString *) convertToJSParametr:(NSString *) pValue;
-(NSString *) HTMLImage:(NSString *) pValue;
@end

@implementation ListOfItemsViewController
@synthesize tableView, btnInvite, btnBack, activityIndicator, loadingView,offLineBackGround,offLineText,statusOnLine, updateTimer;

#define SectionHeaderHeight 20

- (id)initWithGCVC:(GameCenterViewController *)GCVC Account:(AccountDataSource *)userAccount OnLine:(BOOL) onLine;
{
    self = [self initWithNibName:nil bundle:nil];
    
	if (self) {
        _gameCenterViewController = GCVC;
        _playerAccount = userAccount;
        statusOnLine=YES;
        
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
//            //iOS 5 new UINavigationBar custom background
//            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"text_navigationBar_background.png"] forBarMetrics: UIBarMetricsDefault];
//        } 
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [loadingView setHidden:NO];
    [activityIndicator startAnimating];
//    [btnInvite setEnabled:NO];

    // Do any additional setup after loading the view from its nib.
    
    _playersOnLineDataSource = [[PlayersOnLineDataSource alloc] initWithTable:tableView];
    _playersOnLineDataSource.delegate=self;
    
    tableView.delegate=self;
    tableView.dataSource=_playersOnLineDataSource;
    
    [tableView setPullToRefreshHandler:^{
        
        /**
         Note: Here you should deal perform a webservice request, CoreData query or
         whatever instead of this dummy code ;-)
         */
        [self refreshController];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:@"/saloon_refresh_click" forKey:@"event"]];

    }];
    
    [offLineText setOpaque:NO];
    [offLineText setBackgroundColor:[UIColor clearColor]];
    
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
        
    [btnRefresh setTitleByLabel:@"REFRESH"];
    [btnRefresh changeColorOfTitleByLabel:btnColor];
}

- (void)viewDidUnload
{
    btnInvite = nil;
    btnRefresh = nil;
    [super viewDidUnload];
    saloonTitle = nil;
    lbBackBtn = nil;
    lbInviteBtn = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self checkInternetStatus:statusOnLine];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshController];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [updateTimer invalidate];
    updateTimer = nil;
    [super viewWillDisappear:animated];
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //[updateTimer invalidate];
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Delegated methods
//table view

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(UIView *) tableView:(UITableView *)pTableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pTableView.frame.size.width, 20)];
    return headerView;
}


-(void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
    }
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.f;
}
#pragma mark - Delegated methods

-(void)clickButton:(NSIndexPath *)indexPath;
{
    CDPlayerOnLine *_player;    
    _player=[_playersOnLineDataSource.arrItemsList objectAtIndex:indexPath.row];
    AccountDataSource *oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer];
    [oponentAccount setAccountID:_player.dAuth];
    [oponentAccount setAccountName:_player.dNickName];
//    [oponentAccount setAccountLevel:1];
    [oponentAccount setAccountLevel:_player.dLevel];
    [oponentAccount setAccountWins:_player.dWinCount];
    [oponentAccount setAvatar:_player.dAvatar];

    [oponentAccount setMoney:_player.dMoney];
    
    DuelStartViewController *duelStartViewController = [[DuelStartViewController alloc]initWithAccount:_playerAccount andOpAccount:oponentAccount opopnentAvailable:NO andServerType:NO andTryAgain:NO];
    duelStartViewController.serverName = _player.dAuth;
    
    duelStartViewController.delegate = _gameCenterViewController;
    _gameCenterViewController.duelStartViewController = duelStartViewController;
    
    [self.navigationController pushViewController:duelStartViewController animated:YES];
    PlayerOnLineCell *cell = (PlayerOnLineCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell hideIndicatorConnectin];
    
    
    //    BOOL serverOnline = NO;
//    for (NSNetService *server in serverBrowser.servers) {
//        if ([_player.dPlayerIP isEqualToString:server.name]) serverOnline = YES;
//        NSLog(@"Servers online%@", server.name);
//    }
//    
//    [self.navigationController pushViewController:duelStartViewController animated:YES];
//    
//    if (serverOnline) {
//        //[_gameCenterViewController startClientWithName:_hostName];
//        [self.navigationController pushViewController:duelStartViewController animated:YES];
//    }
//    else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Server Offline", @"") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//        [alert show];
//        PlayerOnLineCell *cell = (PlayerOnLineCell *)[tableView cellForRowAtIndexPath:indexPath];
//        [cell hideIndicatorConnectin];
//
//    }
    
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
      //  [duelStartViewController setOponent:_player.dImg Label1:_player.dNickName Label1:_player.dMoney];
        [self.navigationController pushViewController:duelStartViewController animated:YES];
        duelStartViewController.delegate = _gameCenterViewController;
        _gameCenterViewController.duelStartViewController = duelStartViewController;
        [_gameCenterViewController stopServer];
        
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
- (IBAction)refreshBtnClick:(id)sender {
    [self refreshController];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/saloon_refresh_click_offline" forKey:@"event"]];
}
- (IBAction)inviteFriendsClick:(id)sender {
    if([[OGHelper sharedInstance] isAuthorized]){
        [loadingView setHidden:NO];
        [activityIndicator startAnimating];
        [btnInvite setEnabled:NO];
        
        [[OGHelper sharedInstance] getFriendsHowDontUseAppDelegate:self];
    }else{
        [[LoginViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusInvaitFriends];
        [[LoginViewController sharedInstance] fbLoginBtnClick:self];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/invait_friends" forKey:@"event"]];
}

-(void)refreshController;
{
    [loadingView setHidden:NO];
    [activityIndicator startAnimating];
    [btnInvite setEnabled:NO];
    [_playersOnLineDataSource reloadDataSource];
}

- (void)checkInternetStatus:(BOOL)status;
{
    if (statusOnLine) {
        [tableView setHidden:NO];
        [offLineBackGround setHidden:YES];
    }else {
        [offLineBackGround setDinamicHeightBackground];
        
        [offLineText loadHTMLString:NSLocalizedString(@"InternetAlertTextListOnline", @"") baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]; 
        
        [tableView setHidden:YES];
        [offLineBackGround setHidden:NO];
    }
}

- (void)checkOnline
{
    for (CDPlayerOnLine *player in _playersOnLineDataSource.arrItemsList) {
        NSString *convertString = player.dPlayerPublicIP;
        NSUInteger bufferCount = sizeof(char) * ([convertString length] + 1);
        char *utf8Buffer = malloc(bufferCount);
        [convertString getCString:utf8Buffer
                        maxLength:bufferCount 
                         encoding:NSUTF8StringEncoding];
        struct sockaddr_in hostAddress;
        memset(&hostAddress, 0, sizeof(hostAddress));
        hostAddress.sin_family = AF_INET;
        hostAddress.sin_len = sizeof(hostAddress);
        hostAddress.sin_port = ntohs(1111);
        hostAddress.sin_addr.s_addr = inet_addr(utf8Buffer);
        Reachability *reachability = [Reachability reachabilityWithAddress:&hostAddress];
        
        BOOL hostOnline = [reachability isReachable];
        player.dOnline = hostOnline;
        if(hostOnline) NSLog(@"Reachability %@", reachability);
    }
    [_playersOnLineDataSource setCellsHide:YES];
    [tableView reloadData];
        
    if (_playersOnLineDataSource.arrItemsList.count == 0) {
        [offLineBackGround setDinamicHeightBackground];
        
        [offLineText loadHTMLString:NSLocalizedString(@"AlertTextListOnlineIsEmpty", @"") baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
        
        [tableView setHidden:YES];
        [offLineBackGround setHidden:NO];
    }else {
            [tableView setHidden:NO];
            [offLineBackGround setHidden:YES];
    };
}

-(void)startTableAnimation;
{
    //

    
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

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    //    [delegate hideActivityIndicator];
    [[OGHelper sharedInstance] request:request didFailWithError:error];
    
    [loadingView setHidden:YES];
    [activityIndicator stopAnimating];
    [btnInvite setEnabled:YES];
    //        [self showMessage:[error debugDescription]];
}


@end

