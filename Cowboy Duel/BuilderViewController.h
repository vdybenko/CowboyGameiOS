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

<<<<<<< HEAD
@interface BuilderViewController : UIViewController<MemoryManagement,GMGridViewDataSource,UIScrollViewDelegate>
=======
@interface BuilderViewController : UIViewController<MemoryManagement,UICollectionViewDataSource,UICollectionViewDelegate>
typedef void (^ScrollViewSwitcherResult)(NSInteger curentIndex);
typedef void (^BuyActionBlock)(NSInteger curentIndex);
>>>>>>> e5cf1330e8405a3b5442883f7867af34d5cbbf12

@property (strong, nonatomic) VisualViewDataSource *visualViewDataSource;
@property (copy) ScrollViewSwitcherResult didFinishBlock;
@property (copy) BuyActionBlock didBuyAction;
@end
