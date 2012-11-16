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
    StoreDataSourceTypeTablesWeaponsTRY,
} StoreDataSourceTypeTables;

@interface StoreDataSource : NSObject <UITableViewDataSource> {
    
}
@property(strong, readonly)NSMutableArray *arrItemsList;
@property(nonatomic) BOOL cellsHide;
@property(strong, nonatomic)id<TableCellWithButton> delegate;
@property(nonatomic) StoreDataSourceTypeTables typeOfTable;

-(void) reloadDataSource;
-(id) initWithTable:(UITableView *)pTable parentVC:(StoreViewController *)storeViewController;
@end