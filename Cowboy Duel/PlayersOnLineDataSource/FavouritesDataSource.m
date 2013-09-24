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

#import "AccountDataSource.h"

#import "UIImage+Save.h"
#import "UIButton+Image+Title.h"
#import "IconDownloader.h"
#import "DuelRewardLogicController.h"

@interface FavouritesDataSource()
{
    NSMutableData *receivedData;
    
    NSMutableDictionary *imageDownloadsInProgress;
    
    NSArray *arrDefense;
    NSArray *arrAttack;
}
@end

@implementation FavouritesDataSource

@synthesize arrFavObjets, tableView, delegate,typeOfTable,cellsHide;
@synthesize arrFavObjetsList;

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
  
    arrFavObjets=[[NSMutableArray alloc] init];
    arrFavObjetsList =[[NSMutableArray alloc] init];
    imageDownloadsInProgress=[[NSMutableDictionary alloc] init];
    
    self.serverObjects = [[NSMutableArray alloc] init];
    tableView=pTable;
    cellsHide = YES;
    arrDefense = [DuelProductDownloaderController loadDefenseArray];
    arrAttack = [DuelProductDownloaderController loadWeaponArray];
    
//    update at init

    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:FAV_PLAYERS_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    [theRequest setHTTPMethod:@"POST"];
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                           [[AccountDataSource sharedInstance] accountID],@"authen",
                           nil];
    
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
    [theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]];
        
    CustomNSURLConnection *theConnection=[[CustomNSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        receivedData = [[NSMutableData alloc] init];
    } else {
        FavouritesViewController *favsViewController = (FavouritesViewController *)delegate;
        [favsViewController.loadingView setHidden:YES];
        [favsViewController.activityIndicator stopAnimating];
    }
    
	return self;
}

-(void) reloadDataSource;
{
    NSMutableArray *arr= [self loadFavoritesArray];
    if (arr) {
        arrFavObjetsList = arr;
        
        NSMutableArray *discardedItems = [[NSMutableArray alloc] init];
        
        for (CDFavPlayer *fvPlayer in arrFavObjetsList) {
            BOOL playerOnline = [self isOnline:fvPlayer];
            if (playerOnline && typeOfTable == OFFLINE) {
                [discardedItems addObject:fvPlayer];
            }else if (!playerOnline && typeOfTable == ONLINE){
                [discardedItems addObject:fvPlayer];
            }
        }
        
        [arrFavObjetsList removeObjectsInArray:discardedItems];
        [discardedItems removeAllObjects];
                
        FavouritesViewController *favsViewController = (FavouritesViewController *)delegate;
        [favsViewController.loadingView setHidden:YES];
        [self setCellsHide:YES];
        [tableView reloadData];
        [favsViewController startTableAnimation];
    }else{
        FavouritesViewController *favsViewController = (FavouritesViewController *)delegate;
        [favsViewController.loadingView setHidden:YES];
    }
}

-(void)releaseComponents
{
    arrFavObjets = nil;
    arrFavObjetsList = nil;
    receivedData = nil;
    tableView = nil;
    imageDownloadsInProgress = nil;
    arrDefense = nil;
    arrAttack = nil;
}
#pragma mark - Delegated methods

