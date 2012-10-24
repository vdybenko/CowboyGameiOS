//
//  CDWeaponProduct.m
//  Cowboy Duels
//
//  Created by Taras on 24.10.12.
//
//

#import "CDWeaponProduct.h"

@implementation CDWeaponProduct
@synthesize dDamage;

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInteger:self.dDamage forKey:@"DAMAGE"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.dDamage = [decoder decodeIntegerForKey:@"DAMAGE"];
    return self;
}

@end
