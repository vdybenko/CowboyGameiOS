//
//  LevelCongratViewController.h
//  Cowboy Duel 1
//
//  Created by AlexandrBezpalchuk on 02.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AccountDataSource.h"
#import "DuelViewController.h"
#import "ActivityIndicatorView.h"

@interface LevelCongratViewController : UIViewController
{
    AccountDataSource *playerAccount;
    ActivityIndicatorView *activityIndicatorView;
        
    int money;
    double angle;
    
    
    IBOutlet UIImageView *ivImageForLevel;
    
//images to animate:    
    IBOutlet UIImageView *ivLightRays;
    IBOutlet UIImageView *ivLightRays2;
    IBOutlet UIImageView *ivLevelRing;
    IBOutlet UIImageView *ivLevelCoint;
    
//labels:
    IBOutlet UILabel *lbTitleRankAchieve;

    IBOutlet UILabel *lbCongLvlMainText;
    IBOutlet UILabel *lbAgain;
    IBOutlet UILabel *lbMenu;
    IBOutlet UILabel *lbPostOnFB;
//buttons:
    IBOutlet UIButton *btnAgain;
    IBOutlet UIButton *btnMenu;
    IBOutlet UIButton *btnPost;
    BOOL runAnimation;
    
    
}
@property(nonatomic, strong)id<DuelViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIImageView *ivLightRays2;

- (id) initForNewLevelPlayerAccount:(AccountDataSource *)pPlayerAccount andController:(id)delegateController;

- (IBAction)btnMenuClicked:(id)sender;
- (IBAction)btnAgainClicked:(id)sender;
- (IBAction)btnPostOnFBClicked:(id)sender;
+(void)newLevelNumber:(NSInteger)level;

@end
