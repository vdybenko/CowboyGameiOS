//
//  ShopDataSource.m
//  Test
//
//  Created by Sobol on 31.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShopDataSource.h"
#import "JSON.h"
#import "NetworkActivityIndicatorManager.h"


@interface ShopDataSource (PrivateMethods)

- (void)getInfoForIdentifiers:(NSArray *)ids;

@end


@implementation ShopDataSource

@synthesize delegate;
@synthesize resultsList;

static const char *GET_SUBSCRIPTIONS_URL = BASE_URL "/api/get_subscriptions";


#pragma mark -
#pragma mark Initialization method

- (id)init {
	
	self = [super init];
	
	[self reloadResults];
	
	return self;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
//    if (lastRequest) {
//        [lastRequest clearDelegatesAndCancel];
//        
//        [[NetworkActivityIndicatorManager sharedInstance] hide];
//    }
    
    if (lastProductsRequest) {
        lastProductsRequest.delegate = nil;
//        [lastProductsRequest autorelease];
        lastProductsRequest = nil;
    }
    
	
}

#pragma mark -
#pragma mark Public methods

- (void)reloadResults {
	
//	if (lastRequest) {
//		[lastRequest clearDelegatesAndCancel];
//		lastRequest = nil;
//		
//		[[NetworkActivityIndicatorManager sharedInstance] hide];
//	}
	
    if (lastProductsRequest) {
        
        lastProductsRequest.delegate = nil;
//        [lastProductsRequest autorelease];
        
        [[NetworkActivityIndicatorManager sharedInstance] hide];
    }
    
//	NSURL *url = [NSURL URLWithString:[NSString stringWithCString:GET_SUBSCRIPTIONS_URL encoding:NSUTF8StringEncoding]];
//	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//	[request setTimeOutSeconds:kTimeOutSeconds];
//	[request setDelegate:self];
//	[request setPostValue:@"json" forKey:@"format"];
//	[request startAsynchronous];
//	
//	lastRequest = request;
	[[NetworkActivityIndicatorManager sharedInstance] show];
}


- (void)buyItemAtRow:(NSInteger)row {
    NSLog(@"Reason least = %d",[self.resultsList count]);
    
    NSString *lastUserMail = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastUserMail"];
    [[NSUserDefaults standardUserDefaults] setObject:lastUserMail forKey:@"LastBuyerMail"];
    
    SKProduct *product = [self.resultsList objectAtIndex:row];
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:product.productIdentifier];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark -
#pragma mark Private methods

- (void)getInfoForIdentifiers:(NSArray *)ids {
    
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:ids]];
    request.delegate = self;
    [request start];
    
    lastProductsRequest = request;
    
    [[NetworkActivityIndicatorManager sharedInstance] show];
}


//#pragma mark -
//#pragma mark ASIHTTPRequest handlers
//
//- (void)requestFinished:(ASIHTTPRequest *)request {
//    
//	NSString *response = [request responseString];
//	NSDictionary *responseObject = ValidateObject([response JSONValue], [NSDictionary class]);
//	NSArray *identifiers = ValidateObject([responseObject objectForKey:@"subscriptions"], [NSArray class]);
//	
//    NSLog(@"ShopDataSource: %@", response);
//    
//    if ([delegate respondsToSelector:@selector(shopDataSource:requestCompleted:)])
//        [delegate performSelector:@selector(shopDataSource:requestCompleted:) withObject:self withObject:request];
//    
//    if ([identifiers count] > 0)
//        [self getInfoForIdentifiers:identifiers];
//    else
//        if ([delegate respondsToSelector:@selector(shopDataSourceRequestFailed:)])
//            [delegate performSelector:@selector(shopDataSourceRequestFailed:) withObject:self];
//    
//	lastRequest.delegate = nil;
//	lastRequest = nil;
//    
//    [[NetworkActivityIndicatorManager sharedInstance] hide];
//}
//
//
//- (void)requestFailed:(ASIHTTPRequest *)request { 
//    
//	NSLog(@"ShopDataSource: Connection failed: %@", [[request error] description]);
//	
//	lastRequest.delegate = nil;
//	lastRequest = nil;
//	
//    if ([delegate respondsToSelector:@selector(shopDataSourceRequestFailed:)])
//        [delegate performSelector:@selector(shopDataSourceRequestFailed:) withObject:self];
//    
//    [[NetworkActivityIndicatorManager sharedInstance] hide];
//}


#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    self.resultsList = response.products;
    
    NSLog(@"Reason least = %d",[self.resultsList count]);
    
    if ([delegate respondsToSelector:@selector(shopDataSource:productsRequestCompleted:)])
        [delegate performSelector:@selector(shopDataSource:productsRequestCompleted:) withObject:self withObject:request];
    
    request.delegate = nil;
//    [request autorelease];
    lastProductsRequest = nil;
    
    [[NetworkActivityIndicatorManager sharedInstance] hide];
}

@end
