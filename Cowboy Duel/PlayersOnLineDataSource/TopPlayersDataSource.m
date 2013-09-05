//
//  ItemsDataSource.m
//  ScopeAndSequence
//
//  Created by Developer on 21.06.11.
//  Copyright 2011 Company Name. All rights reserved.
//

#import "TopPlayersDataSource.h"
#import "TopPlayersViewController.h"
#import "CustomNSURLConnection.h"
#import "UIImage+Save.h"
#import "IconDownloader.h"

@interface TopPlayersDataSource()
{
    NSMutableData *receivedData;
    
    NSMutableDictionary *imageDownloadsInProgress;
    int myProfileIndex;
}

@end

@implementation TopPlayersDataSource
@synthesize arrItemsList,delegate,myProfileIndex;
@synthesize tableView;

//static const char *TOP_PLAYERS_URL =  BASE_URL"users/listview";
static const char *TOP_PLAYERS_URL =  "http://bidoncd.s3.amazonaws.com/top_board.json";


#pragma mark - Instance initialization

-(id) initWithTable:(UITableView *)pTable;
 {
	self = [super init];
	
	if (!self) {
		return nil;
	}
    arrItemsList=[[NSMutableArray alloc] init];
     imageDownloadsInProgress=[[NSMutableDictionary alloc] init];
     
     tableView=pTable;
     myProfileIndex=-1;
	return self;
}

-(void) reloadDataSource;
{
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"topPlayers"];
    NSMutableArray *testArr= [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    if ([Utils isNextHourBegin]||([testArr count]==0)) {

        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:TOP_PLAYERS_URL encoding:NSUTF8StringEncoding]]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:kTimeOutSeconds];
        
        CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
        if (theConnection) {
            //        [receivedData setLength:0];
            receivedData = [[NSMutableData alloc] init];
        } else {
        }
    }else {
        arrItemsList = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
        TopPlayersViewController *topPlayersViewController = (TopPlayersViewController *)delegate;
        [topPlayersViewController.btnFindMe setEnabled:YES];
        [topPlayersViewController.loadingView setHidden:YES];
        [topPlayersViewController.activityIndicator stopAnimating];
    }
}

-(void)releaseComponents
{
    arrItemsList = nil;
    receivedData = nil;
    tableView = nil;
    imageDownloadsInProgress = nil;
}
#pragma mark - Delegated methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TopPlayerCell* cell;
    cell = [tableView dequeueReusableCellWithIdentifier:[TopPlayerCell cellID]];
    
    if (!cell ) {
        cell = [TopPlayerCell cell];
        [cell initMainControls];
    }
    
    CDTopPlayer *player;

    player=[arrItemsList objectAtIndex:indexPath.row];
    [cell populateWithPlayer:player index:indexPath myIndex:myProfileIndex];
    
    [cell setPlayerIcon:nil];
//  Set Image of user
    NSString *name=[[OGHelper sharedInstance ] getClearName:player.dAuth];
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
            
            if (player.dAvatar&&[player.dAvatar length]&&![player.dAvatar isEqualToString:@"0"])
            {
                [iconDownloader setAvatarURL:player.dAvatar];
                [iconDownloader startDownloadSimpleIcon];
            }else {
                if ([player.dAuth rangeOfString:@"F"].location != NSNotFound){
                    [iconDownloader startDownloadFBIcon];
                }
            }
        }else {
            if (![cell.playerName.text isEqualToString:player.dNickName]) {
                [cell setPlayerIcon:[UIImage imageNamed:@"pv_photo_default.png"]];
                
                NSString *name=[[OGHelper sharedInstance ] getClearName:player.dAuth];
                iconDownloader.namePlayer=name;
                iconDownloader.indexPathInTableView = indexPath;
                iconDownloader.delegate = self;
                
                if (![player.dAvatar isEqualToString:@""])
                {
                    [iconDownloader setAvatarURL:player.dAvatar];
                    [iconDownloader startDownloadSimpleIcon];
                }else {
                    if ([player.dAuth rangeOfString:@"F"].location != NSNotFound){
                        [iconDownloader startDownloadFBIcon];
                    }
                }
            }
        }
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrItemsList count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

#pragma mark CustomNSURLConnection handlers


- (void)connectionDidFinishLoading:(CustomNSURLConnection *)connection1 {
   
    connection1 = nil;
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
//    DLog(@"PlayersOnLineDataSource jsonString %@",jsonString);
    NSArray *responseObject = ValidateObject([jsonString JSONValue], [NSArray class]);
    [arrItemsList removeAllObjects];
    for (NSDictionary *dic in responseObject) {
        CDTopPlayer *player=[[CDTopPlayer alloc] init];
        player.dPositionInList=[responseObject indexOfObject:dic]+1;
        player.dAuth=[dic objectForKey:@"authen"];
        player.dNickName=[dic objectForKey:@"nickname"];
        player.dMoney=[[dic objectForKey:@"money"] intValue];
        player.dLevel=[[dic objectForKey:@"level"] intValue];
        player.dPoints=[[dic objectForKey:@"points"] intValue];
        player.dAvatar=[dic objectForKey:@"avatar"];
        [arrItemsList addObject: player];
    }
    NSData *data= [NSKeyedArchiver archivedDataWithRootObject:arrItemsList];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"topPlayers"];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"topPlayers"];
    
    TopPlayersViewController *topPlayersViewController = (TopPlayersViewController *)delegate;
    [topPlayersViewController.btnFindMe setEnabled:YES];
    [topPlayersViewController.loadingView setHidden:YES];
    [tableView reloadData];
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
    TopPlayersViewController *topPlayersViewController = (TopPlayersViewController *)delegate;
    [topPlayersViewController.loadingView setHidden:YES];
    [topPlayersViewController.activityIndicator stopAnimating];
    [topPlayersViewController.tableView reloadData];
}

#pragma mark IconDownloaderDelegate
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                TopPlayerCell *cell = (TopPlayerCell*)[tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
                [cell setPlayerIcon:iconDownloader.imageDownloaded];
            });
            [imageDownloadsInProgress removeObjectForKey:indexPath];
            iconDownloader = nil;
        }
}
//
#pragma mark -

-(BOOL) isPlayerInTop10:(NSString*)authen;
{
    CDTopPlayer *player;
    if([arrItemsList count] == 0) return NO;
    for (int i=0; i<10; i++) {
        player=[arrItemsList objectAtIndex:i];
        if ([player.dAuth isEqualToString:authen]) {
            return YES;
        }
    }
    return NO;
}

@end

