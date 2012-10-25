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

@interface StoreDataSource()
{
    UITableView *tableView;
    StoreViewController *storeViewController;
}
@end

@implementation StoreDataSource
@synthesize arrItemsList,cellsHide,typeOfTable;

#pragma mark - Instance initialization

-(id) initWithTable:(UITableView *)pTable parentVC:(StoreViewController *)pStoreViewController;
 {
	self = [super init];
	
	if (!self) {
		return nil;
	}
     
    typeOfTable = StoreDataSourceTypeTablesWeapons;
    arrItemsList=[[NSMutableArray alloc] init];
     
    tableView=pTable;
    storeViewController = pStoreViewController;
    cellsHide=YES;
	return self;
}

-(void) reloadDataSource;
{
    NSString *key;
    if (typeOfTable == StoreDataSourceTypeTablesWeapons) {
        key=DUEL_PRODUCTS_WEAPONS;
    }else{
        key=DUEL_PRODUCTS_DEFENSES;
    }
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSMutableArray *testArr= [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    if ([testArr count]==0) {
        DuelProductDownloaderController *duelProductDownloaderController = [[DuelProductDownloaderController alloc] init];
        [duelProductDownloaderController setDidFinishBlock:^(NSError *error){
            [tableView reloadData];
        }];
        [duelProductDownloaderController refreshDuelProducts];
        testArr = nil;
    }else {
        testArr = nil;
        arrItemsList = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    }
}

#pragma mark - Delegated methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell = [[UITableViewCell alloc] init];
//    cell = [tableView dequeueReusableCellWithIdentifier:[TopPlayerCell cellID]];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrItemsList count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
@end

