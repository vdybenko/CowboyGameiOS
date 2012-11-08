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
{
    UILabel *buttonLabel;
}
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

-(void) initWithOutBackGround;
{
    UIColor *buttonsTitleColor = [[UIColor alloc] initWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    CGRect frame=buyProduct.frame;
    frame.origin.x=5;
    frame.origin.y=0;
    frame.size.width=frame.size.width-10;
    buttonLabel = [[UILabel alloc] initWithFrame:frame];
    [buttonLabel setFont: [UIFont fontWithName: @"DecreeNarrow" size:20]];
    buttonLabel.textAlignment = UITextAlignmentCenter;
    [buttonLabel setBackgroundColor:[UIColor clearColor]];
    [buttonLabel setTextColor:buttonsTitleColor];
    [buyProduct addSubview:buttonLabel];    
}

-(void) initMainControls;
{
    [self initWithOutBackGround];
    [backGround setDinamicHeightBackground];
}

-(void)populateWithProduct:(CDDuelProduct *)product targetToBuyButton:(id)delegate cellType:(StoreDataSourceTypeTables)cellType;
{
    buyButtonDelegate = delegate;
    buyProduct.hidden = NO;
    
    name.text = product.dName;
    if (cellType==StoreDataSourceTypeTablesDefenses) {
        effectTitle.text=NSLocalizedString(@"defenses", @"");
        effect.text =[NSString stringWithFormat:@"+%d",((CDDefenseProduct*)product).dDefense];
        
        buttonLabel.text = NSLocalizedString(@"BUYIT", @"");
    }else{
        effectTitle.text=NSLocalizedString(@"damage", @"");
        effect.text =[NSString stringWithFormat:@"+%d",((CDWeaponProduct*)product).dDamage];
        
        if (cellType == StoreDataSourceTypeTablesWeaponsTRY) {
            buttonLabel.text = NSLocalizedString(@"TRY_IT", @"");
        }else{
            if (product.dCountOfUse == 0) {
                buttonLabel.text = NSLocalizedString(@"BUYIT", @"");
            }else{
                if (product.dID == [AccountDataSource sharedInstance].curentIdWeapon) {
                    buyProduct.hidden = YES;
                }
                buttonLabel.text = NSLocalizedString(@"USE", @"");
            }
        }
    }
    descriptionText.text = [NSString stringWithFormat:@"%d %d",product.dCountOfUse, product.dID];//product.dDescription;
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
