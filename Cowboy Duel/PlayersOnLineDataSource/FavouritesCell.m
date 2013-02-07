//
//  FavouritesCell.m
//  Bounty Hunter
//
//  Created by AlexandrBezpalchuk on 07.02.13.
//
//

#import "FavouritesCell.h"

#import <QuartzCore/QuartzCore.h>

#import "AccountDataSource.h"

#import "Utils.h"
#import "FXLabel.h"
#import "UIButton+Image+Title.h"
#import "UIView+Dinamic_BackGround.h"


@interface FavouritesCell()
{
    NSNumberFormatter *numberFormatter;
    FXLabel *rankNumber;
}
@end

@implementation FavouritesCell

UIColor * bronzeColor;
UIColor * brownColor;
UIColor * sandColor;

+(FavouritesCell *)cell
{
    @autoreleasepool {
        NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"FavouritesCell" owner:nil options:nil];
        return [objects objectAtIndex:0];
    }
}
+ (NSString *)cellID
{
    return @"FavouritesCell";
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

-(void) initMainControls {
    bronzeColor=[UIColor colorWithRed:0.596 green:0.525 blue:0.416 alpha:1];
    brownColor=[UIColor colorWithRed:0.38 green:0.267 blue:0.133 alpha:1];
    sandColor=[UIColor colorWithRed:1 green:0.917 blue:0.749 alpha:1];

    
    @autoreleasepool {
        rankNumber=[[FXLabel alloc] initWithFrame:_lbNum.frame];
        rankNumber.backgroundColor = [UIColor clearColor];
        [rankNumber setTextAlignment:UITextAlignmentCenter];
        [self addSubview:rankNumber];
    }
    

    _lbGoldTitle.text = NSLocalizedString(@"Gold:", @"");
    _lbAttackTitle.text = NSLocalizedString(@"Attack:", @"");
    _lbDefenseTitle.text = NSLocalizedString(@"Defense:", @"");

    [_btnGetHim setTitleByLabel:@"Poke"];
    
    [_vBackGround setDinamicHeightBackground];
    
    
}

-(void)populateWithPlayer:(CDFavPlayer *) player index:(NSIndexPath *)indexPath;
{
    _lbPlayerName.text=player.dNickName;
    
    
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:( player.dMoney)]];
    _lbGold.text=[NSString stringWithFormat:@"%@$",formattedNumberString];
    
    rankNumber.text=[NSString stringWithFormat:@"%d",indexPath.row+1];
    
    _lbDefense.text=[NSString stringWithFormat:@"%d",player.dDefense];
    
    
//  style
    [_ivBackGroundSelected setHidden:YES];
    [_ivIcon setBackgroundColor:[UIColor clearColor]];
    rankNumber.textColor=brownColor;
    _lbPlayerName.textColor=brownColor;
    _lbGoldTitle.textColor=bronzeColor;
    _lbGold.textColor=brownColor;
//
   
    if (indexPath.row<=9) {
        [self setLargeNumbers:YES];
    }else {
        [self setLargeNumbers:NO];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setPlayerIcon:(UIImage*)iconImage;
{
    [_ivIcon setImage:iconImage];
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
        rankNumber.textColor=brownColor;
        [rankNumber setGradientStartColor:rankNumber.textColor];
        [rankNumber setGradientEndColor:rankNumber.textColor];
    }
}

#pragma mark - 
#pragma mark IBActions:

- (IBAction)btnGetHimClicked:(id)sender {
    

}

@end
