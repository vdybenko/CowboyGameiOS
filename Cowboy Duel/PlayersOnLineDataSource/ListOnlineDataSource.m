//
//  ListOnlineDataSource.m
//  Bounty Hunter
//
//  Created by AlexandrBezpalchuk on 14.02.13.
//
//

#import "ListOnlineDataSource.h"
#import "SSServer.h"
#import "SSConnection.h"
#import "CDPlayerMain.h"
#import "ListOfItemsViewController.h"
#import "FavouritesViewController.h"
#import "PlayersOnLineDataSource.h"

ListOfItemsViewController *delegate;

@implementation ListOnlineDataSource

@synthesize connection,serverObjects,isNeedFavCheck;

#pragma mark class methods:
+(NSUInteger(^)(NSArray *, NSString *))findPlayerByID {
    return ^(NSArray * array, NSString *dAuthID) {
        for (NSUInteger i = 0; i < [array count]; i++) {
            CDPlayerMain *player = [array objectAtIndex:i];
            if ([player.dAuth isEqualToString:dAuthID]) {
                return i;
            }
        }
        return (NSUInteger)NSNotFound;
    };
}
#pragma mark -

- (id)init{
    self = [super init];
	
	if (!self) {
		return nil;
	}

    connection = [SSConnection sharedInstance];
    connection.delegate = self;
    
    return self;
}

- (void) refreshListOnline;
{
    [connection sendData:@"" packetID:NETWORK_GET_LIST_ONLINE ofLength:sizeof(int)];
}

#pragma mark SSConnection handlers:

-(void) listOnlineResponse:(NSString *)jsonString
{
    
    NSLog(@"\nrefresh response: %@", jsonString);
    
    NSError *jsonParseError;
    
    [self.serverObjects removeAllObjects];
    SBJSON *parser = [[SBJSON alloc] init];
    
    NSArray *servers = [parser objectWithString:jsonString error:&jsonParseError];
    
    if (!servers) {
        NSLog(@"\nJSON parse error: %@", jsonParseError);
        [self.serverObjects removeAllObjects];
    }
    else{
        
        for (NSDictionary *server in servers)
        {
            SSServer *serverObj = [[SSServer alloc] init];
            [serverObj setValuesForKeysWithDictionary:server];
            if (isNeedFavCheck) {
                [self checkServerForFavorite:serverObj];
            }
            [self.serverObjects addObject:serverObj];
        }
    }
}

-(void)checkServerForFavorite:(SSServer*)server
{
    NSUInteger index = [FavouritesDataSource findPlayerByID]([[StartViewController sharedInstance].favsDataSource loadFavoritesArray] ,server.serverName);
    if (index == (NSUInteger)NSNotFound) {
        server.favorite = NO;
    }else{
        server.favorite = YES;
        
    }
}
@end
