//
//  TestViewController.h
//  Test
//
//  Created by Sobol on 11.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DuelViewControllerWithXib.h"

#define kFilteringFactor 0.5


@interface DuelViewController : DuelViewControllerWithXib <CLLocationManagerDelegate, UIAccelerometerDelegate, DuelViewControllerDelegate> 
{
}

-(id)initWithTime:(int)randomTime Account:(AccountDataSource *)userAccount oponentAccount:(AccountDataSource *)oponentAccount;
-(float)abs:(float)d;

@property(nonatomic, strong)id<DuelViewControllerDelegate> delegate;
@property(nonatomic)int time;
@property(nonatomic) BOOL notFirstStart;
@property(nonatomic) int startDuelTime;


@end
