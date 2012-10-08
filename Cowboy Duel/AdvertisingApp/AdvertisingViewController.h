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
{
    CDCollectionAdvertisingApp *_AppCurentForShow;
    CollectionAppWrapper *_collectionAppWrapper;
    
    BOOL advertisingNeed;
    
    IBOutlet UILabel *titleView;
    IBOutlet UIView *view;
    IBOutlet UIView *bodyView;
    IBOutlet UIWebView *webBody;
    IBOutlet UIButton *_btnAppStore;
    
}

@property (strong) IBOutlet UIView *view;
@property (strong) IBOutlet UIView *bodyView;
@property (strong) IBOutlet UILabel *titleView;
@property (strong) IBOutlet UIWebView *webBody;
@property (strong) IBOutlet UIButton *_btnAppStore;

//@property (strong, nonatomic) CDCollectionAdvertisingApp *_AppCurentForShow;


-(IBAction)btnSkipClick:(id)sender;
-(IBAction)btnAppStoreClick:(id)sender;
-(void)refreshContent;
-(void) setInformationAboutApp;
-(BOOL)isAdvertisingNeed;

@end
