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
    DLog(@"getPointsForWinWithOponentLevel %d", oponentlevel);
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
    if (oponentlevel < kCountOfLevelsMinimal || oponentlevel>kCountOfLevels) {
        oponentlevel = kCountOfLevelsMinimal;
    }
    int winPonits=[[_pontsForWin objectAtIndex:(oponentlevel)] intValue];
    return winPonits;
    
}

+(NSInteger)getPointsForLoseWithOponentLevel:(NSInteger)oponentlevel;
{
    DLog(@"getPointsForLoseWithOponentLevel %d", oponentlevel);
    NSArray *_pontsForLose=[[NSArray alloc] initWithObjects:
                   [NSNumber numberWithInt:1],
                   [NSNumber numberWithInt:1],
                   [NSNumber numberWithInt:2],
                   [NSNumber numberWithInt:3],
                   [NSNumber numberWithInt:3],
                   [NSNumber numberWithInt:3],
                   [NSNumber numberWithInt:3],
                   [NSNumber numberWithInt:3],
                   [NSNumber numberWithInt:3],
                   [NSNumber numberWithInt:3],
                   [NSNumber numberWithInt:3],
                   nil];
    if (oponentlevel<kCountOfLevelsMinimal||oponentlevel>kCountOfLevels) {
        oponentlevel = kCountOfLevelsMinimal;
    }
    int losePonits=[[_pontsForLose objectAtIndex:(oponentlevel)] intValue];
    return losePonits;
}


+(NSArray *)getStaticPointsForEachLevels;
{
    NSArray *array=[[NSArray alloc] initWithObjects:
                    [NSNumber numberWithInt:1],//1
                    [NSNumber numberWithInt:20],//2
                    [NSNumber numberWithInt:60],//3
                    [NSNumber numberWithInt:120],//4
                    [NSNumber numberWithInt:240],//5
                    [NSNumber numberWithInt:480],//6
                    [NSNumber numberWithInt:960],//7
                    nil];
    return array;
}

+(NSInteger)countUpBuletsWithPlayerLevel:(int)playerLevel;
{
    NSArray *array=[[NSArray alloc] initWithObjects:
                    [NSNumber numberWithInt:5],//0
                    [NSNumber numberWithInt:6],//1
                    [NSNumber numberWithInt:7],//2
                    [NSNumber numberWithInt:8],//3
                    [NSNumber numberWithInt:9],//4
                    [NSNumber numberWithInt:10],//5
                    [NSNumber numberWithInt:11],//6
                    [NSNumber numberWithInt:12],//7
                    [NSNumber numberWithInt:13],//8
                    [NSNumber numberWithInt:14],//9
                    [NSNumber numberWithInt:15],//10
                    nil];
    if (playerLevel < kCountOfLevelsMinimal||playerLevel>kCountOfLevels) {
        playerLevel = kCountOfLevelsMinimal;
    }
    int countBullets=[[array objectAtIndex:(playerLevel)] intValue];
    return countBullets;
}

+(NSInteger)countUpBuletsWithOponentLevel:(int)playerLevel defense:(NSInteger)defense playerAtack:(NSInteger)atack;
{
    int countBullets = [DuelRewardLogicController countUpBuletsWithPlayerLevel:playerLevel];
    countBullets += defense;
    countBullets -= atack;
    if (countBullets<5) {
        return 5;
    }else{
        return countBullets;
    }
}
@end
