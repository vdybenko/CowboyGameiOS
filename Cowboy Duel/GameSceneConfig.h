//
//  GameSceneConfig.h
//  Bounty Hunter
//
//  Created by Sergey Sobol on 27.03.13.
//
//

#import <Foundation/Foundation.h>

@interface GameSceneConfig : NSObject
{
    NSInteger barrelsCount;
    NSInteger cactusCount;
    NSInteger horseCount;
    NSInteger menCount;
    NSInteger womenCount;
}

@property(nonatomic) NSInteger barrelsCount;
@property(nonatomic) NSInteger cactusCount;
@property(nonatomic) NSInteger horseCount;
@property(nonatomic) NSInteger menCount;
@property(nonatomic) NSInteger womenCount;
@end
