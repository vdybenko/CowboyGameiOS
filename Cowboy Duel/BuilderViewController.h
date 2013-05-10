//
//  BuilderViewController.h
//  Bounty Hunter
//
//  Created by Alex Novitsky on 5/6/13.
//
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"

@class VisualViewDataSource;

@interface BuilderViewController : UIViewController<MemoryManagement,GMGridViewDataSource,UIScrollViewDelegate>

@property (strong, nonatomic) VisualViewDataSource *visualViewDataSource;

@end
