//
//  TeachingViewController.h
//  Test
//
//  Created by Sobol on 25.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "AccelerometrDataSource.h"
#import "DuelViewControllerWithXib.h"

//#define kFilteringFactor 0.1

@interface TeachingViewController : DuelViewControllerWithXib<CLLocationManagerDelegate, UIAccelerometerDelegate,DuelViewControllerDelegate> {
    
    int time;
    
    int mutchNumber;
    int mutchNumberWin;
    int mutchNumberLose;

    BOOL firstRun;
    
    NSTimer *deaccelTimer;
}
@property (nonatomic, readwrite) int mutchNumber;
@property (nonatomic, readwrite) int mutchNumberWin;
@property (nonatomic, readwrite) int mutchNumberLose;


-(id)initWithTime:(int)randomTime
       andAccount:(AccountDataSource *)userAccount
     andOpAccount:(AccountDataSource *)oponentAccount;
-(void)startDuel;
-(void)increaseMutchNumberLose;
-(void)increaseMutchNumber;
-(void)increaseMutchNumberWin;
-(int)fMutchNumberLose;
-(int)fMutchNumber;
-(int)fMutchNumberWin;

-(float)abs:(float)d;

-(IBAction)buttonClick;

@end
