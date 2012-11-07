//
//  CDDefenseProduct.m
//  Cowboy Duels
//
//  Created by Taras on 24.10.12.
//
//

#import "CDDefenseProduct.h"

@implementation CDDefenseProduct
@synthesize dDefense;

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInteger:self.dDefense forKey:@"DEFENCE"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.dDefense = [decoder decodeIntegerForKey:@"DEFENCE"];
    return self;
}

-(id)init
{
    self = [super init];
    self.dDefense = 0;
    return self;
}

@end
