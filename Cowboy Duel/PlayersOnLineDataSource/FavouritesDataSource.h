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
@protocol IconDownloaderDelegate;

@protocol TableCellWithButton
-(void)clickButton:(NSIndexPath *)indexPath;
@optional
-(void)didFinishLoadTable:(UITableView*)table;
@end

@interface FavouritesDataSource : NSObject <UITableViewDataSource,IconDownloaderDelegate,MemoryManagement, SSConnectionDelegate>
@property(strong, readonly) NSMutableArray *arrItemsList;
@property(weak, nonatomic) UITableView *tableView;
@property(weak, nonatomic)id<TableCellWithButton> delegate;

@property (nonatomic, strong) NSMutableArray *serverObjects;

-(void) reloadDataSource;
-(id) initWithTable:(UITableView *)pTable;

+(void)addFavoriteId:(NSString*)favoriteId completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) finishBlock;
+(void)deleteFavoriteId:(NSString*)favoriteId completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) finishBlock;

-(void)addToDBFavotitePlayer:(CDFavPlayer*)player;
-(void)deleteFromDBFavoriteWithId:(NSString*)playerID;

-(void)saveFavorites:(NSArray*)array;
-(NSMutableArray*)loadFavoritesArray;

+(NSUInteger(^)(NSArray *, NSString *))findPlayerByID;
-(BOOL) isOnline:(CDFavPlayer *)fvPlayer;
@end
