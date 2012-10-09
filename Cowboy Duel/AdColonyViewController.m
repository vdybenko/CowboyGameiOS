//
//  AdColonyViewController.m
//  Cowboy Duel 1
//
//  Created by Paul Kovalenko on 26.04.12.
//  Copyright (c) 2012 ascoron90@gmail.com. All rights reserved.
//

#import "AdColonyViewController.h"
#import "StartViewController.h"
#import "UIView+Dinamic_BackGround.h"
#import "UIButton+Image+Title.h"
#import "AccountDataSource.h"

@interface AdColonyViewController ()

@end

@implementation AdColonyViewController
@synthesize cm;

StartViewController *startViewController;
NSString * const productForRemoveAds=@"com.webkate.cowboyduels.four";

- (id)initWithStartVC:(StartViewController *) pStartVC;
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        startViewController=pStartVC;
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        stDonate=[[NSMutableString alloc] init];
    }
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [btnWatchVideo setTitleByLabel:@"AdColonyBtn"];
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    [btnWatchVideo changeColorOfTitleByLabel:btnColor];
    
    [btnRemoveAdvertising setTitleByLabel:@"REMOVE ADS"];
    [btnRemoveAdvertising changeColorOfTitleByLabel:btnColor];
    
    lbWatchText.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"AdColonyText1", nil), NSLocalizedString(@"AdColonyText2", nil)];
    
    onIPadDetermined = NO;
    onIPad = NO;
    //    !!!!!!!!!!!
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppeared:) name:UIKeyboardWillShowNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardGone:) name:UIKeyboardWillHideNotification object:nil];
    //    !!!!!
	// Determine if the user has previously selected to opt in and set the UI accordingly
	userOptedIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"AdColonyInterstitialVideoOptIn"];    
    
    ADCOLONY_ZONE_STATUS s = [AdColony zoneStatusForSlot:1];
    if(s != ADCOLONY_ZONE_STATUS_ACTIVE){
		//        !!!!!
        //        [NSThread detachNewThreadSelector:@selector(videoAdsReadyCheck) toTarget:self withObject:nil];
        //        !!!!!!    }
        
        [cm addDelegate:self];
    }
    [adcolonyMainView setDinamicHeightBackground];
    
}

//-(void)videoAdsReadyCheck{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    const float checkEvery = 0.1f; //seconds
//	
//	BOOL zone1Ready = ([AdColony zoneStatusForSlot:1] == ADCOLONY_ZONE_STATUS_ACTIVE);
//    while (!zone1Ready) {
//        [NSThread sleepForTimeInterval:checkEvery];
//        zone1Ready = ([AdColony zoneStatusForSlot:1] == ADCOLONY_ZONE_STATUS_ACTIVE);
//    }
//    
//    [self performSelectorOnMainThread:@selector(enableVideoButton) withObject:nil waitUntilDone:NO];
//    
//    [pool release];

- (void)viewDidUnload
{
    adcolonyMainView = nil;
    lbWatchText = nil;
    btnWatchVideo = nil;
    [super viewDidUnload];
}

#pragma mark -
#pragma mark These two actions are tied to the buttons that launch video ads

- (void)dealloc {
}

- (IBAction)watchMovieButton:(id)sender {
    
	[AdColonyAdministratorPublic playVideoAdForSlot:2 withDelegate:self];	
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                        userInfo:[NSDictionary dictionaryWithObject:@"/AdColony_watch" forKey:@"event"]];
    [[StartViewController sharedInstance] duelButtonClick];
    [btnWatchVideo setEnabled:NO];
}

-(IBAction)removeAdvertising:(id)sender;
{
    [self buyProduct];
}
#pragma mark -
#pragma mark AdColonyTakeoverAdDelegate

//app interrupted: called when video is played
-(void)adColonyTakeoverBeganForZone:(NSString *)zone{
    //    [player pause];    
    NSLog(@"Video ad or fullscreen banner launched for zone %@", zone);
}

