//
//  ItemsDataSource.h
//  ScopeAndSequence
//
//  Created by Developer on 21.06.11.
//  Copyright 2011 Company Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionAppWrapper.h"


@interface ItemsDataSource : NSObject <UITableViewDataSource> {
    NSArray *arrItemsList;
    CollectionAppWrapper *collectionAppWrapper;
}
@property(readonly)NSArray *arrItemsList;
@property(strong,nonatomic)CollectionAppWrapper *collectionAppWrapper;

-(void) reloadDataSource;

@end
