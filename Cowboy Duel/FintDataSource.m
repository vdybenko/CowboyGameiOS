//
//  FintDataSource.m
//  Cowboy Duel
//
//  Created by Sergey Sobol on 07.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FintDataSource.h"

@implementation FintDataSource
@synthesize firstLevel, thirdLevel, secondLevel;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        firstLevel = NO;
        secondLevel = NO;
        thirdLevel = NO;
    }
    
    return self;
}

-(void)reloadFint
{
    firstLevel = NO;
    secondLevel = NO;
    thirdLevel = NO;
}

-(BOOL)doneFint
{
    return ((firstLevel) && (secondLevel) && (thirdLevel));
}
@end
