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
#import <QuartzCore/QuartzCore.h>
#import "BBCyclingLabel.h"

@interface StoreProductCell()
{
    UILabel *buttonLabel;
    UILabel *ribbonLabel;
}
@property (weak,nonatomic) IBOutlet UIView * backGround;
@property (weak,nonatomic) IBOutlet UIImageView * icon;
@property (weak,nonatomic) IBOutlet UILabel * coldTitle;
@property (weak,nonatomic) IBOutlet UILabel * gold;
@property (weak,nonatomic) IBOutlet UILabel * effectTitle;
@property (weak,nonatomic) IBOutlet UILabel * effect;
@property (weak,nonatomic) IBOutlet UILabel * name;
@property (weak,nonatomic) IBOutlet UILabel * descriptionText;
@property (weak,nonatomic) IBOutlet BBCyclingLabel * countOfUse;
@property (weak,nonatomic) IBOutlet UIView * curentGunBlueBackground;
@property (weak,nonatomic) IBOutlet UIView * lockLevelBackground;
@property (weak,nonatomic) IBOutlet UILabel * lockLevelBackgroundTitle;
@property (weak,nonatomic) IBOutlet UIImageView * ribbonImage;


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
@synthesize countOfUse;
@synthesize buyButtonDelegate;
@synthesize curentGunBlueBackground;
@synthesize lockLevelBackground;
@synthesize lockLevelBackgroundTitle;
@synthesize ribbonImage;

+(StoreProductCell*) cell {
    @autoreleasepool {
        NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"StoreProductCell" owner:nil options:nil];
        return [objects objectAtIndex:0];
    }
}

+(NSString*) cellID { return @"StoreProductCell"; }

