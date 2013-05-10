//
//  BuilderViewController.h
//  Bounty Hunter
//
//  Created by Alex Novitsky on 5/6/13.
//
//

#import <UIKit/UIKit.h>
@class VisualViewDataSource;

@interface BuilderViewController : UIViewController<MemoryManagement,UICollectionViewDataSource,UICollectionViewDelegate>
typedef void (^ScrollViewSwitcherResult)(NSInteger curentIndex);
typedef void (^BuyActionBlock)(NSInteger curentIndex);

@property (strong, nonatomic) VisualViewDataSource *visualViewDataSource;
@property (copy) ScrollViewSwitcherResult didFinishBlock;
@property (copy) BuyActionBlock didBuyAction;
@end
