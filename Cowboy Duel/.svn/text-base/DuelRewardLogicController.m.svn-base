//
//  DuelRewardLogicController.m
//  Cowboy Duel 1
//
//  Created by Taras on 03.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DuelRewardLogicController.h"

@implementation DuelRewardLogicController

+(NSInteger)getPointsForWinWithOponentLevel:(NSInteger)oponentlevel;
{
    NSLog(@"getPointsForWinWithOponentLevel %d", oponentlevel);
   NSArray *_pontsForWin=[[NSArray alloc] initWithObjects:
                  [NSNumber numberWithInt:1],
                  [NSNumber numberWithInt:4],
                  [NSNumber numberWithInt:6],
                  [NSNumber numberWithInt:10],
                  [NSNumber numberWithInt:15],
                  [NSNumber numberWithInt:25],
                  [NSNumber numberWithInt:35],
                  [NSNumber numberWithInt:50],
                  [NSNumber numberWithInt:65],
                  [NSNumber numberWithInt:85],
                  [NSNumber numberWithInt:100],
                  nil]; 
    if (oponentlevel < 0 || oponentlevel>10) {
        oponentlevel = 1;
    }
    int winPonits=[[_pontsForWin objectAtIndex:(oponentlevel)] intValue];
    return winPonits;
    
}

+(NSInteger)getPointsForLoseWithOponentLevel:(NSInteger)oponentlevel;
{
    NSLog(@"getPointsForLoseWithOponentLevel %d", oponentlevel);
    NSArray *_pontsForLose=[[NSArray alloc] initWithObjects:
                   [NSNumber numberWithInt:1],
                   [NSNumber numberWithInt:1],
                   [NSNumber numberWithInt:2],
                   [NSNumber numberWithInt:3],
                   [NSNumber numberWithInt:5],
                   [NSNumber numberWithInt:7],
                   [NSNumber numberWithInt:10],
                   [NSNumber numberWithInt:15],
                   [NSNumber numberWithInt:20],
                   [NSNumber numberWithInt:25],
                   [NSNumber numberWithInt:30],
                   nil];
    if (oponentlevel<0||oponentlevel>10) {
        oponentlevel = 1;
    }
    int losePonits=[[_pontsForLose objectAtIndex:(oponentlevel)] intValue];
    return losePonits;
}


+(NSArray *)getStaticPointsForEachLevels;
{
    NSArray *array=[[NSArray alloc] initWithObjects:
                    [NSNumber numberWithInt:1],//1
                    [NSNumber numberWithInt:20],//2
                    [NSNumber numberWithInt:40],//3
                    [NSNumber numberWithInt:80],//4
                    [NSNumber numberWithInt:150],//5
                    [NSNumber numberWithInt:300],//6
                    [NSNumber numberWithInt:500],//7
                    [NSNumber numberWithInt:800],//8
                    [NSNumber numberWithInt:1500],//9
                    [NSNumber numberWithInt:5000],//10
                    nil];
    return array;
}

+(NSInteger)countUpBuletsWithPlayerLevel:(int)playerLevel;
{
    NSLog(@"countUpBuletsWithPlayerLevel %d", playerLevel);
    NSArray *array=[[NSArray alloc] initWithObjects:
                    [NSNumber numberWithInt:2],//0
                    [NSNumber numberWithInt:2],//1
                    [NSNumber numberWithInt:2],//2
                    [NSNumber numberWithInt:3],//3
                    [NSNumber numberWithInt:3],//4
                    [NSNumber numberWithInt:4],//5
                    [NSNumber numberWithInt:4],//6
                    [NSNumber numberWithInt:5],//7
                    [NSNumber numberWithInt:5],//8
                    [NSNumber numberWithInt:6],//9
                    [NSNumber numberWithInt:6],//10
                    nil];
    if (playerLevel < 0||playerLevel>10) {
        playerLevel = 1;
    }
    int countBullets=[[array objectAtIndex:(playerLevel)] intValue];
    return countBullets;
}
@end
