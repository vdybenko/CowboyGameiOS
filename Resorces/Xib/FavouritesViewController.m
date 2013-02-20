//
//  FavouritesViewController.m
//  Bounty Hunter
//
//  Created by AlexandrBezpalchuk on 07.02.13.
//
//

#import "FavouritesViewController.h"
#import "FavouritesDataSource.h"
#import "UIButton+Image+Title.h"
#import "CustomNSURLConnection.h"
#import "StartViewController.h"
#import "SSConnection.h"
#import "DuelStartViewController.h"
#import "GameCenterViewController.h"
#import "CDTransaction.h"

@interface FavouritesViewController ()
{
    AccountDataSource *playerAccount;
    AccountDataSource *oponentAccount;
    FavouritesDataSource *favsDataSource;
    DuelStartViewController *duelStartViewController;
    
    UIView *vMessage;
}
@end

@implementation FavouritesViewController

@synthesize lbFavsTitle, btnBack, vOffLineBackGround, wvOffLineText, tvFavTable, btnOffLine, btnOnLine;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithAccount:(AccountDataSource *)userAccount
{
    self = [self initWithNibName:nil bundle:nil];
    
	if (self) {
//        playerAccount = userAccount;
//        arrItemsListForFindMe=[[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.loadingView setHidden:NO];
    [self.activityIndicator startAnimating];
    
    favsDataSource = [[StartViewController sharedInstance] favsDataSource];
//    [_favsDataSource reloadDataSource];
    favsDataSource.tableView = tvFavTable;
    favsDataSource.typeOfTable = ONLINE;
    favsDataSource.delegate=self;
    
    SSConnection *conn = [SSConnection sharedInstance];
    conn.delegate = favsDataSource;
//    
    tvFavTable.delegate=self;
    tvFavTable.dataSource=favsDataSource;
    [favsDataSource reloadDataSource];
    
    lbFavsTitle.text = NSLocalizedString(@"FavouritesTitle", nil);
    lbFavsTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    lbFavsTitle.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    [btnBack setTitleByLabel:@"BACK"];
    [btnBack changeColorOfTitleByLabel:btnColor];
    
    [btnOnLine setTitleByLabel:@"OnLine"];
    [btnOnLine changeColorOfTitleByLabel:btnColor];
    
    [btnOffLine setTitleByLabel:@"OffLine"];
    [btnOffLine changeColorOfTitleByLabel:btnColor];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    if ([_favsDataSource.arrItemsList count]!=0) {
//        [self.loadingView setHidden:YES];
//        [self.activityIndicator stopAnimating];
//    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self startTableAnimation];
//    });
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTvFavTable:nil];
    [self setLbFavsTitle:nil];
    [self setBtnBack:nil];
    [self setBtnOnLine:nil];
    [self setBtnOffLine:nil];
    [super viewDidUnload];
}

- (void) releaseComponents
{
    tvFavTable = nil;
    lbFavsTitle = nil;
    btnBack = nil;
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

#pragma mark -
#pragma mark IBActions:

- (IBAction)btnBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self releaseComponents];
}

- (IBAction)btnOnlineClicked:(id)sender {
    
    if (favsDataSource.typeOfTable != ONLINE) {
        favsDataSource.typeOfTable = ONLINE;
        [favsDataSource reloadDataSource];
        [favsDataSource setCellsHide:YES];
        [tvFavTable reloadData];
    }

}

- (IBAction)btnOfflineClicked:(id)sender {
    if (favsDataSource.typeOfTable != OFFLINE) {
        favsDataSource.typeOfTable = OFFLINE;
        
        [favsDataSource reloadDataSource];
        [favsDataSource setCellsHide:YES];
        
        [tvFavTable reloadData];
    }
}

