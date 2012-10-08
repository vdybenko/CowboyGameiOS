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


@implementation TopPlayerCell

@synthesize Icon;
@synthesize playerName;
@synthesize gold;
@synthesize coldTitle;
//@synthesize starFriend;
@synthesize rankNumber;
@synthesize backGroundSelected;
@synthesize status;

UIColor * bronzeColor;
UIColor * brownColor;
UIColor * sandColor;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setControlls];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //[self setControlls];
    
}
- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}





-(void) setControlls {
    
    //    background
    [self setBackgroundColor:[UIColor clearColor]];
    UIImage *imageBackGround=[UIImage imageNamed:@"view_dinamic_height.png"];
    CGRect mainFrame=CGRectMake(0, 0, 320, 78);
    CGRect frameToCrop;
    
    bronzeColor=[UIColor colorWithRed:0.596 green:0.525 blue:0.416 alpha:1];
    brownColor=[UIColor colorWithRed:0.38 green:0.267 blue:0.133 alpha:1];
    sandColor=[UIColor colorWithRed:1 green:0.917 blue:0.749 alpha:1];
    
    if ([Utils isiPhoneRetina]) {
        frameToCrop=CGRectMake(0, 0, 2*imageBackGround.size.width, 2*mainFrame.size.height);
    }else {
        frameToCrop=CGRectMake(0, 0, imageBackGround.size.width, mainFrame.size.height);
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageBackGround CGImage], frameToCrop);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    UIImageView *ivBody=[[UIImageView alloc] initWithImage:cropped];
    CGRect frame=CGRectMake(12, 2, imageBackGround.size.width, mainFrame.size.height);
    [ivBody setFrame:frame];
    
    [self addSubview:ivBody];
    CGImageRelease(imageRef);
    
    ivBody.layer.cornerRadius = 20.0;
    ivBody.layer.masksToBounds = YES;
        
    UIImageView *ivBottom=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"view_dinamic_height_bottom.png"]];
    CGRect frameBottom=ivBottom.frame;
    frameBottom.origin.x=frame.origin.x;
    frameBottom.origin.y=frame.origin.y+(frame.size.height-frameBottom.size.height);
    [ivBottom setFrame:frameBottom];
    [self addSubview:ivBottom];
    
    backGroundSelected=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topPlayerCell.png"]];
    frame=backGroundSelected.frame;
    frame.origin=CGPointMake(14 , 3);
    [backGroundSelected setFrame:frame];
    [self addSubview:backGroundSelected];
    
//  Number in list  
        
        rankNumber=[[FXLabel alloc] initWithFrame:CGRectMake(32, 25, 40 , 42)];
        rankNumber.backgroundColor = [UIColor clearColor];
        [rankNumber setTextAlignment:UITextAlignmentCenter];
        [self addSubview:rankNumber]; 

//  Icon
        Icon=[[UIImageView alloc] initWithFrame:CGRectMake(80, 20, 42, 42)];
        Icon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:Icon];
        
        UIImageView *iconFrame=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ls_OnLine_frame.png"]];
        frame=iconFrame.frame;
        frame.origin=CGPointMake(78, 18);
        [iconFrame setFrame:frame];
        [self addSubview:iconFrame];
//  Name
        playerName=[[UILabel alloc] initWithFrame:CGRectMake(132 , 25, 130, 16)];
        playerName.textColor = [UIColor blackColor];
        playerName.font = [UIFont systemFontOfSize:14.0f];
        playerName.backgroundColor = [UIColor clearColor];
        [playerName setTextAlignment:UITextAlignmentLeft];
        [self addSubview:playerName];   
//  Gold
        coldTitle=[[UILabel alloc] initWithFrame:CGRectMake(132, 46, 28, 11)];
        coldTitle.textColor = [UIColor blackColor];
        coldTitle.font = [UIFont systemFontOfSize:10.0f];
        coldTitle.backgroundColor = [UIColor clearColor];
        coldTitle.text=NSLocalizedString(@"Gold:", @"");
        [coldTitle setTextAlignment:UITextAlignmentLeft];
        [self addSubview:coldTitle];   
         
        gold=[[UILabel alloc] initWithFrame:CGRectMake(159, 46, 105 , 11)];
        gold.textColor = [UIColor blackColor];
        gold.font = [UIFont systemFontOfSize:10.0f];
        gold.backgroundColor = [UIColor clearColor];
        [gold setTextAlignment:UITextAlignmentLeft];
        [self addSubview:gold];  
//  Star will be in next version
//        starFriend=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topPlayerStar.png"]];
//        frame=starFriend.frame;
//        frame.origin=CGPointMake(265, 28);
//        [starFriend setFrame:frame];
//        [self addSubview:starFriend];
}

-(void) setPlayerIcon:(UIImage*)iconImage;
{
    [Icon setImage:iconImage];
}

-(void)showIndicatorConnectin;
{
    }

-(void)hideIndicatorConnectin;
{
    
}

-(void)setCellStatus:(TopPlayerCellStatus)pStatus;
{
    status=pStatus;
    switch (pStatus) {
        case TopPlayerCellStatusSimple:
            
            [backGroundSelected setHidden:YES];
            [Icon setBackgroundColor:[UIColor clearColor]];
            rankNumber.textColor=brownColor;
            playerName.textColor=brownColor;
            coldTitle.textColor=bronzeColor;
            gold.textColor=brownColor;
            break;
        case TopPlayerCellStatusRed:
            [backGroundSelected setImage:[UIImage imageNamed:@"topPlayerCell.png"]];
            [backGroundSelected setHidden:NO];
            [Icon setBackgroundColor:[UIColor whiteColor]];
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
