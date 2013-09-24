//
//  CDCollectionAdvertisingApp.m
//  Bounty Hunter 1
//
//  Created by Taras on 05.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CDCollectionAdvertisingApp.h"


@implementation CDCollectionAdvertisingApp
@synthesize cdNumberOfShows;

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInteger:self.cdNumberOfShows forKey:@"NUMBER_SHOWS"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.cdNumberOfShows = [decoder decodeIntegerForKey:@"NUMBER_SHOWS"];
    return self;
}

-(void)setCdNumberOfShows_number:(NSNumber *)number;
{
    self.cdNumberOfShows=[number intValue];
}
@end
