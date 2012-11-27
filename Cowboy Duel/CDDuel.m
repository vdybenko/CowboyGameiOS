//
//  Cowboy Duel
//
//  Created by Sergey Sobol on 29.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CDDuel.h"

@implementation CDDuel
@synthesize dGps, dDate, dRateFire, dOpponentId;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:dGps forKey:@"GPS"];
    [encoder encodeObject:dDate forKey:@"DATE"];
    [encoder encodeObject:dRateFire forKey:@"RATEFIRE"];
    [encoder encodeObject:dOpponentId forKey:@"OPPONENTID"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    dGps = [decoder decodeObjectForKey:@"GPS"];
    dDate = [decoder decodeObjectForKey:@"DATE"];
    dRateFire = [decoder decodeObjectForKey:@"RATEFIRE"];
    dOpponentId = [decoder decodeObjectForKey:@"OPPONENTID"];
    return self;
}

@end
