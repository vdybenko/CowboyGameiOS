//
//  CDPlayerOnLine.m
//  Cowboy Duel 1
//
//  Created by Taras on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CDTopPlayer.h"

@implementation CDTopPlayer
@synthesize dPoints,dPositionInList;
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
    [super encodeWithCoder:encoder];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.dPoints] forKey:@"POINTS"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.dPositionInList] forKey:@"POSITION"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.dPoints = [[decoder decodeObjectForKey:@"POINTS"] intValue];
    self.dPositionInList = [[decoder decodeObjectForKey:@"POSITION"] intValue];
    return self;
}

@end
