//
//  FavouritesCell.h
//  Bounty Hunter
//
//  Created by AlexandrBezpalchuk on 07.02.13.
//
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
#import "CDFavPlayer.h"

@class FavouritesDataSource;

@interface FavouritesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView * vBackGround;

@property (weak, nonatomic) IBOutlet UIImageView * ivIcon;

@property (weak, nonatomic) IBOutlet UIButton *btnGetHim;

@property (weak, nonatomic) IBOutlet UILabel * lbGoldTitle;
@property (weak, nonatomic) IBOutlet UILabel * lbGold;
@property (weak, nonatomic) IBOutlet UILabel * lbPlayerName;
@property (weak, nonatomic) IBOutlet UILabel *lbNum;
@property (weak, nonatomic) IBOutlet UILabel *lbAttackTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbAttack;
@property (weak, nonatomic) IBOutlet UILabel *lbDefenseTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbDefense;



+(FavouritesCell*)cell;
+(NSString*) cellID;

-(void)populateWithPlayer:(CDFavPlayer *) player index:(NSIndexPath *)indexPath;
-(void) setPlayerIcon:(UIImage*)iconImage;
-(void) initMainControls;

@end
