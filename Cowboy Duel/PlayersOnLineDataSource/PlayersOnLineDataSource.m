//
//  ItemsDataSource.m
//  ScopeAndSequence
//
//  Created by Developer on 21.06.11.
//  Copyright 2011 Company Name. All rights reserved.
//

#import "PlayersOnLineDataSource.h"
#import "CDPlayerOnLine.h"
#import "ListOfItemsViewController.h"
#import "CustomNSURLConnection.h"
#import "Utils.h"
#import "AccountDataSource.h"
#import "UIImage+Save.h"
#import "SSConnection.h"
#import "SSServer.h"

@interface PlayersOnLineDataSource ()

@property (nonatomic) SSConnection *connection;
@property (nonatomic) BOOL startLoad;

@end 

@implementation PlayersOnLineDataSource
@synthesize arrItemsList, delegate, cellsHide, statusOnLine, serverObjects, connection, startLoad;


#pragma mark - Instance initialization

-(id) initWithTable:(UITableView *)pTable ;
 {
	self = [super init];
	
	if (!self) {
		return nil;
	}
     arrItemsList=[[NSMutableArray alloc] init];
     imageDownloadsInProgress=[[NSMutableDictionary alloc] init];
     _tableView=pTable;
     numberFormatter = [[NSNumberFormatter alloc] init];
     [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
     
     self.serverObjects = [[NSMutableArray alloc] init];
     
     topPlayersDataSource = [[StartViewController sharedInstance] topPlayersDataSource];
     [topPlayersDataSource reloadDataSource];
     self.connection = [SSConnection sharedInstance];
     self.connection.delegate = self;
     srand ([NSDate timeIntervalSinceReferenceDate]);
     //[self reloadRandomId];
	return self;
}


-(void) reloadDataSource;
{
    if (statusOnLine) {
        [self.connection sendData:@"" packetID:NETWORK_GET_LIST_ONLINE ofLength:sizeof(int)];
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(connectionTimeout) userInfo:nil repeats:NO];
        self.startLoad = YES;
    }else{
        self.startLoad = NO;
        [self addPracticeCell];
        ListOfItemsViewController *listOfItemsViewController = (ListOfItemsViewController *)delegate;
        [listOfItemsViewController didRefreshController];
    }
}

- (void) listOnlineResponse:(NSString *)jsonString
{
    self.startLoad = NO;
    NSError *jsonParseError;
    SBJSON *parser = [[SBJSON alloc] init];
    NSLog(@"jsonString: %@", jsonString);
    NSArray *servers = [parser objectWithString:jsonString error:&jsonParseError];
    
    if (!servers) {
        NSLog(@"JSON parse error: %@", jsonParseError);
        [self.serverObjects removeAllObjects];
    }
    else{
        NSLog(@"servers: %@", servers);
        for (NSDictionary *server in servers)
        {
            SSServer *serverObj = [[SSServer alloc] init];
            [serverObj setValuesForKeysWithDictionary:server];
            [self.serverObjects addObject:serverObj];
        }
    }
    [[AccountDataSource sharedInstance] refreshBotArray];
    [self addBotsForListCount:[self.serverObjects count]];
    [self addPracticeCell];
    ListOfItemsViewController *listOfItemsViewController = (ListOfItemsViewController *)delegate;
    [listOfItemsViewController didRefreshController];
}

-(void)connectionTimeout
{
    if (!self.startLoad)
    {
        
        return;
    }
    
    ListOfItemsViewController *listOfItemsViewController = (ListOfItemsViewController *)delegate;
    [listOfItemsViewController didRefreshController];
}

