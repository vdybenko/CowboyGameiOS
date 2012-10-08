//
//  CDPlayerOnLine.m
//  Cowboy Duel 1
//
//  Created by Taras on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CDPlayerOnLine.h"

@implementation CDPlayerOnLine
@synthesize dPlayerIP, dOnline, dPlayerPublicIP,dWinCount,dInTop;

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
    [encoder encodeObject:self.dPlayerIP forKey:@"IP"];
    [encoder encodeObject:self.dPlayerPublicIP forKey:@"PIP"];
    [encoder encodeObject:[NSString stringWithFormat:@"%b",self.dOnline] forKey:@"ONLINE"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.dWinCount] forKey:@"WINCOUNT"];
    [encoder encodeObject:[NSString stringWithFormat:@"%b",self.dInTop] forKey:@"TOP"];

}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.dPlayerIP = [decoder decodeObjectForKey:@"IP"];
    self.dPlayerPublicIP = [decoder decodeObjectForKey:@"PIP"];
    self.dOnline = [[decoder decodeObjectForKey:@"ONLINE"] boolValue];
    self.dInTop = [[decoder decodeObjectForKey:@"TOP"] boolValue];
    self.dWinCount = [[decoder decodeObjectForKey:@"WINCOUNT"] intValue];
    return self;
}

@end
