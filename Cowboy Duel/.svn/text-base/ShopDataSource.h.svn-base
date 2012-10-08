//
//  ShopDataSource.h
//  Test
//
//  Created by Sobol on 31.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "ValidationUtils.h"

@class ShopDataSource;

@protocol ShopDataSourceDelegate

@optional
//- (void)shopDataSource:(ShopDataSource *)dataSource requestCompleted:(ASIHTTPRequest *)request;
- (void)shopDataSource:(ShopDataSource *)dataSource productsRequestCompleted:(SKProductsRequest *)request;
- (void)shopDataSourceRequestFailed:(ShopDataSource *)dataSource;

@end

@interface ShopDataSource : NSObject  <SKProductsRequestDelegate> {
    NSObject <ShopDataSourceDelegate> *__unsafe_unretained delegate;
	
//	ASIFormDataRequest *lastRequest;
    SKProductsRequest *lastProductsRequest;
    
    NSArray *__unsafe_unretained resultsList;
}
@property (unsafe_unretained) NSObject <ShopDataSourceDelegate> *delegate;
@property (unsafe_unretained, nonatomic) NSArray *resultsList;

- (void)reloadResults;
- (void)buyItemAtRow:(NSInteger)row;

@end
