//
//  AdColonyViewController.h
//  Cowboy Duel 1
//
//  Created by Paul Kovalenko on 26.04.12.
//  Copyright (c) 2012 ascoron90@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BluetoothViewController.h"
#import "CurrencyManager.h"
#import "StartViewController.h"
#import "MKStoreManager.h"

typedef enum {
    AdColonyAdsStatusNotChecked=0,
    AdColonyAdsStatusShow,
    AdColonyAdsStatusRemoved,
} AdColonyAdsStatus;

@class StartViewController;

@interface AdColonyViewController : UIViewController <AdColonyTakeoverAdDelegate, CurrencyManagerDelegate,SKPaymentTransactionObserver, SKProductsRequestDelegate, MKStoreKitDelegate>
@property (nonatomic, unsafe_unretained) CurrencyManager *cm;

- (id)initWithStartVC:(StartViewController *) pStartVC;
+ (BOOL)isAdStatusValid;
@end
