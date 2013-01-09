//
//  ItemsDataSource.m
//  ScopeAndSequence
//
//  Created by Developer on 21.06.11.
//  Copyright 2011 Company Name. All rights reserved.
//

#import "StoreDataSource.h"
#import "UIImage+Save.h"
#import "DuelProductDownloaderController.h"
#import "StoreViewController.h"
#import "StoreProductCell.h"

@interface StoreDataSource()
{
    __unsafe_unretained StoreViewController *storeViewController;
    DuelProductDownloaderController *duelProductDownloaderController;
}
@end

@implementation StoreDataSource
@synthesize arrItemsList,typeOfTable,delegate;
@synthesize cellsHide, bagFlag;
@synthesize tableView;

#pragma mark - Instance initialization

-(id) initWithTable:(UITableView *)pTable parentVC:(StoreViewController *)pStoreViewController;
 {
	self = [super init];
	
	if (!self) {
		return nil;
	}
     cellsHide = YES;
    typeOfTable = StoreDataSourceTypeTablesWeapons;
    arrItemsList=[[NSMutableArray alloc] init];
    duelProductDownloaderController = [[DuelProductDownloaderController alloc] init];
     
    tableView=pTable;
    storeViewController = pStoreViewController;
     
	return self;
}

-(void) reloadDataSource;
{
    __unsafe_unretained NSMutableArray *testArr;
    if (typeOfTable == StoreDataSourceTypeTablesWeapons) {
        testArr = [DuelProductDownloaderController loadWeaponArray];
    }else{
        testArr = [DuelProductDownloaderController loadDefenseArray];
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.dCountOfUse > 0 || SELF.dID == -1"];
    if (self.bagFlag) [testArr filterUsingPredicate:predicate];
    
    if ([testArr count]==0) {
        arrItemsList = testArr;
    }else {
        arrItemsList = testArr;
    }
}

#pragma mark - Delegated methods

-(UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	StoreProductCell *cell;
     cell = [pTableView dequeueReusableCellWithIdentifier:[StoreProductCell cellID]];
    
    if (!cell ) {
        cell = [StoreProductCell cell];
        [cell initMainControls];
    }
    
    cell.hidden = cellsHide;
    CDDuelProduct *prod=[arrItemsList objectAtIndex:indexPath.row];
    [cell populateWithProduct:prod targetToBuyButton:self cellType:typeOfTable];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrItemsList count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

#pragma mark -
-(void)buyButtonClick:(id __strong)sender;
{
    StoreProductCell *cell=(StoreProductCell *)sender;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    [delegate clickButton:indexPath];
}
@end

