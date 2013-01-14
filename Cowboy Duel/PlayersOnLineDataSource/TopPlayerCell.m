//
//  TopPlayerCell.m
//  Cowboy Duel 1
//
//  Created by Taras on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopPlayerCell.h"
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Dinamic_BackGround.h"
#import "AccountDataSource.h"

@interface TopPlayerCell()
{
    NSNumberFormatter *numberFormatter;
    FXLabel *rankNumber;
}
@property (strong,nonatomic) IBOutlet UILabel *rankNumberFake;
@end

@implementation TopPlayerCell

@synthesize backGround;
@synthesize icon;
@synthesize playerName;
@synthesize gold;
@synthesize coldTitle;
@synthesize rankNumberFake;
@synthesize backGroundSelected;
@synthesize status;

UIColor * bronzeColor;
UIColor * brownColor;
UIColor * sandColor;

+(TopPlayerCell*) cell {
    @autoreleasepool {
        NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"TopPlayersCell" owner:nil options:nil];
        return [objects objectAtIndex:0];
    }
}

+(NSString*) cellID { return @"TopPlayersCell"; }

-(void) initMainControls {
    bronzeColor=[UIColor colorWithRed:0.596 green:0.525 blue:0.416 alpha:1];
    brownColor=[UIColor colorWithRed:0.38 green:0.267 blue:0.133 alpha:1];
    sandColor=[UIColor colorWithRed:1 green:0.917 blue:0.749 alpha:1];
    
    numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    @autoreleasepool {
        rankNumber=[[FXLabel alloc] initWithFrame:rankNumberFake.frame];
        rankNumber.backgroundColor = [UIColor clearColor];
        [rankNumber setTextAlignment:UITextAlignmentCenter];
        [self addSubview:rankNumber];
    }
    
    coldTitle.text=NSLocalizedString(@"Gold:", @"");
    
    [backGround setDinamicHeightBackground];
}

-(void)populateWithPlayer:(CDTopPlayer *) player index:(NSIndexPath *)indexPath myIndex:(int)myProfileIndex;
{
    [self setPlayerIcon:[UIImage imageNamed:@"pv_photo_default.png"]];
    
    playerName.text=player.dNickName;
    
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:( player.dMoney)]];
    gold.text=[NSString stringWithFormat:@"money %@",formattedNumberString];
    
    rankNumber.text=[NSString stringWithFormat:@"%d",indexPath.row+1];
        
    if ((myProfileIndex!=-1)) {
        if (myProfileIndex==indexPath.row) {
            [self setCellStatus:TopPlayerCellStatusRed];
        }else {
            if (indexPath.row==0) {
                [self setCellStatus:TopPlayerCellStatusGold];
            }else {
                [self setCellStatus:TopPlayerCellStatusSimple];
            }
        }
    }else {
        if ([player.dAuth isEqualToString:[AccountDataSource sharedInstance].accountID]) {
            [self setCellStatus:TopPlayerCellStatusRed];
            myProfileIndex=indexPath.row;
        }else {
            if (indexPath.row==0) {
                [self setCellStatus:TopPlayerCellStatusGold];
            }else {
                [self setCellStatus:TopPlayerCellStatusSimple];
            }
        }
    }
    
    if (indexPath.row<=9) {
        [self setLargeNumbers:YES];
    }else {
        [self setLargeNumbers:NO];
    }
}

-(void) setPlayerIcon:(UIImage*)iconImage;
{
    [icon setImage:iconImage];
}

-(void)setCellStatus:(TopPlayerCellStatus)pStatus;
{
    status=pStatus;
    switch (pStatus) {
        case TopPlayerCellStatusSimple:
            [backGroundSelected setHidden:YES];
            [icon setBackgroundColor:[UIColor clearColor]];
            rankNumber.textColor=brownColor;
            playerName.textColor=brownColor;
            coldTitle.textColor=bronzeColor;
            gold.textColor=brownColor;
            break;
        case TopPlayerCellStatusRed:
            [backGroundSelected setImage:[UIImage imageNamed:@"topPlayerCell.png"]];
            [backGroundSelected setHidden:NO];
            [icon setBackgroundColor:[UIColor whiteColor]];
            rankNumber.textColor=[UIColor whiteColor];
            playerName.textColor=[UIColor whiteColor];
            coldTitle.textColor=sandColor;
            gold.textColor=[UIColor whiteColor];
            break;
        case TopPlayerCellStatusGold:
            [backGroundSelected setImage:[UIImage imageNamed:@"topPlayerGoldCell.png"]];
            [backGroundSelected setHidden:NO];
            rankNumber.textColor=brownColor;
            playerName.textColor=brownColor;
            coldTitle.textColor=bronzeColor;
            gold.textColor=brownColor;
            break;
        default:
            break;
    }
}

-(void)setLargeNumbers:(BOOL)largeNumbers;
{
    if (largeNumbers) {
        [rankNumber setAdjustsFontSizeToFitWidth:YES];
        [rankNumber setShadowColor:[UIColor colorWithRed:1.f green:253.f/255.f blue:178.f/255.f alpha:1]];
        [rankNumber setShadowOffset:CGSizeMake(0, 0)];
        rankNumber.shadowBlur=2.f;
        rankNumber.font = [UIFont fontWithName: @"MyriadPro-Bold" size:40];
        [rankNumber setGradientEndColor:[UIColor colorWithRed:1.0f green:140.f/255.f blue:0 alpha:1.0]];
        [rankNumber setGradientStartColor:[UIColor colorWithRed:1.0f green:181.f/255.f blue:0 alpha:1.0]];
        rankNumber.shadowOffset = CGSizeZero;
        rankNumber.innerShadowColor = [UIColor colorWithRed:137.f/255.f green:81.f/255.f blue:0.f alpha:1];
        rankNumber.innerShadowOffset = CGSizeMake(1.0f, 1.0f);
    }else {
        [rankNumber setAdjustsFontSizeToFitWidth:YES];
        [rankNumber setShadowColor:[UIColor clearColor]];
        rankNumber.innerShadowColor = rankNumber.shadowColor;
        [rankNumber setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        rankNumber.font = [UIFont fontWithName: @"MyriadPro-Bold" size:20];
        
        switch (status) {
            case TopPlayerCellStatusSimple:
                rankNumber.textColor=brownColor;
                break;
            case TopPlayerCellStatusRed:
                rankNumber.textColor=[UIColor whiteColor];
                break;
            case TopPlayerCellStatusGold:
                rankNumber.textColor=brownColor;
                break;
            default:
                break;
        }
        [rankNumber setGradientStartColor:rankNumber.textColor];
        [rankNumber setGradientEndColor:rankNumber.textColor];
    }
}
@end
