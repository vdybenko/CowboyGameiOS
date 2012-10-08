//
//  ListOfCategoriesViewController.h
//  platfor
//
//  Created by Taras on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemsDataSource.h"

@interface CollectionAppViewController : UIViewController<UITableViewDelegate>{
    IBOutlet UITableView * tableView;
    IBOutlet UIButton *btnBack;
    IBOutlet UILabel *lbBackBtn;
    ItemsDataSource *itemsDataSource;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
-(void)reloadController;
@end
