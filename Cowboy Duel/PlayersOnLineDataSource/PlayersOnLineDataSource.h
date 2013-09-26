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
#import "PlayerOnLineCell.h"
#import "TopPlayersDataSource.h"
#import "IconDownloader.h"

#import "ListOnlineDataSource.h"

@protocol TableCellWithButton

-(void)clickButton:(NSIndexPath *)indexPath;
@optional
-(void)didFinishLoadTable:(UITableView*)table;

@end

@interface PlayersOnLineDataSource : ListOnlineDataSource <UITableViewDataSource,IconDownloaderDelegate> {
    NSMutableArray * arrItemsList;
    NSMutableData *receivedData;
    UITableView *_tableView;
    
    NSNumberFormatter *numberFormatter;
    
    NSMutableDictionary *imageDownloadsInProgress;
    __weak id<TableCellWithButton> delegate;
    
    TopPlayersDataSource *topPlayersDataSource;
}
@property(strong, readonly)NSArray *arrItemsList;
@property(weak, nonatomic)id<TableCellWithButton> delegate;
@property(nonatomic) BOOL statusOnLine;

-(void) reloadDataSource;
-(id) initWithTable:(UITableView *)pTable;
@end
