//
//  FavouritesDataSource.m
//  Bounty Hunter
//
//  Created by AlexandrBezpalchuk on 07.02.13.
//
//

#import "FavouritesDataSource.h"
#import "FavouritesViewController.h"
#import "CustomNSURLConnection.h"
#import "UIImage+Save.h"
#import "UIButton+Image+Title.h"
#import "IconDownloader.h"

@interface FavouritesDataSource()
{
    NSMutableData *receivedData;
    
    NSMutableDictionary *imageDownloadsInProgress;
}
@end

@implementation FavouritesDataSource

@synthesize arrItemsList, tableView, delegate;

static const char *FAV_PLAYERS_URL = BASE_URL"users/get_favorites";
static NSString  *const URL_ADD_FAVORITE = @BASE_URL"users/add_to_favorites";
static NSString  *const URL_DELETE_FAVORITE = @BASE_URL"users/delete_favorites";

#define FAVORITES_LIST @"FAVORITES_LIST"

#pragma mark - Instance initialization

-(id) initWithTable:(UITableView *)pTable;
{
	self = [super init];
	
	if (!self) {
		return nil;
	}
    arrItemsList=[[NSMutableArray alloc] init];
    imageDownloadsInProgress=[[NSMutableDictionary alloc] init];
    
    self.serverObjects = [[NSMutableArray alloc] init];
    tableView=pTable;
	return self;
}

-(void) reloadDataSource;
{
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"favPlayers"];
    NSMutableArray *testArr= [NSKeyedUnarchiver unarchiveObjectWithData:data1];

    //if ([testArr count]==0)
    if (1==1)
    {
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:FAV_PLAYERS_URL encoding:NSUTF8StringEncoding]]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:kTimeOutSeconds];
        
        [theRequest setHTTPMethod:@"POST"];
        NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                               [[AccountDataSource sharedInstance] accountID],@"authen",
                               nil];
        
        NSString *stBody=[Utils makeStringForPostRequest:dicBody];
        [theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]];

        NSLog(@"\nFavs request : %@", stBody);
        
        CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if (theConnection) {
            receivedData = [[NSMutableData alloc] init];
            [self refreshListOnline];
            
        } else {
        
        }
    }else {
        arrItemsList = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
        FavouritesViewController *favsViewController = (FavouritesViewController *)delegate;
        [favsViewController.loadingView setHidden:YES];
        [favsViewController.activityIndicator stopAnimating];
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
	FavouritesCell* cell;
    cell = [tableView dequeueReusableCellWithIdentifier:[FavouritesCell cellID]];
    
    if (!cell ) {
        cell = [FavouritesCell cell];
        [cell initMainControls];
    }
    
    CDFavPlayer *player;
    
    player=[arrItemsList objectAtIndex:indexPath.row];
    BOOL statusOnline = [self isOnline:player];
    [cell populateWithPlayer:player index:indexPath status: statusOnline];
    
    [cell setPlayerIcon:nil];
    
    if (statusOnline) {
        [cell.btnGetHim addTarget:self action:@selector(invaiteWithMessage:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnGetHim changeTitleByLabel:@"DUEL"];
    }else{
        [cell.btnGetHim removeTarget:self action:@selector(invaiteWithMessage:) forControlEvents:UIControlEventTouchUpInside ];
        [cell.btnGetHim changeTitleByLabel:@"Poke"];
    }
    
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
            if (![cell.lbPlayerName.text isEqualToString:player.dNickName]) {
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

    NSArray *responseObject = ValidateObject([jsonString JSONValue], [NSArray class]);
    [arrItemsList removeAllObjects];
    for (NSDictionary *dic in responseObject) {
        CDFavPlayer *player=[[CDFavPlayer alloc] init];
        player.dAuth=[dic objectForKey:@"authen"];
        player.dNickName=[dic objectForKey:@"nickname"];
        player.dMoney=[[dic objectForKey:@"money"] intValue];
        player.dLevel=[[dic objectForKey:@"level"] intValue];
        player.dAvatar=[dic objectForKey:@"avatar"];
//        player.dDefense=[[dic objectForKey:@"defense"] intValue];
//        player.dAttack=[[dic objectForKey:@"attack"] intValue];
        [arrItemsList addObject: player];
    }

    for (CDFavPlayer *fvPlayer in arrItemsList) {

        for (SSServer *server in self.serverObjects) {

            if ([server.serverName isEqualToString:fvPlayer.dAuth]) {
                fvPlayer.dAttack = server.weapon;
                fvPlayer.dDefense = server.defense;
                fvPlayer.dBot = server.bot;
                fvPlayer.dStatus = server.status;
                fvPlayer.dSessionId = server.sessionId;
                NSLog(@"\nfav %@ is online!",fvPlayer.dNickName );
            }
        }
    }
    
    NSData *data= [NSKeyedArchiver archivedDataWithRootObject:arrItemsList];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"favPlayers"];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"favPlayers"];
    
    FavouritesViewController *favsViewController = (FavouritesViewController *)delegate;
    [favsViewController.loadingView setHidden:YES];
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
    FavouritesViewController *favsViewController = (FavouritesViewController *)delegate;
    [favsViewController.loadingView setHidden:YES];
    [favsViewController.activityIndicator stopAnimating];
    [favsViewController.tvFavTable reloadData];
}

