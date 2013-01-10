//
//  LoadViewController.h
//  Test
//
//  Created by Sobol on 13.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "StartViewController.h"

@interface LoadViewController : UIViewController <RefreshContentDataControllerDelegate,MemoryManagement>
-(id)initWithPush:(__weak NSDictionary *)notification;
@end
