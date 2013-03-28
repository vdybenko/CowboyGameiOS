//
//  GameSceneConfig.m
//  Bounty Hunter
//
//  Created by Sergey Sobol on 27.03.13.
//
//

#import "GameSceneConfig.h"

@implementation GameSceneConfig
@synthesize barrelsCount, cactusCount, horseCount, menCount, womenCount;
-(id)init
{
    self = [super init];
    if (self) {
        barrelsCount = 0;
        cactusCount = 0;
        horseCount = 0;
        menCount = 0;
        womenCount = 0;
    }
    return self;
}
@end
