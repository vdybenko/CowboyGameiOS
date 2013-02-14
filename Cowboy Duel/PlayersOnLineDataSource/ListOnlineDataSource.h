//
//  ListOnlineDataSource.h
//  Bounty Hunter
//
//  Created by AlexandrBezpalchuk on 14.02.13.
//
//

#import <Foundation/Foundation.h>
#import "SSConnection.h"

@interface ListOnlineDataSource : NSObject<SSConnectionDelegate>

@property (strong, nonatomic) SSConnection *connection;
@property (strong, nonatomic) NSMutableArray *listOnline;

//+ (NSMutableArray *)listOnlineResponse:(NSString *)jsonString;
+ (NSUInteger(^)(NSArray *, NSString *)) findPlayerByID;
- (void) refreshListOnline;

@end
