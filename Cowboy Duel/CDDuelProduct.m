//
//  CDDuelProduct.m
//  Cowboy Duels
//
//  Created by Taras on 24.10.12.
//
//

#import "CDDuelProduct.h"

@implementation CDDuelProduct

@synthesize dID;
@synthesize dName;
@synthesize dDescription;
@synthesize dIconLocal;
@synthesize dIconURL;
@synthesize dImageLocal;
@synthesize dImageURL;
@synthesize dPrice;
@synthesize dPurchaseUrl;
@synthesize dLevelLock;

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:self.dID forKey:@"ID"];
    [encoder encodeObject:self.dName forKey:@"NAME"];
    [encoder encodeObject:self.dDescription forKey:@"DESC"];
    [encoder encodeObject:self.dIconLocal forKey:@"ICON_LOCAL"];
    [encoder encodeObject:self.dIconURL forKey:@"ICON_URL"];
    [encoder encodeObject:self.dImageLocal forKey:@"IMAGE_LOCAL"];
    [encoder encodeObject:self.dImageURL forKey:@"IMAGE_URL"];
    [encoder encodeInteger:self.dPrice forKey:@"PRICE"];
    [encoder encodeInteger:self.dLevelLock forKey:@"LEVEL"];
    [encoder encodeObject:self.dPurchaseUrl forKey:@"PURCH_URL"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self.dID = [decoder decodeIntegerForKey:@"ID"];
    self.dName = [decoder decodeObjectForKey:@"NAME"];
    self.dDescription = [decoder decodeObjectForKey:@"DESC"];
    self.dIconLocal = [decoder decodeObjectForKey:@"ICON_LOCAL"];
    self.dIconURL = [decoder decodeObjectForKey:@"ICON_URL"];
    self.dImageLocal = [decoder decodeObjectForKey:@"IMAGE_LOCAL"];
    self.dImageURL = [decoder decodeObjectForKey:@"IMAGE_URL"];
    self.dPrice = [decoder decodeIntegerForKey:@"PRICE"];
    self.dLevelLock = [decoder decodeIntegerForKey:@"LEVEL"];
    self.dPurchaseUrl = [decoder decodeObjectForKey:@"PURCH_URL"];
    return self;
}

-(NSString*) saveNameThumb{return [NSString stringWithFormat:@"%dthumb",self.dID];}
-(NSString*) saveNameImage{return [NSString stringWithFormat:@"%dimg",self.dID];}

@end
