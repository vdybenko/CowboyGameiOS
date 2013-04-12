//
//  FinalStatsView.m
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 05.04.13.
//
//

#import "FinalStatsView.h"
#import "DuelRewardLogicController.h"
#import "UIView+Dinamic_BackGround.h"
#import "LevelCongratViewController.h"
#import "MoneyCongratViewController.h"

AccountDataSource *playerAccount;
FinalViewDataSource *finalViewDataSource;

int startMoney;
int startPoints;

int endMoney;
int endPoints;

@implementation FinalStatsView
@synthesize lblGold, lblGoldTitle, lblPoints;
@synthesize ivBlueLine, ivCurrentRank, ivNextRank, ivGoldCoin;
@synthesize goldPointBgView;
@synthesize activeDuelViewController;
@synthesize isTryAgainEnabled;

- (id)initWithFrame:(CGRect)frame andDataSource:(FinalViewDataSource *)fvDataSource;// andAccount:(AccountDataSource *)acc;
{
    self = [super initWithFrame:frame];

    if (self) {
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"FinalStatsView" owner:self options:nil];
        self = [subviewArray objectAtIndex:0];
        
        finalViewDataSource = fvDataSource;
        playerAccount = finalViewDataSource.playerAccount;
        isTryAgainEnabled = YES;
        [goldPointBgView setDinamicHeightBackground];
//Labels:
        lblGold.shadowColor = [UIColor whiteColor];
        lblGold.shadowOffset=CGSizeMake(1.0, 1.0);
        lblGold.innerShadowColor = [UIColor whiteColor];
        lblGold.innerShadowOffset=CGSizeMake(1.0, 1.0);
        lblGold.shadowBlur = 1.0;
        
        lblGold.text = [NSString stringWithFormat:@"%d",playerAccount.money];
        
        [lblGold setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
        [lblGoldTitle setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];
        
        lblGold.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
        lblGold.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
        
        [self coinCenter];
        
        CGRect goldCountCentered = lblGold.frame;
        goldCountCentered.origin.x = ivGoldCoin.frame.origin.x+ivGoldCoin.frame.size.width + 5;
        lblGold.frame = goldCountCentered;
        
        lblPoints.text = [NSString stringWithFormat:@"%d", playerAccount.accountPoints];
        
        ivBlueLine.hidden = YES;
        
//Images of ranks:
        if (playerAccount.accountLevel == kCountOfLevels){
            NSString *name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel];
            ivCurrentRank.image = [UIImage imageNamed:name];
        }
        else{
            NSString *name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel];
            ivCurrentRank.image = [UIImage imageNamed:name];
            name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel+1];
            ivNextRank.image = [UIImage imageNamed:name];
        }
    }
    return self;
}

-(void)startAnimations;
{
    startMoney = playerAccount.money;
    if (!finalViewDataSource.teaching) {
        endMoney = playerAccount.money+finalViewDataSource.moneyExch;
    }else
        endMoney = playerAccount.money;

    
    startPoints = finalViewDataSource.oldPoints;
    endPoints = playerAccount.accountPoints;

    ivBlueLine.hidden = NO;

    lblPoints.text = [NSString stringWithFormat:@"%d",startPoints ];
    NSArray *poi = [DuelRewardLogicController getStaticPointsForEachLevels];


    [UIView animateWithDuration:1.4f
                     animations:^{
                         [self animationWithLable:lblGold andStartNumber:startMoney andEndNumber:endMoney];
                         
                         if (![LoginAnimatedViewController sharedInstance].isDemoPractice) {
                             [self changePointsLine:endPoints maxValue:[poi objectAtIndex:(playerAccount.accountLevel+1)] animated:YES];
                         }
                         [self animationWithLable:lblPoints andStartNumber:startPoints andEndNumber:endPoints];
                         
                     } completion:^(BOOL finished) {
                         if (finalViewDataSource.reachNewLevel) {
                             [self showMessageOfNewLevel];
                             finalViewDataSource.reachNewLevel=NO;
                         }
                         
                         if (finalViewDataSource.userWon) {
                             if ((finalViewDataSource.oldMoney<500)&&(playerAccount.money>=500)&&(playerAccount.money<1000)) {
                                 NSString *moneyText=[NSString stringWithFormat:@"%d",playerAccount.money];
                                 [self showMessageOfMoreMoney:playerAccount.money withLabel:moneyText];
                             }else {
                                 int thousandOld=finalViewDataSource.oldMoney/1000;
                                 int thousandNew=playerAccount.money/1000;
                                 int thousandSecond=(playerAccount.money % 1000)/100;
                                 if (thousandNew>thousandOld) {
                                     if (thousandSecond==0) {
                                         [self showMessageOfMoreMoney:playerAccount.money withLabel:[NSString stringWithFormat:@"+%dK",thousandNew]];
                                     }else {
                                         [self showMessageOfMoreMoney:playerAccount.money withLabel:[NSString stringWithFormat:@"+%d.%dK",thousandNew,thousandSecond]];
                                     }
                                 }
                             }
                             finalViewDataSource.oldMoney=0;
                         }
                     }];
    

    
}

