//
//  GameContentViewController.h
//  AdColonyBasicApp
//
//  Created by Erik Seeley on 2/22/11.
//  Copyright 2011 Jirbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrencyManager.h"
#import "AdColonyPublic.h"

@interface GameContentViewController : UIViewController <CurrencyManagerDelegate>{
	IBOutlet UILabel *currentBalanceLabel1, *currentBalanceLabel2;
	IBOutlet UILabel *disclaimerLabel;
	IBOutlet UILabel *balanceEarnedLabel;
	
	BOOL showedVideo;
    CurrencyManager *__unsafe_unretained cm;
}

@property(nonatomic, unsafe_unretained) CurrencyManager *cm;

-(id) initWithVideoPlayed:(BOOL)videoWatched;
-(IBAction) backButtonPressed;

@end
