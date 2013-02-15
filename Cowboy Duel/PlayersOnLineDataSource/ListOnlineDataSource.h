//
//  ListOnlineDataSource.h
//  Bounty Hunter
//
//  Created by AlexandrBezpalchuk on 14.02.13.
//
//

#import <Foundation/Foundation.h>
#import "SSConnection.h"
#import "SSServer.h"

@interface ListOnlineDataSource : NSObject<SSConnectionDelegate>

@property (strong, nonatomic) SSConnection *connection;
@property (strong, nonatomic) NSMutableArray *serverObjects;
@property BOOL isNeedFavCheck;

+ (NSUInteger(^)(NSArray *, NSString *)) findPlayerByID;
- (void) refreshListOnline;
- (void) checkServerForFavorite:(SSServer*)server;

@end
