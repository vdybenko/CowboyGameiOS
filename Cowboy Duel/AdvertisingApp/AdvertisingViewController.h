//
//  AdvertisingViewController.h
//  Cowboy Duel 1
//
//  Created by Taras on 05.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDCollectionAdvertisingApp.h"
#import "CollectionAppWrapper.h"
#import "UIButton+Image+Title.h"

@interface AdvertisingViewController : UIViewController

-(IBAction)btnSkipClick:(id)sender;
-(IBAction)btnAppStoreClick:(id)sender;
-(void) setInformationAboutApp;
-(BOOL)isAdvertisingNeed;

@end
