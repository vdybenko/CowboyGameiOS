//
//  ItemsDataSource.h
//  ScopeAndSequence
//
//  Created by Developer on 21.06.11.
//  Copyright 2011 Company Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDPlayerOnLine.h"
#import "JSON.h"
#import "ValidationUtils.h"
#import "PlayerOnLineCell.h"
#import "TopPlayersDataSource.h"
#import "IconDownloader.h"

@protocol TableCellWithButton

-(void)clickButton:(NSIndexPath *)indexPath;

@end

@interface PlayersOnLineDataSource : NSObject <UITableViewDataSource,IconDownloaderDelegate> {
    NSMutableArray * arrItemsList;
    NSMutableData *receivedData;
    UITableView *_tableView;
    
    NSNumberFormatter *numberFormatter;
    
    NSMutableDictionary *imageDownloadsInProgress;
    id<TableCellWithButton> delegate;
    
    TopPlayersDataSource *topPlayersDataSource;
    BOOL cellsHide;

}
@property(strong, readonly)NSArray *arrItemsList;
@property(strong, nonatomic)id<TableCellWithButton> delegate;
@property(nonatomic) BOOL cellsHide;
@property (nonatomic, strong) NSMutableArray *serverObjects;


-(void) reloadDataSource;
-(id) initWithTable:(UITableView *)pTable;
@end
