//
//  ListOfItemsViewController.m
//  platfor
//
//  Created by Taras on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopPlayersViewController.h"
#import "TopPlayersDataSource.h"
#import "UIButton+Image+Title.h"
#import "CustomNSURLConnection.h"

@interface TopPlayersViewController()
{
    AccountDataSource *_playerAccount;
    TopPlayersDataSource *_playersTopDataSource;
    
    NSIndexPath *_indexPath;
    
    NSMutableData *receivedData;
    NSMutableArray * arrItemsListForFindMe;
}

-(NSString *) convertToJSParametr:(NSString *) pValue;
-(NSString *) HTMLImage:(NSString *) pValue;
@end

@implementation TopPlayersViewController
@synthesize tableView, btnFindMe, btnBack, activityIndicator, loadingView,offLineBackGround,offLineText,saloonTitle;

static const char *RANK_TOP = BASE_URL"users/top_rank_on_interspace";


#define SectionHeaderHeight 20

- (id)initWithAccount:(AccountDataSource *)userAccount;
{
    self = [self initWithNibName:nil bundle:nil];
    
	if (self) {
        _playerAccount = userAccount;
        arrItemsListForFindMe=[[NSMutableArray alloc] init];
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
    
    _playersTopDataSource = [[TopPlayersDataSource alloc] initWithTable:tableView];
    [_playersTopDataSource reloadDataSource];
    _playersTopDataSource.delegate=self;
    
    tableView.delegate=self;
    tableView.dataSource=_playersTopDataSource;
    
    saloonTitle.text = NSLocalizedString(@"LEAD", nil);
    saloonTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    saloonTitle.font = [UIFont fontWithName: @"DecreeNarrow" size:35];

    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    [btnBack setTitleByLabel:@"BACK"];
    [btnBack changeColorOfTitleByLabel:btnColor];
    
    [btnFindMe setTitleByLabel:@"FIND ME"];
    [btnFindMe changeColorOfTitleByLabel:btnColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    saloonTitle = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([_playersTopDataSource.arrItemsList count]!=0) {
        [self.btnFindMe setEnabled:YES];
        [self.loadingView setHidden:YES];
        [self.activityIndicator stopAnimating];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self startTableAnimation];
    });
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)releaseComponents
{
    tableView = nil;
    btnFindMe = nil;
    btnBack = nil;
    activityIndicator = nil;
    loadingView = nil;
    offLineBackGround = nil;
    offLineText = nil;
    saloonTitle = nil;
    _playerAccount = nil;
    _playersTopDataSource = nil;
    receivedData = nil;
    arrItemsListForFindMe = nil;
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

#pragma mark - Private methods
-(void)getMyPositionInLeaderboard;
{
    [btnFindMe setEnabled:NO];
    [loadingView setHidden:NO];
    
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:RANK_TOP encoding:NSUTF8StringEncoding]]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:kTimeOutSeconds];
        [theRequest setHTTPMethod:@"POST"]; 
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    
    
    [dicBody setValue:[[AccountDataSource sharedInstance] accountID] forKey:@"authentification"];
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
	[theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
        CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
        if (theConnection) {
            receivedData = [[NSMutableData alloc] init];
        }
}

#pragma mark CustomNSURLConnection handlers

- (void)connectionDidFinishLoading:(CustomNSURLConnection *)connection1 {
    
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    DLog(@"TopPlayersViewController jsonString %@",jsonString);
    NSArray *responseObject = ValidateObject([jsonString JSONValue], [NSArray class]);
    jsonString = nil;
    for (NSDictionary *dic in responseObject) {
        CDTopPlayer *player=[[CDTopPlayer alloc] init];
        player.dPositionInList=[[dic objectForKey:@"rank"] intValue];
        player.dAuth=[dic objectForKey:@"authen"];
        player.dNickName=[dic objectForKey:@"nickname"];
        player.dMoney=[[dic objectForKey:@"money"] intValue];
        player.dLevel=[[dic objectForKey:@"level"] intValue];
        player.dPoints=[[dic objectForKey:@"points"] intValue];
        [arrItemsListForFindMe addObject: player];
        
        if ([player.dAuth isEqualToString:[AccountDataSource sharedInstance].accountID]) {
            [_playersTopDataSource setMyProfileIndex:player.dPositionInList-1];
        }
    }
    
    NSMutableArray *arrItemsList=[_playersTopDataSource arrItemsList];
  if ([arrItemsListForFindMe count]>0) {
    CDTopPlayer *firstPlayerInList=[arrItemsListForFindMe objectAtIndex:0];
    int rankOfFirstPlayer=firstPlayerInList.dPositionInList;
    if (rankOfFirstPlayer>[arrItemsList count]) {
        [arrItemsList addObjectsFromArray:arrItemsListForFindMe];
    }else {
        int limitIndex=rankOfFirstPlayer+[arrItemsListForFindMe count]-1;
        int indexOfFirstElement=rankOfFirstPlayer-1;
        if (limitIndex>=[arrItemsList count]) {
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(indexOfFirstElement, [arrItemsList count]-indexOfFirstElement)];
            [arrItemsList removeObjectsAtIndexes:indexes];
            [arrItemsList addObjectsFromArray:arrItemsListForFindMe];
        }else {
            [arrItemsList replaceObjectsInRange:NSMakeRange(indexOfFirstElement, [arrItemsListForFindMe count]) withObjectsFromArray:arrItemsListForFindMe];
        }
    }
    
    NSData *data= [NSKeyedArchiver archivedDataWithRootObject:arrItemsList];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"topPlayers"];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"topPlayers"];
    
    [tableView reloadData];
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:_playersTopDataSource.myProfileIndex inSection:0];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
  }
    [btnFindMe setEnabled:YES];
    [loadingView setHidden:YES];
}

- (void)connection:(CustomNSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(CustomNSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // inform the user
    DLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

#pragma mark - Interface methods

-(IBAction)backToMenu:(id)sender;
{
    [self.navigationController popViewControllerAnimated:YES];
    [self releaseComponents];
}
-(IBAction)findMe:(id)sender;
{
    if (_playersTopDataSource.myProfileIndex==-1) {
        int myIndexInArray=-1;
        for (CDTopPlayer *_player in _playersTopDataSource.arrItemsList) {
            if ([_player.dAuth isEqualToString:_playerAccount.accountID]) {
                myIndexInArray=[_playersTopDataSource.arrItemsList indexOfObject:_player];
                break;
            }
        }
        if (myIndexInArray!=-1) {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:myIndexInArray inSection:0];
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            TopPlayerCell  *cell = (TopPlayerCell*)[tableView cellForRowAtIndexPath:indexPath];
            
            [_playersTopDataSource setMyProfileIndex:myIndexInArray];
            if (cell.playerName.text) {
                [cell setCellStatus:TopPlayerCellStatusRed];
            }
        }else {
            [self getMyPositionInLeaderboard];
        }
    }else {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:_playersTopDataSource.myProfileIndex inSection:0];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/find_me" forKey:@"event"]];
    
}

-(IBAction)refreshController:(id)sender;
{
    [loadingView setHidden:NO];
    [activityIndicator startAnimating];
    [btnFindMe setEnabled:NO];
    [_playersTopDataSource reloadDataSource];
  [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:@"/refresh_top_players" forKey:@"event"]];
  
}

-(void)startTableAnimation
{
    int countOfCells=[_playersTopDataSource.arrItemsList count];
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
            [tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationBottom];
        });
        
        [NSThread sleepForTimeInterval:0.1];
    }
}
@end