#pragma mark IconDownloaderDelegate
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            FavouritesCell *cell = (FavouritesCell*)[tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            [cell setPlayerIcon:iconDownloader.imageDownloaded];
        });
        [imageDownloadsInProgress removeObjectForKey:indexPath];
        iconDownloader = nil;
    }
}

#pragma mark
+(void)addFavoriteId:(NSString*)favoriteId completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) finishBlock;
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_ADD_FAVORITE]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    [theRequest setHTTPMethod:@"POST"];
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                           [AccountDataSource sharedInstance].accountID,@"user_authen",
                           favoriteId,@"favorite_authen",
                           [AccountDataSource sharedInstance].sessionID,@"session_id",
                           nil];
    
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection
     sendAsynchronousRequest:theRequest
     queue:[[NSOperationQueue alloc] init]
     completionHandler:finishBlock];
}
+(void)deleteFavoriteId:(NSString*)favoriteId completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) finishBlock;
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_DELETE_FAVORITE]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    [theRequest setHTTPMethod:@"POST"];
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                           [AccountDataSource sharedInstance].accountID,@"user_authen",
                           favoriteId,@"favorite_authen",
                           [AccountDataSource sharedInstance].sessionID,@"session_id",
                           nil];
    
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection
     sendAsynchronousRequest:theRequest
     queue:[[NSOperationQueue alloc] init]
     completionHandler:finishBlock];
}

-(void)addToDBFavotitePlayer:(CDFavPlayer*)player;
{
    [arrItemsList addObject:player];
    [self saveFavorites:arrItemsList];
}
-(void)deleteFromDBFavoriteWithId:(NSString*)playerID;
{
    CDFavPlayer *player = [arrItemsList objectAtIndex:[FavouritesDataSource findPlayerByID](arrItemsList,playerID)];
    [arrItemsList removeObject:player];
}

-(void)saveFavorites:(NSArray*)array;
{
    NSData *data= [NSKeyedArchiver archivedDataWithRootObject:array];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FAVORITES_LIST];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:FAVORITES_LIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSMutableArray*)loadFavoritesArray;
{
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_LIST];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data1];
}

-(BOOL) isOnline:(CDFavPlayer *)fvPlayer;
{
    for (SSServer *server in self.serverObjects) {
        if ([server.serverName isEqualToString:fvPlayer.dAuth]) {
            fvPlayer.dAttack = server.weapon;
            fvPlayer.dDefense = server.defense;
            fvPlayer.dBot = server.bot;
            fvPlayer.dStatus = server.status;
            fvPlayer.dSessionId = server.sessionId;
            NSLog(@"\nfav %@ is online!",fvPlayer.dNickName );
            return YES;
        }
    }
    NSLog(@"\nfav %@ is offline!",fvPlayer.dNickName );
    return NO;
}

#pragma mark -
-(void)invaiteWithMessage:(id __strong)sender;
{
    FavouritesCell *cell=(FavouritesCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    [delegate clickButton:indexPath];
}
@end
