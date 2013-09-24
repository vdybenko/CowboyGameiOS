//
//  ItemsDataSource.m
//  ScopeAndSequence
//
//  Created by Developer on 21.06.11.
//  Copyright 2011 Company Name. All rights reserved.
//

#import "PlayersOnLineDataSource.h"
#import "ListOfItemsViewController.h"
#import "CustomNSURLConnection.h"
#import "Utils.h"
#import "AccountDataSource.h"
#import "UIImage+Save.h"
#import "SSConnection.h"
#import "SSServer.h"
#import "PracticeCell.h"


@interface PlayersOnLineDataSource ()

@end 

@implementation PlayersOnLineDataSource
@synthesize arrItemsList, delegate, statusOnLine;


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

     srand ([NSDate timeIntervalSinceReferenceDate]);
     //[self reloadRandomId];
	return self;
}


-(void) reloadDataSource;
{
    if ([[StartViewController sharedInstance] connectedToWiFi]) {
        self.isNeedFavCheck = YES;
        [self refreshListOnline];
    }else{
        [self.serverObjects removeAllObjects];
        [self addPracticeCell];
        ListOfItemsViewController *listOfItemsViewController = (ListOfItemsViewController *)delegate;
        [listOfItemsViewController didRefreshController];
    }
}

#pragma mark - Delegated methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == ([tableView numberOfRowsInSection:0]-1)) {
//        Invite
        PracticeCell *cell = [tableView dequeueReusableCellWithIdentifier:[PracticeCell cellID]];
        if (!cell ) {
            cell = [PracticeCell cell];
            [cell initMainControls];
        }
        [cell cellForPractice:NO];
        return cell;
    }else if (indexPath.row == ([tableView numberOfRowsInSection:0]-2)) {
//        Practice
        PracticeCell *cell = [tableView dequeueReusableCellWithIdentifier:[PracticeCell cellID]];
        if (!cell ) {
            cell = [PracticeCell cell];
            [cell initMainControls];
        }
        [cell.btnDuel addTarget:self action:@selector(invaiteWithMessage:) forControlEvents:UIControlEventTouchUpInside];
        [cell cellForPractice:YES];
        return cell;
    }else{
        PlayerOnLineCell* cell;
        cell = [tableView dequeueReusableCellWithIdentifier:[PlayerOnLineCell cellID]];
        
        if (!cell ) {
            cell = [PlayerOnLineCell cell];
            [cell initMainControls];
        }
        SSServer *player;
        
        player=[self.serverObjects objectAtIndex:indexPath.row];
//        [self checkServerForFavorite:player];
        [cell populateWithPlayer:player];
        [cell setPlayerIcon:nil];
        
        NSString *name=[[OGHelper sharedInstance ] getClearName:player.serverName];
        NSString *path=[NSString stringWithFormat:@"%@/icon_%@.png",[[OGHelper sharedInstance] getSavePathForList],name];
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){  
            UIImage *image=[UIImage loadImageFullPath:path];
            [cell setPlayerIcon:image];
        }else
        {
            IconDownloader *iconDownloader;// = [imageDownloadsInProgress objectForKey:indexPath];
            
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
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.serverObjects count]+1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

#pragma mark ListOnlineDataSource
- (void)listOnlineResponse:(NSString *)jsonString{
    [super listOnlineResponse:jsonString];
    [self addPracticeCell];
    ListOfItemsViewController *listOfItemsViewController = (ListOfItemsViewController *)delegate;
    [listOfItemsViewController didRefreshController];
}

-(void)connectionTimeoutListOnline
{
    [super connectionTimeoutListOnline];
    
    if (![self.serverObjects count]) {
        [self addPracticeCell];
    }
    
    ListOfItemsViewController *listOfItemsViewController = (ListOfItemsViewController *)delegate;
    [listOfItemsViewController didRefreshController];
}

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

#pragma mark Practice

-(void)addPracticeCell
{
    SSServer *serverObj = [[SSServer alloc] init];
    serverObj.displayName = NSLocalizedString(@"PRAC", @"");
    serverObj.status = @"A";
    serverObj.fbImageUrl = @"";
    serverObj.money = @1000;
    serverObj.serverName = @"";
    serverObj.rank = @2;
    serverObj.bot = NO;
    serverObj.duelsLost = @0;
    serverObj.duelsWin = @0;
    serverObj.sessionId = @"-1";
    serverObj.defense = 0;
    serverObj.weapon = 0;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.displayName == %@", NSLocalizedString(@"PRAC", @"")];
    if (![[self.serverObjects filteredArrayUsingPredicate:predicate] count]) [self.serverObjects addObject:serverObj];
}


#pragma mark -
-(void)invaiteWithMessage:(id __strong)sender;
{
    while (![sender isKindOfClass:[UITableViewCell class]]) {
        sender = [sender superview];
    };
    PlayerOnLineCell *cell=(PlayerOnLineCell *)sender;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    [delegate clickButton:indexPath];
}


@end
