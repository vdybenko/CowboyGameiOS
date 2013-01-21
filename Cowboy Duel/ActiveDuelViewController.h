//
//  ActiveDuelViewController.h
//  Cowboy Duels
//
//  Created by Sergey Sobol on 10.01.13.
//
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
#import <AVFoundation/AVFoundation.h>
@protocol ActiveDuelViewControllerDelegate <NSObject>

@optional
@end

@interface ActiveDuelViewController : UIViewController
{
    BOOL duelIsStarted;
    BOOL fireSound;
    
    BOOL acelStatus;
    
    AVAudioPlayer *player;
    
    NSTimeInterval startInterval;
    NSTimeInterval stopInterval;
    NSTimeInterval nowInterval;
    NSTimeInterval activityInterval;
    
    NSTimer *timer;
    int shotTime;
    BOOL soundStart;
    BOOL accelerometerState;
    
    BOOL accelerometerStateSend;
    
    BOOL follAccelCheck;
    
}

@property(weak)id<ActiveDuelViewControllerDelegate> delegate;

-(id)initWithTime:(int)randomTime Account:(AccountDataSource *)userAccount oponentAccount:(AccountDataSource *)pOponentAccount;

@end
