//
//  ShopViewController.m
//  Test
//
//  Created by Sobol on 31.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShopViewController.h"
#import <StoreKit/StoreKit.h>

@implementation ShopViewController
-(id)init
{
    self = [super init];
    if (self) {
        
        UIButton *buyMoneyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buyMoneyButton setFrame:CGRectMake(175, 150, 100, 40)];
        [buyMoneyButton setTitle:@"Buy 200$" forState:UIControlStateNormal];
        [buyMoneyButton addTarget:self action:@selector(buyMoneyButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:buyMoneyButton];
        
        //shopDataSource = [[ShopDataSource alloc] init];
        //shopDataSource.delegate = self;
         [self requestProductData];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)buyMoneyButtonClick
{
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"com.webkate.texasduel.coins100"];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) requestProductData
{
    SKProductsRequest *request= [[SKProductsRequest alloc] 
                                 initWithProductIdentifiers: [NSSet setWithObject: @"com.webkate.texasduel.coins100"]];
    request.delegate = self;
    [request start];
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:
(SKProductsResponse *)response
{
    NSArray *myProduct = response.products;
    DLog(@"count %d",[myProduct count]);
    // populate UI
//    [request autorelease];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    //DLog(@"count %d",[transactions count]);
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                DLog(@"Purchared");
                //[self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                DLog(@"Failed %@", transaction.error);
               // [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                DLog(@"Restored");
              //  [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)canMakePayments {
    
    BOOL canMakePayments = [SKPaymentQueue canMakePayments];
    
    if (!canMakePayments) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Для продления акаунта вам необходимо включить покупки внутри приложений в настройках вашего телефона.", @"")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
    }
    return canMakePayments;
}

@end
