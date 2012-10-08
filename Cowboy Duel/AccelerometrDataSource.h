//
//  AccelerometrDataSource.h
//  Cowboy Duel
//
//  Created by Sergey Sobol on 07.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FintDataSource.h"

typedef enum {
    NoneFint,
    FirstFint,
    SecondFint,
    ThirdFint
} FintType;


@interface AccelerometrDataSource : NSObject
{
    float x;
    float y;
    float z;
    FintType fintType;
    FintDataSource *firstFintData;
}
@property(nonatomic) float x;
@property(nonatomic) float y;
@property(nonatomic) float z;

-(FintType)setPositionWithX:(float)xl
                   andY:(float)yl
                   andZ:(float)zl;
-(FintType)checkFint;
-(FintType)firstFint;
-(FintType)secondFint;
-(void)reloadFint;


@end
