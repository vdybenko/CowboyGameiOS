//
//  TopPlayerCell.m
//  Cowboy Duel 1
//
//  Created by Taras on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreProductCell.h"
#import "Utils.h"
#import "UIView+Dinamic_BackGround.h"
#import "UIButton+Image+Title.h"
#import "DuelProductDownloaderController.h"
#import "UIImage+Save.h"

@interface StoreProductCell()
@property (strong,nonatomic) IBOutlet UIView * backGround;
@property (strong,nonatomic) IBOutlet UIImageView * icon;
@property (strong,nonatomic) IBOutlet UILabel * coldTitle;
@property (strong,nonatomic) IBOutlet UILabel * gold;
@property (strong,nonatomic) IBOutlet UILabel * effectTitle;
@property (strong,nonatomic) IBOutlet UILabel * effect;
@property (strong,nonatomic) IBOutlet UILabel * name;
@property (strong,nonatomic) IBOutlet UILabel * descriptionText;
@property (strong,nonatomic) IBOutlet UIButton * buyProduct;
@property (nonatomic) id buyButtonDelegate;
@end

@implementation StoreProductCell

@synthesize backGround;
@synthesize icon;
@synthesize name;
@synthesize gold;
@synthesize coldTitle;
@synthesize effectTitle;
@synthesize effect;
@synthesize descriptionText;
@synthesize buyProduct;
@synthesize buyButtonDelegate;

+(StoreProductCell*) cell {
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"StoreProductCell" owner:nil options:nil];
    return [objects objectAtIndex:0];
}

+(StoreProductCell*) cellAttension {
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"StoreProductAttensionCell" owner:nil options:nil];
    return [objects objectAtIndex:0];
}

+(NSString*) cellID { return @"StoreProductCell"; }

-(void) initWithOutBackGroundWithButtonText:(NSString*)text;
{
    UIColor *buttonsTitleColor = [[UIColor alloc] initWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    CGRect frame=buyProduct.frame;
    frame.origin.x=5;
    frame.origin.y=0;
    frame.size.width=frame.size.width-10;
    UILabel *label1 = [[UILabel alloc] initWithFrame:frame];
    [label1 setFont: [UIFont fontWithName: @"DecreeNarrow" size:20]];
    label1.textAlignment = UITextAlignmentCenter;
    [label1 setBackgroundColor:[UIColor clearColor]];
    [label1 setTextColor:buttonsTitleColor];
    [label1 setText:text];
    [buyProduct addSubview:label1];    
}

-(void) initMainControlsWithNarrowBackGround;
{
    [self initWithOutBackGroundWithButtonText:NSLocalizedString(@"TRY_IT", @"")];
}

-(void) initMainControls;
{
    [self initWithOutBackGroundWithButtonText:NSLocalizedString(@"BUYIT", @"")];
    [backGround setDinamicHeightBackground];
}

-(void)populateWithProduct:(CDDuelProduct *)product targetToBuyButton:(id)delegate cellType:(StoreDataSourceTypeTables)cellType;
{
    buyButtonDelegate = delegate;
    name.text = product.dName;
    if (cellType==StoreDataSourceTypeTablesDefenses) {
        effectTitle.text=NSLocalizedString(@"defenses", @"");
        effect.text =[NSString stringWithFormat:@"+%d",((CDDefenseProduct*)product).dDefense];
    }else{
        effectTitle.text=NSLocalizedString(@"damage", @"");
        effect.text =[NSString stringWithFormat:@"+%d",((CDWeaponProduct*)product).dDamage];
    }
    descriptionText.text = [NSString stringWithFormat:@"%d %d",product.dID,product.dCountOfUse];
    if (product.dPrice == 0) {
        coldTitle.text=NSLocalizedString(@"Price:", @"");
        gold.text = [NSString stringWithFormat:@"%d",product.dPrice];
        
        if ([AccountDataSource sharedInstance].money>product.dPrice) {
            buyProduct.enabled = YES;
        }else{
            buyProduct.enabled = NO;
        }
    }else{
        coldTitle.text=NSLocalizedString(@"Golds:", @"");
        gold.text = [NSString stringWithFormat:@"%d",product.dPrice];
    }
    
    icon.image = [UIImage loadImageFullPath:[NSString stringWithFormat:@"%@/%@",[DuelProductDownloaderController getSavePathForDuelProduct],product.dIconLocal]];
    
}

- (IBAction)buyButtonClick:(id)sender {
    [buyButtonDelegate buyButtonClick:self];
}
@end