-(UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	FavouritesCell* cell;
    cell = [pTableView dequeueReusableCellWithIdentifier:[FavouritesCell cellID]];
    
    if (!cell ) {
        cell = [FavouritesCell cell];
        [cell initMainControls];
    }
    
    CDFavPlayer *player;
    
    player=[arrFavObjetsList objectAtIndex:indexPath.row];
    cell.hidden = cellsHide;
    [cell populateWithPlayer:player index:indexPath];
    
    [cell setPlayerIcon:nil];
    
    if (typeOfTable == ONLINE) {
        [cell.btnGetHim addTarget:self action:@selector(invaiteWithMessage:) forControlEvents:UIControlEventTouchUpInside];
        
//        [cell.btnGetHim removeTarget:self action:@selector(stealGold:) forControlEvents:UIControlEventTouchUpInside ];
        if ([player.dStatus isEqualToString:@"A"]) {
            cell.btnGetHim.enabled = YES ;
            [cell.btnGetHim changeTitleByLabel:@"DUEL"];
        }else{
            cell.btnGetHim.enabled = NO ;
            [cell.btnGetHim changeTitleByLabel:@"Busy"];
        }
    }else{
        if ([self checkForSteal:player]) {
            [cell.btnGetHim removeTarget:self action:@selector(invaiteWithMessage:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnGetHim addTarget:self action:@selector(stealGold:) forControlEvents:UIControlEventTouchUpInside ];
            [cell.btnGetHim changeTitleByLabel:@"Steal"];
        }else{
            
            [cell.btnGetHim removeTarget:self action:@selector(invaiteWithMessage:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnGetHim addTarget:self action:@selector(pokeHim:) forControlEvents:UIControlEventTouchUpInside ];
            [cell.btnGetHim changeTitleByLabel:@"Poke"];
        }
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
    return [arrFavObjetsList count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

#pragma mark CustomNSURLConnection handlers


- (void)connectionDidFinishLoading:(CustomNSURLConnection *)connection1 {
    
    connection1 = nil;
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSArray *responseObject = ValidateObject([jsonString JSONValue], [NSArray class]);
    [arrFavObjets removeAllObjects];
    for (NSDictionary *dic in responseObject) {
        CDFavPlayer *player=[[CDFavPlayer alloc] init];
        player.dAuth=[dic objectForKey:@"authen"];
        player.dNickName=[dic objectForKey:@"nickname"];
        player.dMoney=[[dic objectForKey:@"money"] intValue];
        player.dLevel=[[dic objectForKey:@"level"] intValue];
        player.dAvatar=[dic objectForKey:@"avatar"];
        
        player.dDefense=[DuelRewardLogicController countUpBuletsWithPlayerLevel:player.dLevel];
        if([[dic objectForKey:@"defenses"] respondsToSelector:@selector(objectForKey:)]){
            int defId = [[[dic objectForKey:@"defenses"] objectForKey:@"id"] intValue];
            NSUInteger index=[[AccountDataSource sharedInstance] findObsByID](arrDefense,defId);
            if (index!=NSNotFound) {
                CDDefenseProduct *def = [arrDefense objectAtIndex:index];
                player.dDefense += def.dDefense;
            }
        }
        
        player.dAttack=[DuelRewardLogicController countUpBuletsWithPlayerLevel:player.dLevel];

        if([[dic objectForKey:@"weapons"] respondsToSelector:@selector(objectForKey:)]){
            int attId = [[[dic objectForKey:@"weapons"] objectForKey:@"id"] intValue];
            NSUInteger index=[[AccountDataSource sharedInstance] findObsByID](arrAttack,attId);
            if (index!=NSNotFound) {
                CDWeaponProduct *att = [arrAttack objectAtIndex:index];
                player.dAttack += att.dDamage;
            }
        }
        [arrFavObjets addObject: player];
    }    
    [self saveFavorites:arrFavObjets];
    arrFavObjetsList = arrFavObjets;
    [super refreshListOnline];

}

- (void)connection:(CustomNSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(CustomNSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/FavouritesDS_didFailConnection" forKey:@"page"]];
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

#pragma mark ListOnlineDataSource
-(void) listOnlineResponse:(NSString *)jsonString
{
    [super listOnlineResponse:jsonString];
    [self reloadDataSource];
}

- (void)connectionTimeoutListOnline
{
    FavouritesViewController *favsViewController = (FavouritesViewController *)delegate;
    if (self.typeOfTable == ONLINE) {
        [favsViewController btnOfflineClicked:Nil];
    }
    [super connectionTimeoutListOnline];
    [self reloadDataSource];
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
    [arrFavObjets addObject:player];
    [self saveFavorites:arrFavObjets];
}
-(void)deleteFromDBFavoriteWithId:(NSString*)playerID;
{
    CDFavPlayer *player = [arrFavObjets objectAtIndex:[FavouritesDataSource findPlayerByID](arrFavObjets,playerID)];
    [arrFavObjets removeObject:player];
    [self saveFavorites:arrFavObjets];
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
            fvPlayer.dMoney = [server.money integerValue];
            fvPlayer.dAttack = server.weapon + [DuelRewardLogicController countUpBuletsWithPlayerLevel:[server.rank intValue]];
            fvPlayer.dDefense = server.defense + [DuelRewardLogicController countUpBuletsWithPlayerLevel:[server.rank intValue]];
            fvPlayer.dBot = server.bot;
            fvPlayer.dStatus = server.status;
            fvPlayer.dSessionId = server.sessionId;
            return YES;
        }
    }
    return NO;
}

-(BOOL)checkForSteal:(CDFavPlayer *)fvPlayer ;
{
    //condition for steal gold should be here!
    return NO;
}

#pragma mark -
-(void)invaiteWithMessage:(id __strong)sender;
{
    while (![sender isKindOfClass:[UITableViewCell class]]) {
        sender = [sender superview];
    };
    FavouritesCell *cell=(FavouritesCell *)sender;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    [delegate clickButton:indexPath];
}

-(void)pokeHim:(id __strong)sender;
{
    while (![sender isKindOfClass:[UITableViewCell class]]) {
        sender = [sender superview];
    };
    FavouritesCell *cell=(FavouritesCell *)sender;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    [delegate clickButtonPoke:indexPath];
}

-(void)stealGold:(id __strong)sender;
{
    while (![sender isKindOfClass:[UITableViewCell class]]) {
        sender = [sender superview];
    };
    FavouritesCell *cell=(FavouritesCell *)sender;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    [delegate clickButtonSteal:indexPath];
}
@end
