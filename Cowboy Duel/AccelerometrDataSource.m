//
//  AccelerometrDataSource.m
//  Cowboy Duel
//
//  Created by Sergey Sobol on 07.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccelerometrDataSource.h"

@implementation AccelerometrDataSource

@synthesize x, y, z;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        firstFintData = [[FintDataSource alloc] init];	
    }
    
    return self;
}

-(FintType)setPositionWithX:(float)xl
                   andY:(float)yl
                   andZ:(float)zl
{
    x = xl;
    y = yl;
    z = zl;
    
    fintType = [self checkFint];
    return fintType;
}

-(FintType)checkFint
{
    return [self firstFint];
    //return [self secondFint];
    return NoneFint;
}

////////////////////////////////////////////////////first fint

-(FintType)firstFint
{
//    NSLog(@"First %f %f %f",x,y,z);

    if ((y < -1) && (x > 0.05)) {firstFintData.firstLevel = YES;/*NSLog(@"first level yes ");*/}
    if (x < 0.00) {firstFintData.firstLevel = NO;/*NSLog(@"first level No");*/}
    if ((z > 0.7) && (firstFintData.firstLevel)){ firstFintData.secondLevel = YES;/* NSLog(@"secondLevel = YES");*/}
    if ((z < 0.7) && (firstFintData.secondLevel)) {firstFintData.thirdLevel = YES;/*NSLog(@"thirdLevel = YES");*/}
    
    if ([firstFintData doneFint]) 
    {
        [firstFintData reloadFint];
        return FirstFint;
    }
    
    return NoneFint;
}

////////////////////////////////////////////////////second fint

-(FintType)secondFint
{
    
    
    return NoneFint;
}

-(void)reloadFint
{
    [firstFintData reloadFint];
}



@end