//app interruption over: called when video ad is dismissed
-(void)adColonyTakeoverEndedForZone:(NSString *)zone withVC:(BOOL)withVirtualCurrencyAward {
    //    [player play];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"advertisingWillShow"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:@"movieWatched"] < kNumberOfAdvertisingPerDay) {
        NSInteger movWatchInt = [defaults integerForKey:@"movieWatched"];
        movWatchInt++;
        [defaults setInteger:movWatchInt forKey:@"movieWatched"];
        [defaults synchronize];
    }
    NSInteger adColonyCanceled = 0;
    [defaults setInteger:adColonyCanceled forKey:@"adColonyCanceled"];
    [defaults synchronize];
    NSLog(@"adColonyCanceled for adcolony %@", [defaults objectForKey:@"adColonyCanceled"]);
    
	// If the play came from the Navigation Button, continue with execution.
    [self dismissModalViewControllerAnimated:YES];   
    
    //    WebPageViewController *webPageViewController = [[WebPageViewController alloc] init];
    //    [self.navigationController presentModalViewController:webPageViewController animated:YES];
    
}

- (IBAction)cancelButton:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger adColonyCanceled = 1;
    [defaults setInteger:adColonyCanceled forKey:@"adColonyCanceled"];
    [defaults synchronize];
    NSLog(@"adColonyCanceled for cancel %@", [defaults objectForKey:@"adColonyCanceled"]);
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/AdColony_Cancel" forKey:@"event"]];
}

#pragma mark SKProductsRequestDelegate

- (void) buyProduct
{
    if ([SKPaymentQueue canMakePayments]) {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:productForRemoveAds];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
        loadingView.hidden=NO;
        [activityIndicator startAnimating];
    }   
    [stDonate appendString:@"/removeAds"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:stDonate forKey:@"event"]];
}

-(void) restorPurchases {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue]restoreCompletedTransactions];
}


- (void) performDismiss {
    [baseAlert dismissWithClickedButtonIndex:[baseAlert cancelButtonIndex] animated:NO];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -

-(void)completedPurchaseTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completedPurchaseTransaction");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    [[AccountDataSource sharedInstance] setRemoveAds:AdColonyAdsStatusRemoved];
    [[AccountDataSource sharedInstance] saveRemoveAds];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [startViewController authorizationModifier:YES];
    [[StartViewController sharedInstance] duelButtonClick];
    [self dismissModalViewControllerAnimated:YES];

    loadingView.hidden=YES;
    [activityIndicator stopAnimating];

    
    [stDonate appendString:@"/done"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:stDonate forKey:@"event"]];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
}

- (void) handleFailedTransaction: (SKPaymentTransaction *) transaction {
    NSLog(@"handleFailedTransaction");

    if (transaction.error.code != SKErrorPaymentCancelled){
        baseAlert = [[UIAlertView alloc] initWithTitle:@"Transaction Error. Please try again later." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [self.view addSubview:baseAlert];
        [baseAlert show];
        
        [self performSelector:@selector(performDismiss) withObject:self afterDelay:3.0];
        
        [stDonate appendString:@"/error"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:stDonate forKey:@"event"]];
        
    }
    else
    {
        baseAlert = [[UIAlertView alloc] initWithTitle:@"Payment cancelled. Please try again later." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [self.view addSubview:baseAlert];
        [baseAlert show];
        
        [self performSelector:@selector(performDismiss) withObject:self afterDelay:3.0];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction]; 
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    loadingView.hidden=YES;
    [activityIndicator stopAnimating];
}



- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
     NSLog(@"paymentQueue: %i", queue.transactions.count);
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        NSLog(@"tran for product: %@ of state: %i", [[transaction payment] productIdentifier], [transaction transactionState]);

        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"SKPaymentTransactionStatePurchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"SKPaymentTransactionStatePurchased");
                [[AccountDataSource sharedInstance] setRemoveAds:AdColonyAdsStatusRemoved];
                [[AccountDataSource sharedInstance] saveRemoveAds];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [startViewController authorizationModifier:YES];
                [[StartViewController sharedInstance] duelButtonClick];
                [self dismissModalViewControllerAnimated:YES];
                loadingView.hidden=YES;
                [activityIndicator stopAnimating];
                
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction]; 
                [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
                
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"SKPaymentTransactionStateRestored");
                [self completedPurchaseTransaction:transaction];
                break;  
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"Failed %@", transaction.error);
                [self handleFailedTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {    
    NSLog(@"restoreCompletedTransactionsFailedWithError %@",[error userInfo]);
    loadingView.hidden=YES;
    [activityIndicator stopAnimating];
    [self dismissModalViewControllerAnimated:YES];
}

@end