-(void) initWithOutBackGround;
{
    UIColor *buttonsTitleColor = [[UIColor alloc] initWithRed:240.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    CGRect frame=buyProduct.frame;
    frame.origin.x=5;
    frame.origin.y=0;
    frame.size.width=frame.size.width-10;
    @autoreleasepool {
        buttonLabel = [[UILabel alloc] initWithFrame:frame];
        [buttonLabel setFont: [UIFont fontWithName: @"DecreeNarrow" size:20]];
        buttonLabel.textAlignment = UITextAlignmentCenter;
        [buttonLabel setBackgroundColor:[UIColor clearColor]];
        [buttonLabel setTextColor:buttonsTitleColor];
        [buyProduct addSubview:buttonLabel];
        
        ribbonLabel=[[UILabel alloc] initWithFrame:CGRectMake(1, 21, 40 , 13)];
        ribbonLabel.font = [UIFont systemFontOfSize:11.0f];
        ribbonLabel.backgroundColor = [UIColor clearColor];
        ribbonLabel.textColor=[UIColor whiteColor];
        [ribbonLabel setTextAlignment:UITextAlignmentCenter];
        
        CGFloat angle = M_PI * -0.25;
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        ribbonLabel.transform = transform;
        [ribbonImage addSubview:ribbonLabel];
    }
    
    lockLevelBackground.clipsToBounds = YES;
    lockLevelBackground.layer.cornerRadius = 13.f;
    
    countOfUse.clipsToBounds = YES;
    countOfUse.layer.cornerRadius = 1.f;
    countOfUse.font = [UIFont systemFontOfSize:13];
    //countOfUse.transitionEffect = BBCyclingLabelTransitionEffectScrollUp;
    countOfUse.transitionDuration = 1.0;
    countOfUse.textColor = [UIColor colorWithWhite:1 alpha:1];
    countOfUse.transitionEffect = BBCyclingLabelTransitionEffectScrollUp;
    
    countOfUse.clipsToBounds = YES;
    
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
    ribbonImage.hidden = YES;
    curentGunBlueBackground.hidden = YES;
    
    name.text = product.dName;
    
    switch (cellType) {
        case StoreDataSourceTypeTablesDefenses:{
            effectTitle.text=NSLocalizedString(@"defenses", @"");
            effect.text =[NSString stringWithFormat:@"+%d",((CDDefenseProduct*)product).dDefense];
            
            buttonLabel.text = NSLocalizedString(@"BUYIT", @"");
            
            if (product.dCountOfUse == 0) {
                countOfUse.hidden = YES;
            }else{
                [countOfUse setText:[NSString stringWithFormat:@"x%d",product.dCountOfUse] animated:YES];
                countOfUse.hidden = NO;
            }

            break;
        }
        case StoreDataSourceTypeTablesWeapons:{
            effectTitle.text=NSLocalizedString(@"damage", @"");
            effect.text =[NSString stringWithFormat:@"+%d",((CDWeaponProduct*)product).dDamage];
            
            countOfUse.hidden = YES;
            
            if (product.dCountOfUse == 0 && product.dID!=-1) {
                buttonLabel.text = NSLocalizedString(@"BUYIT", @"");
            }else{
                if (product.dID == [AccountDataSource sharedInstance].curentIdWeapon) {
                    buyProduct.hidden = YES;
                    ribbonImage.hidden = NO;
                    ribbonLabel.text = NSLocalizedString(@"IN_HAND", @"");
                    curentGunBlueBackground.hidden = NO;
                }else{
                    buttonLabel.text = NSLocalizedString(@"USE", @"");
                    ribbonImage.hidden = NO;
                    ribbonLabel.text = NSLocalizedString(@"BOUGHT", @"");
                }
            }
            
            break;
        }
        case StoreDataSourceTypeTablesBarrier:{
            
            effectTitle.text=NSLocalizedString(@"defenses", @"");
            //effect.text =[NSString stringWithFormat:@"+%d",((CDDefenseProduct*)product).dDefense];
            
            buttonLabel.text = NSLocalizedString(@"BUYIT", @"");
            
            if (product.dCountOfUse == 0) {
                countOfUse.hidden = YES;
            }else{
                [countOfUse setText:[NSString stringWithFormat:@"x%d",product.dCountOfUse] animated:YES];
                countOfUse.hidden = NO;
            }
            
            break;
            
        }
        default:
            break;
    }
    
        
    if ([AccountDataSource sharedInstance].accountLevel<product.dLevelLock) {
        lockLevelBackground.hidden = NO;
        buyProduct.enabled = NO;
        if (product.dLevelLock == 4.0) {
            [lockLevelBackgroundTitle setFont:[UIFont boldSystemFontOfSize:13.0f]];
        }
        NSString *nameOfRank=[NSString stringWithFormat:@"%dRank",product.dLevelLock];
        lockLevelBackgroundTitle.text = [NSString stringWithFormat:@"Available for %@",NSLocalizedString(nameOfRank, @"")];
    }else{
        lockLevelBackground.hidden = YES;
        buyProduct.enabled = YES;
    }
    
    if (product.dPrice == 0) {
        coldTitle.text=NSLocalizedString(@"Price:", @"");
        gold.text = [NSString stringWithFormat:@"%@",product.dPurchasePrice];
//        if (product.dID == -1) {
//            [coldTitle setHidden:YES];
//            [gold setHidden:YES];
//        }
//        else{
//            [coldTitle setHidden:NO];
//            [gold setHidden:NO];
//        }
    }else{
        coldTitle.text=NSLocalizedString(@"Golds:", @"");
        gold.text = [NSString stringWithFormat:@"%d",product.dPrice];
        
        if ([AccountDataSource sharedInstance].money>product.dPrice) {
            buyProduct.enabled = YES;
        }else{
            if ((cellType==StoreDataSourceTypeTablesDefenses)||(product.dCountOfUse == 0)) buyProduct.enabled = NO;
        }
    }
    
    descriptionText.text = product.dDescription;
    icon.image = [UIImage loadImageFullPath:[NSString stringWithFormat:@"%@/%@",[DuelProductDownloaderController getSavePathForDuelProduct],product.dIconLocal]];
    if (product.dID == -1) {
        icon.image = [UIImage imageNamed:@"iconGun.png"];
    }    
}

- (IBAction)buyButtonClick:(id)sender {
    [buyButtonDelegate buyButtonClick:self];
}
@end
