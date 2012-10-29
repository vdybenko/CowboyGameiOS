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
@synthesize dImageGunLocal;
@synthesize dImageGunURL;
@synthesize dSoundLocal;
@synthesize dSoundURL;

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInteger:self.dDamage forKey:@"DAMAGE"];
    [encoder encodeObject:self.dImageGunLocal forKey:@"IMAGE_GUN_LOCAL"];
    [encoder encodeObject:self.dImageGunURL forKey:@"IMAGE_GUN_URL"];
    [encoder encodeObject:self.dSoundLocal forKey:@"SOUND_LOCAL"];
    [encoder encodeObject:self.dSoundURL forKey:@"SOUND_URL"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    self.dDamage = [decoder decodeIntegerForKey:@"DAMAGE"];
    self.dImageGunLocal = [decoder decodeObjectForKey:@"IMAGE_GUN_LOCAL"];
    self.dImageGunURL = [decoder decodeObjectForKey:@"IMAGE_GUN_URL"];
    self.dSoundLocal = [decoder decodeObjectForKey:@"SOUND_LOCAL"];
    self.dSoundURL = [decoder decodeObjectForKey:@"SOUND_URL"];
    return self;
}
-(NSString*) saveNameImageGun{return [NSString stringWithFormat:@"%dgun",self.dID];}
-(NSString*) saveNameSoundGun{return [NSString stringWithFormat:@"gun_sound%d",self.dID];}


@end
