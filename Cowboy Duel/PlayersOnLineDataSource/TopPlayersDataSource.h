//
//  ItemsDataSource.h
//  ScopeAndSequence
//
//  Created by Developer on 21.06.11.
//  Copyright 2011 Company Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDTopPlayer.h"
#import "JSON.h"
#import "ValidationUtils.h"
#import "TopPlayerCell.h"
#import "Utils.h"

@protocol IconDownloaderDelegate;


@interface TopPlayersDataSource : NSObject <UITableViewDataSource,IconDownloaderDelegate,MemoryManagement>
@property(strong, readonly)NSMutableArray *arrItemsList;
@property(weak, nonatomic)id delegate;
@property(nonatomic) int myProfileIndex;

-(void) reloadDataSource;
-(id) initWithTable:(UITableView *)pTable;
-(BOOL) isPlayerInTop10:(NSString*)authen;
@end
