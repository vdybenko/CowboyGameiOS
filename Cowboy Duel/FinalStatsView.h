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

@interface FinalStatsView : UIView
@property (nonatomic,strong)     IBOutlet UIView *goldPointBgView;
@property (nonatomic,strong) IBOutlet UIView *ivGoldCoin;
@property (nonatomic,strong) IBOutlet UIImageView *ivBlueLine;
@property (nonatomic,strong) IBOutlet UIImageView *ivCurrentRank;
@property (nonatomic,strong) IBOutlet UIImageView *ivNextRank;
@property (nonatomic,strong) IBOutlet FXLabel *lblGold;
@property (nonatomic,strong) IBOutlet UILabel *lblPoints;
@property (nonatomic,strong) IBOutlet UILabel *lblGoldTitle;

- (id)initWithFrame:(CGRect)frame andAccount:(AccountDataSource *)acc;

- (void)startAnimationsWithDiffMoney: (int)moneyExch AndDiffPoints:(int)pointsExch;


@end
