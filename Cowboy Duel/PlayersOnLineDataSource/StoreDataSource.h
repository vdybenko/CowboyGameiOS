//
//  ItemsDataSource.h
//  ScopeAndSequence
//
//  Created by Developer on 21.06.11.
//  Copyright 2011 Company Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"
#import "ValidationUtils.h"
#import "Utils.h"
#import "PlayersOnLineDataSource.h"

@class StoreViewController;

typedef enum {
    StoreDataSourceTypeTablesWeapons,
    StoreDataSourceTypeTablesDefenses,
    StoreDataSourceTypeTablesBarrier
} StoreDataSourceTypeTables;

@interface StoreDataSource : NSObject <UITableViewDataSource,MemoryManagement> {
    
}
@property(strong, readonly)NSMutableArray *arrItemsList;
@property(weak, nonatomic)id<TableCellWithButton> delegate;
@property(weak, nonatomic) UITableView *tableView;
@property(nonatomic) StoreDataSourceTypeTables typeOfTable;
@property(nonatomic) BOOL cellsHide;
@property(nonatomic) BOOL bagFlag;

-(void) reloadDataSource;
-(id) initWithTable:(UITableView *)pTable parentVC:(StoreViewController *)storeViewController;
@end
