//
//  AdvertisingNewViewController.h
//  Cowboy Duels
//
//  Created by Sergey Sobol on 05.11.12.
//
//

#import <UIKit/UIKit.h>
#import "CDCollectionAdvertisingApp.h"
#import "CollectionAppWrapper.h"
#import "UIButton+Image+Title.h"

@interface AdvertisingNewViewController : UIViewController
{
    CDCollectionAdvertisingApp *appCurentForShow;
    CollectionAppWrapper *collectionAppWrapper;
    
}
@property (nonatomic) BOOL advertisingNeed;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UIButton *btnAppStore;
@property (weak, nonatomic) IBOutlet UIWebView *webBody;

-(id)initWithNib;
- (IBAction)btnAppStoreClick:(id)sender;
@end
