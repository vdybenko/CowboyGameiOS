//
//  FinalStatsView.h
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 05.04.13.
//
//

#import <UIKit/UIKit.h>
#import "FXLabel.h"
#import "AccountDataSource.h"
#import "FinalViewDataSource.h"
#import "ActiveDuelViewController.h"

@interface FinalStatsView : UIView
@property (nonatomic,strong) IBOutlet UIView *goldPointBgView;
@property (nonatomic,strong) IBOutlet UIView *ivGoldCoin;
@property (nonatomic,strong) IBOutlet UIImageView *ivBlueLine;
@property (nonatomic,strong) IBOutlet UIImageView *ivCurrentRank;
@property (nonatomic,strong) IBOutlet UIImageView *ivNextRank;
@property (nonatomic,strong) IBOutlet FXLabel *lblGold;
@property (nonatomic,strong) IBOutlet UILabel *lblPoints;
@property (nonatomic,strong) IBOutlet UILabel *lblGoldTitle;

@property (nonatomic,weak) ActiveDuelViewController *activeDuelViewController;

@property (nonatomic) BOOL isTryAgainEnabled;

- (id)initWithFrame:(CGRect)frame andDataSource: (FinalViewDataSource *)fvDataSource;

- (void)startAnimations;


@end
