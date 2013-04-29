//
//  TeachingHelperViewController.h
//  Cowboy Duels
//
//  Created by Taras on 15.11.12.
//
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"

@interface TeachingHelperViewController : UIViewController
-(id)initWithOponentAccount:(AccountDataSource *)oponentAccount parentVC:(id<UIAccelerometerDelegate>)parentVC;
@end
