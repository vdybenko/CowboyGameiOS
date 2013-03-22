//
//  VisualViewCharacterViewController.h
//  Bounty Hunter
//
//  Created by Taras on 21.03.13.
//
//

#import <UIKit/UIKit.h>
#import "VisualViewDataSource.h"

@interface VisualViewCharacterViewController : UIViewController<UITableViewDelegate,MemoryManagement>

@property (strong, nonatomic) VisualViewDataSource *visualViewDataSource;

-(id)init;
-(void)refreshController;
@end
