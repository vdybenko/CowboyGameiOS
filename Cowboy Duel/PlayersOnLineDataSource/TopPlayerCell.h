//
//  TopPlayerCell.h
//  Cowboy Duel 1
//
//  Created by Taras on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXLabel.h"
#import "CDTopPlayer.h"

typedef enum {
	TopPlayerCellStatusSimple,
    TopPlayerCellStatusRed,
    TopPlayerCellStatusGold
} TopPlayerCellStatus;

@interface TopPlayerCell : UITableViewCell
@property (strong,nonatomic) IBOutlet UIView * backGround;
@property (strong,nonatomic) IBOutlet UIImageView * icon;
@property (strong,nonatomic) IBOutlet UIImageView * backGroundSelected;
@property (strong,nonatomic) IBOutlet UILabel * coldTitle;
@property (strong,nonatomic) IBOutlet UILabel * gold;
@property (strong,nonatomic) IBOutlet UILabel * playerName;
@property (nonatomic)  TopPlayerCellStatus status;

+(TopPlayerCell*)cell;
+(NSString*) cellID;

-(void)populateWithPlayer:(CDTopPlayer *) player index:(NSIndexPath *)indexPath myIndex:(int)myProfileIndex;
-(void) initMainControls;
-(void) setPlayerIcon:(UIImage*)iconImage;
-(void)setCellStatus:(TopPlayerCellStatus)status;
@end