#pragma mark - Delegated methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PlayerOnLineCell* cell;
    cell = [tableView dequeueReusableCellWithIdentifier:[PlayerOnLineCell cellID]];
    
    if (!cell ) {
        cell = [PlayerOnLineCell cell];
        [cell initMainControls];
    }
    SSServer *player;
    
    player=[self.serverObjects objectAtIndex:indexPath.row];
    [cell populateWithPlayer:player];
    
    NSString *name=[[OGHelper sharedInstance ] getClearName:player.serverName];
    NSString *path=[NSString stringWithFormat:@"%@/icon_%@.png",[[OGHelper sharedInstance] getSavePathForList],name];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){  
        UIImage *image=[UIImage loadImageFullPath:path];
        [cell setPlayerIcon:image];
    }else {
        IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
        if (iconDownloader == nil) {
            [cell setPlayerIcon:[UIImage imageNamed:@"pv_photo_default.png"]];
            iconDownloader = [[IconDownloader alloc] init];
            
            iconDownloader.namePlayer=name;
            iconDownloader.indexPathInTableView = indexPath;
            iconDownloader.delegate = self;
            [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
            
            if (![player.fbImageUrl isEqualToString:@""])
            {
                [iconDownloader setAvatarURL:player.fbImageUrl];
                [iconDownloader startDownloadSimpleIcon];
            }else {
                if ([player.serverName rangeOfString:@"F"].location != NSNotFound){
                    [iconDownloader startDownloadFBIcon];
                }
            }
        }else {
            if (![cell.playerName.text isEqualToString:player.displayName]) {
                [cell setPlayerIcon:[UIImage imageNamed:@"pv_photo_default.png"]];
                
                NSString *name=[[OGHelper sharedInstance ] getClearName:player.serverName];
                iconDownloader.namePlayer=name;
                iconDownloader.indexPathInTableView = indexPath;
                iconDownloader.delegate = self;
                
               if (![player.fbImageUrl isEqualToString:@""])
                {
                    [iconDownloader setAvatarURL:player.fbImageUrl];
                    [iconDownloader startDownloadSimpleIcon];
                }else {
                    if ([player.serverName rangeOfString:@"F"].location != NSNotFound){
                        [iconDownloader startDownloadFBIcon];
                    }
                }
            }
            
        }
    }
    
    if ([topPlayersDataSource isPlayerInTop10:player.serverName]) {
        [cell setRibbonHide:NO];
    }else {
        [cell setRibbonHide:YES];
    }

    [cell.btnDuel addTarget:self action:@selector(invaiteWithMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"count %d",[self.serverObjects count]);
    return [self.serverObjects count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

#pragma mark CustomNSURLConnection handlers



#pragma mark IconDownloaderDelegate
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
        {
            PlayerOnLineCell *cell = (PlayerOnLineCell*)[_tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            [cell setPlayerIcon:iconDownloader.imageDownloaded];
        }
}

-(void) addBotsForListCount:(int)listcount
{
    AccountDataSource *player = [AccountDataSource sharedInstance];
    if([player.receivedBots count] == 0) return;
    DLog(@"player.receivedBots %@", player.receivedBots);
    switch (listcount) {
        case 0:{
            NSDictionary *serverDictionary = [player.receivedBots objectAtIndex:0];
            [self createServerForDictionary:serverDictionary];
            if([player.receivedBots count] == 1) return;
            serverDictionary = [player.receivedBots objectAtIndex:1];;
            [self createServerForDictionary:serverDictionary];
            if([player.receivedBots count] == 2) return;
            serverDictionary = [player.receivedBots objectAtIndex:2];
            [self createServerForDictionary:serverDictionary];
            break;
        }
        case 1:{
            NSDictionary *serverDictionary = [player.receivedBots objectAtIndex:0];
            [self createServerForDictionary:serverDictionary];
            if([player.receivedBots count] == 1) return;
            serverDictionary = [player.receivedBots objectAtIndex:1];
            [self createServerForDictionary:serverDictionary];
            break;
        }
        case 2:{
            NSDictionary *serverDictionary = [player.receivedBots objectAtIndex:0];
            [self createServerForDictionary:serverDictionary];
            
            break;
        }

        default:
            break;
    }
}


-(void)createServerForDictionary:(NSDictionary *)serverDictionary
{
    SSServer *serverObj = [[SSServer alloc] init];
    serverObj.displayName = [serverDictionary objectForKey:@"nickname"];
    serverObj.status = @"A";
    serverObj.money = ([[serverDictionary objectForKey:@"money"] intValue] >= 0) ? [serverDictionary objectForKey:@"money"]: [NSNumber numberWithInt:0];
    serverObj.serverName = [serverDictionary objectForKey:@"authentification"];
    serverObj.rank = [serverDictionary objectForKey:@"level"];
    serverObj.bot = YES;
    serverObj.duelsLost = [serverDictionary objectForKey:@"duels_lost"];
    serverObj.duelsWin = [serverDictionary objectForKey:@"duels_win"];
    serverObj.sessionId = [serverDictionary objectForKey:@"session_id"];
    [self.serverObjects addObject:serverObj];
}
#pragma mark Practice

-(void)addPracticeCell
{
    SSServer *serverObj = [[SSServer alloc] init];
    serverObj.displayName = NSLocalizedString(@"PRAC", @"");
    serverObj.status = @"A";
    serverObj.fbImageUrl = @"";
    serverObj.money = @1000;
    serverObj.serverName = @"";
    serverObj.rank = @1;
    serverObj.bot = NO;
    serverObj.duelsLost = @0;
    serverObj.duelsWin = @0;
    serverObj.sessionId = @"-1";
    [self.serverObjects addObject:serverObj];
}

-(void)practiceCellClick
{
    
}

#pragma mark -
-(void)invaiteWithMessage:(id __strong)sender;
{    
    PlayerOnLineCell *cell=(PlayerOnLineCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    [cell showIndicatorConnectin];
    [delegate clickButton:indexPath];
}
@end
