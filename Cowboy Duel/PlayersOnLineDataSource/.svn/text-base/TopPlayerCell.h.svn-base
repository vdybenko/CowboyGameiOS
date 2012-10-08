//
//  TopPlayerCell.h
//  Cowboy Duel 1
//
//  Created by Taras on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXLabel.h"

typedef enum {
	TopPlayerCellStatusSimple,
    TopPlayerCellStatusRed,
    TopPlayerCellStatusGold
} TopPlayerCellStatus;

@interface TopPlayerCell : UITableViewCell

@property (strong,nonatomic) UIImageView * Icon;
@property (strong,nonatomic) UIImageView * backGroundSelected;
@property (strong,nonatomic) UILabel * playerName;
@property (strong,nonatomic) UILabel * coldTitle;
@property (strong,nonatomic) UILabel * gold;
@property (strong,nonatomic) FXLabel * rankNumber;

@property (nonatomic)  TopPlayerCellStatus status;

//@property (strong,nonatomic) UIImageView * starFriend;



-(void) setPlayerIcon:(UIImage*)iconImage;
-(void)showIndicatorConnectin;
-(void)hideIndicatorConnectin;
-(void)setCellStatus:(TopPlayerCellStatus)status;
-(void)setLargeNumbers:(BOOL)largeNumbers;

//-(void)setStarSelected:(BOOL)starSelected;
@end
