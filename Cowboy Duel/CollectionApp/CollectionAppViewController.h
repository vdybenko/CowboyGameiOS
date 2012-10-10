//
//  ListOfCategoriesViewController.h
//  platfor
//
//  Created by Taras on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemsDataSource.h"

@interface CollectionAppViewController : UIViewController<UITableViewDelegate>
-(void)reloadController;
@end
