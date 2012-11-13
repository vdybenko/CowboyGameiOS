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
    
    IBOutlet UIView *view;
    IBOutlet UIView *bodyView;
    IBOutlet UILabel *titleView;
    IBOutlet UIWebView *web Body;
    IBOutlet UIButton *_btnAppStore;
}
@property (strong) IBOutlet UIView *bodyView;
@property (strong) IBOutlet UILabel *titleView;
@property (strong) IBOutlet UIWebView *webBody;
@property (strong) IBOutlet UIButton *_btnAppStore;
@property (nonatomic) BOOL advertisingNeed;

-(IBAction)btnSkipClick:(id)sender;
-(IBAction)btnAppStoreClick:(id)sender;
-(id)initWithNib;
@end
