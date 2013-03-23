//
//  VisualViewCharacterViewController.h
//  Bounty Hunter
//
//  Created by Taras on 21.03.13.
//
//

#import <UIKit/UIKit.h>
@class VisualViewDataSource;

@interface VisualViewCharacterViewController : UIViewController<MemoryManagement,UICollectionViewDelegate>

@property (strong, nonatomic) VisualViewDataSource *visualViewDataSource;

-(id)init;
-(void)refreshController;
@end
