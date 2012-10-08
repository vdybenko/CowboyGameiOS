//
//  ClassInstructionsManager.h
//  ScopeAndSequence
//
//  Created by Developer on 02.07.11.
//  Copyright 2011 Company Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define PRODUCT_IDENTIFIER_KEY @"productIdentifier"


@interface PurchasesManager : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate> {
    NSOperationQueue *downloadQueue;
    
    NSInteger processCounter;
}

-(void) purchaseWithProductIdentifier:(NSString *)productIdentifier;
-(void) buyPurchaseRemoveAds;

@end
