//
//  CDTransaction.m
//  Cowboy Duel
//
//  Created by Sergey Sobol on 29.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CDTransaction.h"

@implementation CDTransaction
@synthesize trMoneyCh, trType, trDescription, trLocalID, trGlobalID, trOpponentID;

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
    [encoder encodeObject:self.trMoneyCh forKey:@"Money"];
    [encoder encodeObject:self.trType forKey:@"Type"];
    [encoder encodeObject:self.trDescription forKey:@"Description"];
    [encoder encodeObject:self.trLocalID forKey:@"LocalID"];
    [encoder encodeObject:self.trGlobalID forKey:@"GlobalID"];
    [encoder encodeObject:self.trOpponentID forKey:@"OpponentID"];
    
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self.trMoneyCh = [decoder decodeObjectForKey:@"Money"];
    self.trType = [decoder decodeObjectForKey:@"Type"];
    self.trDescription = [decoder decodeObjectForKey:@"Description"];
    self.trLocalID = [decoder decodeObjectForKey:@"LocalID"];
    self.trGlobalID = [decoder decodeObjectForKey:@"GlobalID"];
    self.trOpponentID = [decoder decodeObjectForKey:@"OpponentID"];
    return self;
}

@end
