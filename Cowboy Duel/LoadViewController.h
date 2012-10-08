//
//  LoadViewController.h
//  Test
//
//  Created by Sobol on 13.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "StartViewController.h"

@interface LoadViewController : UIViewController <RefreshContentDataControllerDelegate>{
    AVAudioPlayer *player; 
    StartViewController  *startViewController;
    BOOL firstRun;
    UIImageView *imgBackground;
    NSMutableData *receivedData;
}
-(id)initWithPush:(NSDictionary *)notification;
-(void)closeWindow;

- (void) animationWithGunsFirst:  (UIImageView *)imageLeft andSecond:(UIImageView *)imageRight;

@end
