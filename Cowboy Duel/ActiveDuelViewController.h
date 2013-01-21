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

@interface ActiveDuelViewController : UIViewController

-(id)initWithTime:(int)randomTime Account:(AccountDataSource *)userAccount oponentAccount:(AccountDataSource *)pOponentAccount;
@end
