//
//  AdColonyViewController.h
//  Cowboy Duel 1
//
//  Created by Paul Kovalenko on 26.04.12.
//  Copyright (c) 2012 ascoron90@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdColonyPublic.h"
//#import "BluetoothViewController.h"
#import "CurrencyManager.h"
#import "StartViewController.h"

typedef enum {
    AdColonyAdsStatusNotChecked=0,
    AdColonyAdsStatusShow,
    AdColonyAdsStatusRemoved,
} AdColonyAdsStatus;

@class StartViewController;

@interface AdColonyViewController : UIViewController <AdColonyTakeoverAdDelegate, CurrencyManagerDelegate,SKPaymentTransactionObserver, SKProductsRequestDelegate> {
    
    
    CurrencyManager *__unsafe_unretained cm;
    
    BOOL soundCheack;
    AVAudioPlayer *player;
    BOOL userOptedIn;
    BOOL navigationVideoPlayed;
    BOOL onIPadDetermined, onIPad;
    
    UIAlertView *baseAlert;
    NSMutableString *stDonate;
    
    IBOutlet UIView *adcolonyMainView;
    IBOutlet UILabel *lbWatchText;
    IBOutlet UIButton *btnWatchVideo;
    IBOutlet UIButton *btnRemoveAdvertising;
    
    IBOutlet UIView *loadingView;
    IBOutlet UIActivityIndicatorView *activityIndicator;

    
}

@property (nonatomic, unsafe_unretained) CurrencyManager *cm;

- (id)initWithStartVC:(StartViewController *) pStartVC;

-(void)videoAdsReadyCheck;
-(void)enableVideoButton;

-(void) performNavigation;

-(void)keyboardAppeared:(NSNotification *)notification;
-(void)keyboardGone:(NSNotification *)notification;

-(IBAction)watchMovieButton:(id)sender;
-(IBAction)cancelButton:(id)sender;
-(IBAction)removeAdvertising:(id)sender;

@end
