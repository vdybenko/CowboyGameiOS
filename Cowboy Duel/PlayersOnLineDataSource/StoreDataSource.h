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
@class StoreViewController;

typedef enum {
    StoreDataSourceTypeTablesWeapons,
    StoreDataSourceTypeTablesDefenses,
} StoreDataSourceTypeTables;

@interface StoreDataSource : NSObject <UITableViewDataSource> {
    
}
@property(strong, readonly)NSMutableArray *arrItemsList;
@property(strong, nonatomic)id delegate;
@property(nonatomic) BOOL cellsHide;

-(void) reloadDataSource;
-(id) initWithTable:(UITableView *)pTable parentVC:(StoreViewController *)storeViewController;
@end
