//
//  CDPlayerOnLine.m
//  Cowboy Duel 1
//
//  Created by Taras on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CDPlayerMain.h"

@implementation CDPlayerMain
@synthesize dAuth, dNickName,dAvatar, dMoney,dLevel;

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
    [encoder encodeObject:self.dAuth forKey:@"AUTH"];
    [encoder encodeObject:self.dNickName forKey:@"NICK"];
    [encoder encodeObject:self.dAvatar forKey:@"AVATAR"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.dMoney] forKey:@"MONEY"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.dLevel] forKey:@"LEVEL"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self.dAuth = [decoder decodeObjectForKey:@"AUTH"];
    self.dNickName = [decoder decodeObjectForKey:@"NICK"];
    self.dAvatar = [decoder decodeObjectForKey:@"AVATAR"];
    self.dMoney = [[decoder decodeObjectForKey:@"MONEY"] intValue];
    self.dLevel = [[decoder decodeObjectForKey:@"LEVEL"] intValue];
    return self;
}

@end
