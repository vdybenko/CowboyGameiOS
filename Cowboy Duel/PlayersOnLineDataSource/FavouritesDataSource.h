//
//  FavouritesDataSource.h
//  Bounty Hunter
//
//  Created by AlexandrBezpalchuk on 07.02.13.
//
//

#import <Foundation/Foundation.h>

#import "CDFavPlayer.h"
#import "JSON.h"
#import "ValidationUtils.h"
#import "FavouritesCell.h"
#import "Utils.h"
#import "SSConnection.h"

#import "ListOnlineDataSource.h"

@class FavouritesViewController;

@protocol IconDownloaderDelegate;

@protocol TableCellWithButton
-(void)clickButton:(NSIndexPath *)indexPath;
@optional
-(void)didFinishLoadTable:(UITableView*)table;
-(void)clickButtonSteal:(NSIndexPath *)indexPath;
@end

typedef enum {
    OFFLINE,
    ONLINE
} FavTableType;

@interface FavouritesDataSource : ListOnlineDataSource <UITableViewDataSource,IconDownloaderDelegate,MemoryManagement>
@property(strong, readonly) NSMutableArray *arrItemsList;
@property(weak, nonatomic) UITableView *tableView;
@property(weak, nonatomic)id<TableCellWithButton> delegate;
@property(nonatomic)FavTableType typeOfTable;
@property(nonatomic)BOOL cellsHide;

-(void) reloadDataSource;
-(id) initWithTable:(UITableView *)pTable;

+(void)addFavoriteId:(NSString*)favoriteId completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) finishBlock;
+(void)deleteFavoriteId:(NSString*)favoriteId completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) finishBlock;

-(void)addToDBFavotitePlayer:(CDFavPlayer*)player;
-(void)deleteFromDBFavoriteWithId:(NSString*)playerID;

-(void)saveFavorites:(NSArray*)array;
-(NSMutableArray*)loadFavoritesArray;

-(BOOL) isOnline:(CDFavPlayer *)fvPlayer;
@end
