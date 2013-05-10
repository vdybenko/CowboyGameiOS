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

@interface BuilderViewController : UIViewController<MemoryManagement,GMGridViewDataSource,GMGridViewActionDelegate,UIScrollViewDelegate>
typedef void (^ScrollViewSwitcherResult)(NSInteger curentIndex);
typedef void (^BuyActionBlock)(NSInteger curentIndex);

@property (strong, nonatomic) VisualViewDataSource *visualViewDataSource;
@property (copy) ScrollViewSwitcherResult didFinishBlock;
@property (copy) BuyActionBlock didBuyAction;
@property (nonatomic) NSInteger curentObject;
@end
