//
//  CDDuelProduct.m
//  Cowboy Duels
//
//  Created by Taras on 24.10.12.
//
//

#import "CDDuelProduct.h"

@implementation CDDuelProduct

@synthesize dName;
@synthesize dDescription;
@synthesize dIconLocal;
@synthesize dIconURL;
@synthesize dPrice;
@synthesize dPurchaseUrl;
@synthesize dEffect;

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.dName forKey:@"NAME"];
    [encoder encodeObject:self.dDescription forKey:@"DESC"];
    [encoder encodeObject:self.dIconLocal forKey:@"ICON_LOCAL"];
    [encoder encodeObject:self.dIconURL forKey:@"ICON_URL"];
    [encoder encodeInteger:self.dPrice forKey:@"PRICE"];
    [encoder encodeObject:self.dPurchaseUrl forKey:@"PURCH_URL"];
    [encoder encodeInteger:self.dEffect forKey:@"EFFECT"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self.dName = [decoder decodeObjectForKey:@"NAME"];
    self.dDescription = [decoder decodeObjectForKey:@"DESC"];
    self.dIconLocal = [decoder decodeObjectForKey:@"ICON_LOCAL"];
    self.dIconURL = [decoder decodeObjectForKey:@"ICON_URL"];
    self.dPrice = [decoder decodeIntegerForKey:@"PRICE"];
    self.dPurchaseUrl = [decoder decodeObjectForKey:@"PURCH_URL"];
    self.dEffect = [decoder decodeIntegerForKey:@"EFFECT"];
    return self;
}

@end
