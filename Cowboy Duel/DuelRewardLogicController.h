//
//  DuelRewardLogicController.h
//  Bounty Hunter 1
//
//  Created by Taras on 03.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DuelRewardLogicController : NSObject

+(NSInteger)getPointsForWinWithOponentLevel:(NSInteger)oponentlevel;
+(NSInteger)getPointsForLoseWithOponentLevel:(NSInteger)oponentlevel;
+(NSArray *)getStaticPointsForEachLevels;
+(NSInteger)countUpBuletsWithPlayerLevel:(int)playerLevel;
+(NSInteger)countUpBuletsWithOponentLevel:(int)playerLevel defense:(NSInteger)defense playerAtack:(NSInteger)atack;
@end