-(void)coinCenter
{
    ivGoldCoin.hidden = YES;
    CGRect coinCentered = ivGoldCoin.frame;
    coinCentered.origin.x = goldPointBgView.frame.size.width/2 - ivGoldCoin.frame.size.width - 10*lblGold.text.length;
    if (coinCentered.origin.x > 0)
        ivGoldCoin.frame = coinCentered;
    else
    {
        coinCentered.origin.x = 0;
        ivGoldCoin.frame = coinCentered;
    }
    ivGoldCoin.hidden = NO;
}

#pragma mark animations

-(void)animationWithLable:(UILabel *)lable andStartNumber:(int)startNumber andEndNumber:(int)endNumber
{
    float goldForGoldAnimation;
    if (abs(endNumber - startNumber) < 110) {
        goldForGoldAnimation = 1;
    }else {
        goldForGoldAnimation = abs(endNumber - startNumber)/110;
    }
    if (startNumber<endNumber)
        dispatch_async(dispatch_queue_create([lable.text cStringUsingEncoding:NSUTF8StringEncoding], NULL), ^{
            {
                for (int i = startNumber; i <= endNumber; i += goldForGoldAnimation) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        lable.text = [NSString stringWithFormat:@"%d", i];
                    });
                    
                    [NSThread sleepForTimeInterval:0.02];
                    
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    lable.text = [NSString stringWithFormat:@"%d", endNumber];
                });
                
            }
        });
    else
        dispatch_async(dispatch_queue_create([lable.text cStringUsingEncoding:NSUTF8StringEncoding], NULL), ^{
            for (int i = startNumber; i >= endNumber; i -= goldForGoldAnimation) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    lable.text = [NSString stringWithFormat:@"%d", i];
                });
                
                [NSThread sleepForTimeInterval:0.02];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                lable.text = [NSString stringWithFormat:@"%d", endNumber];
            });
        });
}

-(void)changePointsLine:(int)points maxValue:(NSNumber *) maxValue animated:(BOOL)animated;
{
    CGRect backup = ivBlueLine.frame;
    CGRect temp = backup;
    temp.size.width = 0;
    ivBlueLine.frame = temp;
    
    if (points <= 0) points = 0;
    int firstWidthOfLine=lblPoints.frame.size.width;
    float changeWidth=(points*firstWidthOfLine)/[maxValue intValue];
    
    temp.size.width = changeWidth;
    
    if (animated) {
        [UIView animateWithDuration:1.4 animations:^{
            ivBlueLine.frame = temp;
        }];
    } else {
        ivBlueLine.frame = temp;
    }
}
#pragma mark -

-(void)showMessageOfNewLevel
{
    LevelCongratViewController *lvlCongratulationViewController=[[LevelCongratViewController alloc] initForNewLevelPlayerAccount:playerAccount andController:activeDuelViewController tryButtonEnable:isTryAgainEnabled];
    [self performSelector:@selector(showViewController:) withObject:lvlCongratulationViewController afterDelay:4.5];
}

-(void)showMessageOfMoreMoney:(NSInteger)money withLabel:(NSString *)labelForCongratulation
{
    MoneyCongratViewController *moneyCongratulationViewController = [[MoneyCongratViewController alloc] initForAchivmentPlayerAccount:playerAccount withLabel:labelForCongratulation andController:activeDuelViewController tryButtonEnable:isTryAgainEnabled];
    [self performSelector:@selector(showViewController:) withObject:moneyCongratulationViewController afterDelay:4.5];
}

-(void)showViewController:(UIViewController *)viewController
{
    [activeDuelViewController presentModalViewController:viewController animated:YES];
    viewController = nil;
}

@end
