//
//  CDFavPlayer.m
//  Bounty Hunter
//
//  Created by AlexandrBezpalchuk on 07.02.13.
//
//

#import "CDFavPlayer.h"

@implementation CDFavPlayer
@synthesize dDefense,dAttack;
@synthesize dBot;
@synthesize dSessionId;
@synthesize dStatus;

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
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.dDefense] forKey:@"DEFENSE"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.dAttack] forKey:@"ATTACK"];
    [encoder encodeBool:self.dBot forKey:@"BOT"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.dDefense = [[decoder decodeObjectForKey:@"DEFENSE"] intValue];
    self.dAttack = [[decoder decodeObjectForKey:@"ATTACK"] intValue];
    self.dAttack = [decoder decodeBoolForKey:@"BOT"];
    return self;
}

@end
