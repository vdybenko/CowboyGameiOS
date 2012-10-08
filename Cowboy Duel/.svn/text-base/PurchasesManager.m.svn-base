//
//  ClassInstructionsManager.m
//  ScopeAndSequence
//
//  Created by Developer on 02.07.11.
//  Copyright 2011 Company Name. All rights reserved.
//

#import "PurchasesManager.h"

#define INTRUCTION_URL BASE_API_URL @"get_instances"

#define TRANSACTION_KEY @"transaction"
#define FILE_PATH_KEY @"filePath"


@interface PurchasesManager ()

-(void) displayHudWithLabel:(NSString *)text;
-(void) hideHud;

-(void) provideContentForPaymentTransaction:(SKPaymentTransaction *)paymentTransaction;
-(void) processArchiveFile:(NSString *)filePath forProductIdentifier:(NSString *)productIdentifier;

-(void) addClassInstructionWithDictionary:(NSDictionary *)dictionary;

@end


@implementation PurchasesManager

#pragma mark - Instance initialization

-(id) init {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    downloadQueue = [[NSOperationQueue alloc] init];
	[downloadQueue setMaxConcurrentOperationCount:1];
    
    return self;
}


#pragma mark - Interface methods

-(void) purchaseWithProductIdentifier:(NSString *)productIdentifier {
//    [self provideContentForPaymentTransaction:productIdentifier];
//    return;
    if (![SKPaymentQueue canMakePayments]) {
        NSLog(@"can not MakePayments");
        
        return;
    }
    
    SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"removeAdColony"]];
    productRequest.delegate = self;
    [productRequest start];
}


-(void) buyPurchaseRemoveAds;
{
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"removeAdColony"];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - Private methods



#pragma mark - SKProductsRequestDelegate method

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *products = response.products;
    
    for (SKProduct *product in products) {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:product.productIdentifier];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    
    [self buyPurchaseRemoveAds];
    
}


#pragma mark - SKPaymentTransactionObserver methods

-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
//                [self provideContentForPaymentTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateRestored:
//                [self provideContentForPaymentTransaction:transaction.originalTransaction];
            default:
                break;
        }
    }
}


-(void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_TRANSACTIONS_RESTORED];
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_TRANSACTIONS_RESTORED];
}

@end