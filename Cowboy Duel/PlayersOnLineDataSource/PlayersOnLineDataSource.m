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
@synthesize arrItemsList, delegate, cellsHide, serverObjects, connection, startLoad;


#pragma mark - Instance initialization

-(id) initWithTable:(UITableView *)pTable;
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
     
     topPlayersDataSource = [[StartViewController sharedInstance] topPlayersDataSource];
     [topPlayersDataSource reloadDataSource];
     self.connection = [SSConnection sharedInstance];
     self.connection.delegate = self;
     srand ([NSDate timeIntervalSinceReferenceDate]);
	return self;
}

-(void) reloadDataSource;
{
	[self.connection sendData:@"" packetID:NETWORK_GET_LIST_ONLINE ofLength:sizeof(int)];
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(connectionTimeout) userInfo:nil repeats:NO];
    self.startLoad = YES;
}

- (void) listOnlineResponse:(NSString *)jsonString
{
    self.startLoad = NO;
    NSError *jsonParseError;
    SBJSON *parser = [[SBJSON alloc] init];
    NSLog(@"jsonString: %@", jsonString);
    NSArray *servers = [parser objectWithString:jsonString error:&jsonParseError];
    self.serverObjects = [[NSMutableArray alloc] init];
    
    if (!servers) {
        NSLog(@"JSON parse error: %@", jsonParseError);
    }
    else{
        NSLog(@"servers: %@", servers);
        for (NSDictionary *server in servers)
        {
            SSServer *serverObj = [[SSServer alloc] init];
            [serverObj setValuesForKeysWithDictionary:server];
            [self.serverObjects addObject:serverObj];
        }
        [_tableView reloadData];
    }
    
    [self addBotsForListCount:[self.serverObjects count]];
//    if (!self.serverObjects.count) {
//        [self addBotsForListCount:self.serverObjects.count];
//        SSServer *serverObj = [[SSServer alloc] init];
//        serverObj.displayName = @"Bot1";
//        serverObj.status = @"A";
//        serverObj.money = [NSNumber numberWithInt:123];
//        serverObj.serverName = @"Bot1";
//        serverObj.rank = [NSNumber numberWithInt:3];
//        serverObj.bot = YES;
//        [self.serverObjects addObject:serverObj];
//    }
    ListOfItemsViewController *listOfItemsViewController = (ListOfItemsViewController *)delegate;
    [listOfItemsViewController didRefreshController];
}

-(void)connectionTimeout
{
    if (!self.startLoad) return;
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
    switch (listcount) {
        case 0:{
            NSArray *randomIndexes = [self randomNumbersWithCount:3];
            DLog(@"%@", randomIndexes);
            NSDictionary *serverDictionary = [player.receivedBots objectAtIndex:[[randomIndexes objectAtIndex:0] intValue]];
            [self createServerForDictionary:serverDictionary];
            serverDictionary = [player.receivedBots objectAtIndex:[[randomIndexes objectAtIndex:1] intValue]];;
            [self createServerForDictionary:serverDictionary];
            serverDictionary = [player.receivedBots objectAtIndex:[[randomIndexes objectAtIndex:2] intValue]];
            [self createServerForDictionary:serverDictionary];
            break;
        }
        case 1:{
            NSArray *randomIndexes = [self randomNumbersWithCount:2];
            NSDictionary *serverDictionary = [player.receivedBots objectAtIndex:[[randomIndexes objectAtIndex:0] intValue]];
            [self createServerForDictionary:serverDictionary];
            serverDictionary = [player.receivedBots objectAtIndex:[[randomIndexes objectAtIndex:1] intValue]];
            [self createServerForDictionary:serverDictionary];
            break;
        }
        case 2:{
            NSArray *randomIndexes = [self randomNumbersWithCount:1];
            NSDictionary *serverDictionary = [player.receivedBots objectAtIndex:[[randomIndexes objectAtIndex:0] intValue]];
            [self createServerForDictionary:serverDictionary];
            
            break;
        }

        default:
            break;
    }
}

-(NSArray *)randomNumbersWithCount:(int)count
{
    AccountDataSource *player = [AccountDataSource sharedInstance];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i<count; i++) {
        BOOL numberNotAdd = YES;
        while (numberNotAdd) {
            BOOL containeNumber = NO;
            int randNumber = ((((double)rand())/RAND_MAX) * ([player.receivedBots count] - 1));
            for (NSNumber *randNumberTemp in array) {
                if([randNumberTemp intValue] == randNumber) containeNumber = YES;
            }
            if (!containeNumber) {
                [array addObject:[NSNumber numberWithInt:randNumber]];
                numberNotAdd = NO;
            }
        }
        
        
    }
    return array;
}

-(void)createServerForDictionary:(NSDictionary *)serverDictionary
{
    AccountDataSource *player = [AccountDataSource sharedInstance];
    
    SSServer *serverObj = [[SSServer alloc] init];
    serverObj.displayName = [serverDictionary objectForKey:@"nickname"];
    serverObj.status = @"A";
    serverObj.money = [serverDictionary objectForKey:@"money"];
    serverObj.serverName = [[player.listBotsOnline objectAtIndex:[self.serverObjects count]] objectForKey:@"authentification"];
    serverObj.rank = [serverDictionary objectForKey:@"level"];
    serverObj.bot = YES;
    serverObj.duelsLost = [serverDictionary objectForKey:@"duels_lost"];
    serverObj.duelsWin = [serverDictionary objectForKey:@"duels_win"];
    serverObj.sessionId = [serverDictionary objectForKey:@"session_id"];
    [self.serverObjects addObject:serverObj];

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
