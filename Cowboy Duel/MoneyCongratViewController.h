//
//  MoneyCongratViewController.h
//  Cowboy Duel 1
//
//  Created by AlexandrBezpalchuk on 02.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
#import "DuelViewController.h"
#import "ActivityIndicatorView.h"

@interface MoneyCongratViewController : UIViewController
{
    AccountDataSource *playerAccount;
    ActivityIndicatorView *activityIndicatorView;
    
    NSString *moneyLabel;
    
    double angle;
    
    BOOL runAnimation;
    
//images to animate:     
    IBOutlet UIImageView *ivAchieveRing;
    IBOutlet UIImageView *ivLight;
    IBOutlet UIImageView *ivLight2;
    IBOutlet UIImageView *ivRing;
    
//labels:        
    IBOutlet UILabel *lbTitleCongratulation;
    
    IBOutlet UILabel *lbPlusMoney;   
    IBOutlet UILabel *lbCongMainText;

    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnTryAgain;
    IBOutlet UIButton *btnPost;

    IBOutlet UILabel *lbPostOnFB;
}

- (id) initForAchivmentPlayerAccount:(AccountDataSource *)pPlayerAccount withLabel:(NSString*)pLabel andController:(id)delegateController;
@property(nonatomic, strong)id<DuelViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIImageView *ivLight2;

- (IBAction)btnMenuClicked:(id)sender;
- (IBAction)btnAgainClicked:(id)sender;
- (IBAction)btnPostOnFBClicked:(id)sender;

-(void)newLevelClick;
+(void)achivmentMoney:(NSUInteger)money;



@end
