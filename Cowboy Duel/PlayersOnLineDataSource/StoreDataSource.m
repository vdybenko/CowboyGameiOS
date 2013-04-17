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
    __weak StoreViewController *storeViewController;
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
     
    tableView=pTable;
    storeViewController = pStoreViewController;
     
	return self;
}

-(void) reloadDataSource;
{
    if (![[StartViewController sharedInstance].duelProductDownloaderController isListProductsAvailable]) {
        [storeViewController activityShow];
        if ([DuelProductDownloaderController isRefreshEvailable:NSNotFound]) {
            [[StartViewController sharedInstance].duelProductDownloaderController refreshDuelProducts];
            __block id selfBlock = self;
            __block id tableViewBlock = tableView;
            [StartViewController sharedInstance].duelProductDownloaderController.didFinishBlock = ^(NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(error){
                        [storeViewController activityHide];
                    }
                    [selfBlock reloadDataSource];
                    [selfBlock setCellsHide:YES];
                    [tableViewBlock reloadData];
                    [storeViewController startTableAnimation];
                });
            };
        }else{
            if (![StartViewController sharedInstance].duelProductDownloaderController.didFinishBlock) {
                __block id selfBlock = self;
                __block id tableViewBlock = tableView;
                [StartViewController sharedInstance].duelProductDownloaderController.didFinishBlock = ^(NSError *error){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(error){
                            [storeViewController activityHide];
                        }
                        [selfBlock reloadDataSource];
                        [selfBlock setCellsHide:YES];
                        [tableViewBlock reloadData];
                        [storeViewController startTableAnimation];
                    });
                };
            }
        }
    }else {
        switch (typeOfTable) {
            case StoreDataSourceTypeTablesWeapons:
                arrItemsList = [DuelProductDownloaderController loadWeaponArray];
                break;
            case StoreDataSourceTypeTablesDefenses:
                arrItemsList = [DuelProductDownloaderController loadDefenseArray];
                break;
            case StoreDataSourceTypeTablesBarrier:
                arrItemsList = [DuelProductDownloaderController loadBarrierArray];
                break;
            default:
                break;
        }
        
        if (self.bagFlag){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.dCountOfUse > 0 || SELF.dID == -1"];
            [arrItemsList filterUsingPredicate:predicate];
        }
        
        [storeViewController activityHide];
    }
}

-(void)releaseComponents
{
    arrItemsList = nil;
    tableView = nil;
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

