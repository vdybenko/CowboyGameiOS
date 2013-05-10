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

@property (strong, nonatomic) VisualViewDataSource *visualViewDataSource;

@end
