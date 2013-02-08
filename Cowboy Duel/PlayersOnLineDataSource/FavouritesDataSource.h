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

@protocol IconDownloaderDelegate;

@interface FavouritesDataSource : NSObject <UITableViewDataSource,IconDownloaderDelegate,MemoryManagement>
@property(strong, readonly) NSMutableArray *arrItemsList;
@property(weak, nonatomic) UITableView *tableView;
@property(weak, nonatomic)id delegate;

-(void) reloadDataSource;
-(id) initWithTable:(UITableView *)pTable;

+(void)addFavoriteId:(NSString*)favoriteId completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) finishBlock;
+(void)deleteFavoriteId:(NSString*)favoriteId completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) finishBlock;

+(void)addToDBFavotitePlayer:(CDFavPlayer*)player;
+(void)deleteFromDBFavoriteWithId:(NSString*)playerID;
@end
