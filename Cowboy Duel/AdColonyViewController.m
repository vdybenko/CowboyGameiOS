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
{
    CurrencyManager *__unsafe_unretained cm;
    
    UIAlertView *baseAlert;
    NSMutableString *stDonate;
    
    IBOutlet UIView *adcolonyMainView;
    IBOutlet UILabel *lbWatchText;
    IBOutlet UIButton *btnWatchVideo;
    IBOutlet UIButton *btnRemoveAdvertising;
    
    IBOutlet UIView *loadingView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

-(void)videoAdsReadyCheck;
-(void)enableVideoButton;

-(void) performNavigation;

-(void)keyboardAppeared:(NSNotification *)notification;
-(void)keyboardGone:(NSNotification *)notification;

-(IBAction)watchMovieButton:(id)sender;
-(IBAction)cancelButton:(id)sender;
-(IBAction)removeAdvertising:(id)sender;

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
    
    ADCOLONY_ZONE_STATUS s = [AdColony zoneStatusForSlot:1];
    if(s != ADCOLONY_ZONE_STATUS_ACTIVE){
        
        [cm addDelegate:self];
    }
    [adcolonyMainView setDinamicHeightBackground];
    
}

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
    
	[AdColonyAdministratorPublic playVideoAdForSlot:1 withDelegate:self];
    
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

+ (BOOL)isAdStatusValid;
{
    ADCOLONY_ZONE_STATUS z1Status = [AdColony zoneStatusForSlot:1];
    if(z1Status == ADCOLONY_ZONE_STATUS_NO_ZONE ||
       z1Status == ADCOLONY_ZONE_STATUS_OFF ||
       z1Status == ADCOLONY_ZONE_STATUS_UNKNOWN){
        DLog(@"Adcolony Enabled NO");
        return NO;
    }else if(z1Status == ADCOLONY_ZONE_STATUS_ACTIVE){
        DLog(@"Adcolony Enabled YES");
        return YES;
    }else{
        return NO;
    }
}

#pragma mark -
#pragma mark AdColonyTakeoverAdDelegate

//app interrupted: called when video is played
-(void)adColonyTakeoverBeganForZone:(NSString *)zone{
    //    [player pause];    
    DLog(@"Video ad or fullscreen banner launched for zone %@", zone);
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
    DLog(@"adColonyCanceled for adcolony %@", [defaults objectForKey:@"adColonyCanceled"]);
    
	// If the play came from the Navigation Button, continue with execution.
    [self dismissModalViewControllerAnimated:YES];   
}

- (IBAction)cancelButton:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger adColonyCanceled = 1;
    [defaults setInteger:adColonyCanceled forKey:@"adColonyCanceled"];
    [defaults synchronize];
    DLog(@"adColonyCanceled for cancel %@", [defaults objectForKey:@"adColonyCanceled"]);
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
    DLog(@"completedPurchaseTransaction");
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
    DLog(@"handleFailedTransaction");

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
     DLog(@"paymentQueue: %i", queue.transactions.count);
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        DLog(@"tran for product: %@ of state: %i", [[transaction payment] productIdentifier], [transaction transactionState]);

        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                DLog(@"SKPaymentTransactionStatePurchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                DLog(@"SKPaymentTransactionStatePurchased");
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
                DLog(@"SKPaymentTransactionStateRestored");
                [self completedPurchaseTransaction:transaction];
                break;  
                
            case SKPaymentTransactionStateFailed:
                DLog(@"Failed %@", transaction.error);
                [self handleFailedTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {    
    DLog(@"restoreCompletedTransactionsFailedWithError %@",[error userInfo]);
    loadingView.hidden=YES;
    [activityIndicator stopAnimating];
    [self dismissModalViewControllerAnimated:YES];
}

@end