//call to duel:
-(void)clickButton:(NSIndexPath *)indexPath;
{
    CDFavPlayer *player;
    player = [favsDataSource.arrItemsList objectAtIndex:indexPath.row];
    
    oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer];
    [oponentAccount setAccountID:player.dAuth];
    [oponentAccount setAccountName:player.dNickName];
    [oponentAccount setAccountLevel:player.dLevel];
    [oponentAccount setAvatar:player.dAvatar];
    [oponentAccount setBot:player.dBot];
    [oponentAccount setMoney:player.dMoney];
    [oponentAccount setSessionID:player.dSessionId];

    NSLog(@"\n%@\n%@", oponentAccount.accountName, playerAccount.accountName);
    
    duelStartViewController = [[DuelStartViewController alloc]initWithAccount:[AccountDataSource sharedInstance] andOpAccount:oponentAccount opopnentAvailable:NO andServerType:NO andTryAgain:NO];
    //duelStartViewController.serverName = playerAccount.accountID;
    
    GameCenterViewController *gameCenterViewController = [GameCenterViewController sharedInstance:[AccountDataSource sharedInstance] andParentVC:self];
    duelStartViewController.delegate = gameCenterViewController;
    gameCenterViewController.duelStartViewController = duelStartViewController;
    
    if (!oponentAccount.bot) {
        const char *name = [playerAccount.accountID cStringUsingEncoding:NSUTF8StringEncoding];
        SSConnection *connection = [SSConnection sharedInstance];
        [connection sendData:(void *)(name) packetID:NETWORK_SET_PAIR ofLength:sizeof(char) * [playerAccount.accountID length]];
    }
    else {
        SSConnection *connection = [SSConnection sharedInstance];
        [connection sendData:@"" packetID:NETWORK_SET_UNAVIBLE ofLength:sizeof(int)];
        int randomTime = arc4random() % 6;
        ActiveDuelViewController *activeDuelViewController = [[ActiveDuelViewController alloc] initWithTime:randomTime Account:[AccountDataSource sharedInstance] oponentAccount:oponentAccount];
        [self.navigationController pushViewController:activeDuelViewController animated:YES];
    }

}

//poke oponnent:
-(void)clickButtonPoke:(NSIndexPath *)indexPath;
{
    CDFavPlayer *player;
    player = [favsDataSource.arrItemsList objectAtIndex:indexPath.row];
    [[StartViewController sharedInstance] sendMessageForPush:@"POKE"
                                                    withType:PUSH_NOTIFICATION_POKE
                                                   forPlayer:player.dNickName
                                                      withId:player.dAuth
                                                     ];
    
    NSString *message = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"PokenMessage", @""),player.dNickName];
    [self performSelector:@selector(showMessage:) withObject:message];
    [self performSelector:@selector(hideMessage) withObject:self afterDelay:3.8];
    
}
//steal money:
-(void)clickButtonSteal: (NSIndexPath *)indexPath;
{
    playerAccount = [AccountDataSource sharedInstance];
    
    CDFavPlayer *player;
    player = [favsDataSource.arrItemsList objectAtIndex:indexPath.row];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    oponentAccount = [[AccountDataSource alloc] initWithLocalPlayer];
    [oponentAccount setAccountID:player.dAuth];
    [oponentAccount setAccountName:player.dNickName];
    [oponentAccount setAccountLevel:player.dLevel];
    [oponentAccount setAvatar:player.dAvatar];
    [oponentAccount setBot:player.dBot];
    [oponentAccount setMoney:player.dMoney];
    [oponentAccount setSessionID:player.dSessionId];

    int moneyExch = (oponentAccount.money<10)?1:oponentAccount.money/10.0;
    NSString *message = [[NSString alloc] initWithFormat:@"%@: $%d",NSLocalizedString(@"StolenMess", @""),moneyExch];

    [self performSelector:@selector(showMessage:) withObject:message];
    [self performSelector:@selector(hideMessage) withObject:self afterDelay:3.8];
    
    NSLog(@"\n%@\n%@", oponentAccount.accountName, playerAccount.accountName);
    
    CDTransaction *transaction = [[CDTransaction alloc] init];
    
    transaction.trMoneyCh = [NSNumber numberWithInt:moneyExch];
    transaction.trType = [NSNumber numberWithInt:1];
    transaction.trDescription = [[NSString alloc] initWithFormat:@"Steal"];
    transaction.trLocalID = [NSNumber numberWithInt:[playerAccount increaseGlNumber]];       
    transaction.trOpponentID = [NSString stringWithString:(oponentAccount.accountID) ? [NSString stringWithString:oponentAccount.accountID]:@""];
    [playerAccount.transactions addObject:transaction];
    
    CDTransaction *opponentTransaction = [CDTransaction new];
    [opponentTransaction setTrDescription:[NSString stringWithString:transaction.trDescription]];
    [opponentTransaction setTrType:[NSNumber numberWithInt:-1]];
    [opponentTransaction setTrMoneyCh:[NSNumber numberWithInt:-[transaction.trMoneyCh intValue]]];
    opponentTransaction.trOpponentID = [NSString stringWithString:(playerAccount.accountID) ? [NSString stringWithString:playerAccount.accountID]:@""];
    opponentTransaction.trLocalID = [NSNumber numberWithInt:-1];
    [oponentAccount.transactions addObject:opponentTransaction];

    [playerAccount saveTransaction];
    playerAccount.money += moneyExch;
    [playerAccount saveMoney];
    [userDef synchronize];
    
    [playerAccount sendTransactions:playerAccount.transactions];
    if (oponentAccount.bot) [oponentAccount sendTransactions:oponentAccount.transactions];

    [[StartViewController sharedInstance] modifierUser:playerAccount];
    if(oponentAccount.bot) [[StartViewController sharedInstance] modifierUser:oponentAccount];
    

}

