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

@implementation ListOnlineDataSource
@synthesize connection,listOnline;

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

+ (NSMutableArray *)arrayListOnline:(NSString *)jsonString;
{

    NSMutableArray *serverObjects = [[NSMutableArray alloc] init];
    NSError *jsonParseError;
    
    [serverObjects removeAllObjects];
    SBJSON *parser = [[SBJSON alloc] init];
    
    NSArray *servers = [parser objectWithString:jsonString error:&jsonParseError];
    
    if (!servers) {
        NSLog(@"\nJSON parse error: %@", jsonParseError);
        [serverObjects removeAllObjects];
    }
    else{
        
        for (NSDictionary *server in servers)
        {
            SSServer *serverObj = [[SSServer alloc] init];
            [serverObj setValuesForKeysWithDictionary:server];
            [serverObjects addObject:serverObj];
        }
    }
    return serverObjects;
}

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

#pragma mark SSConnection handlers:

-(void) listOnlineResponse:(NSString *)jsonString
{
    self.listOnline = [ListOnlineDataSource arrayListOnline:jsonString];
}

@end
