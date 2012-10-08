//
//  ShopViewController.h
//  Test
//
//  Created by Sobol on 31.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopDataSource.h"



@interface ShopViewController : UIViewController<SKProductsRequestDelegate,SKPaymentTransactionObserver> {
    ShopDataSource *shopDataSource;
}
- (BOOL)canMakePayments;
- (void) requestProductData;
@end