-(void)didRefreshController
{
    [self.loadingView setHidden:YES];
    [self.activityIndicator stopAnimating];
    [tvFavTable reloadData];
}

#pragma mark -
-(void)startTableAnimation
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        int countOfCells=[favsDataSource.arrItemsList count];
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
                if ([tvFavTable.visibleCells count]>i) {
                    UITableViewCell *cell = [tvFavTable.visibleCells lastObject];
                    [cell setHidden:YES];
                    
                    UITableViewRowAnimation type;
                    if (favsDataSource.typeOfTable == ONLINE)
                    {
                        type = UITableViewRowAnimationRight;
                    }else{
                        type = UITableViewRowAnimationLeft;
                    }
                    
                    [self.tvFavTable beginUpdates];
                    
                    [favsDataSource setCellsHide:NO];
                    
                    [tvFavTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:type];
                    
                    [self.tvFavTable endUpdates];
                }
            });
            [NSThread sleepForTimeInterval:0.12];
        }
    });
}

-(void)showMessage: (NSString *)message;
{
    vMessage=[[UIView alloc] initWithFrame:CGRectMake(12, -40, 290, 40)];
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 270, 20)];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:16.f]];
    UIColor *brownColor=[UIColor colorWithRed:0.38 green:0.267 blue:0.133 alpha:1];
    [label setTextColor:brownColor];
    [label setBackgroundColor:[UIColor clearColor]];
    
    
    [label setText:message];
    [vMessage addSubview:label];
    
    [self.view addSubview:vMessage];
    [vMessage setDinamicHeightBackground];
    
    [UIView animateWithDuration:0.6f
                     animations:^{
                         CGRect frame=vMessage.frame;
                         frame.origin.y += frame.size.height+5;
                         vMessage.frame = frame;
                     }];
}

-(void)hideMessage;
{
    [UIView animateWithDuration:0.6f
                     animations:^{
                         CGRect frame=vMessage.frame;
                         frame.origin.y -= frame.size.height+5;
                         vMessage.frame = frame;
                     }
                     completion:^(BOOL finished) {
						 [vMessage removeFromSuperview];
					 }];
    
}

@end