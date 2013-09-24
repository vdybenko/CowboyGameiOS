//
//  TopPlayerCell.h
//  Bounty Hunter 1
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
@property (weak,nonatomic) IBOutlet UIView * backGround;
@property (weak,nonatomic) IBOutlet UIImageView * icon;
@property (weak,nonatomic) IBOutlet UIImageView * backGroundSelected;
@property (weak,nonatomic) IBOutlet UILabel * coldTitle;
@property (weak,nonatomic) IBOutlet UILabel * gold;
@property (weak,nonatomic) IBOutlet UILabel * playerName;
@property (nonatomic)  TopPlayerCellStatus status;

+(TopPlayerCell*)cell;
+(NSString*) cellID;

-(void)populateWithPlayer:(CDTopPlayer *) player index:(NSIndexPath *)indexPath myIndex:(int)myProfileIndex;
-(void) initMainControls;
-(void) setPlayerIcon:(UIImage*)iconImage;
-(void)setCellStatus:(TopPlayerCellStatus)status;
@end
