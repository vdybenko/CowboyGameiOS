//
//  CDAchivment.m
//  Cowboy Duel
//
//  Created by Sergey Sobol on 11.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CDAchivment.h"

@implementation CDAchivment
@synthesize aAchivmentId;

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
    [encoder encodeObject:aAchivmentId forKey:@"ID"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    aAchivmentId = [decoder decodeObjectForKey:@"ID"];
    
    return self;
}

@end
