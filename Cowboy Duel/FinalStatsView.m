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
#define kCountOfLevelsMinimal 0
#define kCountOfLevels 6
AccountDataSource *playerAccount;
FinalViewDataSource *finalViewDataSource;

int startMoney;
int startPoints;
int lbStartPoints;
int endMoney;
int endPoints;
int lbEndPoints;
FXLabel *lblGoldPlus;

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
        
        startMoney = finalViewDataSource.oldMoney;
        endMoney = playerAccount.money;
        NSLog(@"%d %d", startMoney, endMoney);
        
        NSArray *array=[DuelRewardLogicController getStaticPointsForEachLevels];
        NSInteger num = playerAccount.accountLevel;
        int  moneyForNextLevel=(playerAccount.accountLevel != kCountOfLevels)? [[array objectAtIndex:num] intValue]:playerAccount.accountPoints+1000;
        
        int moneyForPrewLevel;
        if (playerAccount.accountLevel==kCountOfLevelsMinimal) {
            moneyForPrewLevel = 0;
        }else
            if (playerAccount.accountLevel == kCountOfLevels) {
                moneyForPrewLevel = playerAccount.accountPoints;
            }
            else
            {
                moneyForPrewLevel=[[array objectAtIndex:(playerAccount.accountLevel-1)] intValue];
            }
        
        
        startPoints=(playerAccount.accountPoints-moneyForPrewLevel);
        endPoints=(moneyForNextLevel-moneyForPrewLevel);

        
        lbStartPoints = finalViewDataSource.oldPoints;
        lbEndPoints = playerAccount.accountPoints;
        
//Labels:
        lblGold.shadowColor = [UIColor whiteColor];
        lblGold.shadowOffset=CGSizeMake(1.0, 1.0);
        lblGold.innerShadowColor = [UIColor whiteColor];
        lblGold.innerShadowOffset=CGSizeMake(1.0, 1.0);
        lblGold.shadowBlur = 1.0;
        
        lblGold.text = [NSString stringWithFormat:@"%d",startMoney];
        
        [lblGold setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
        [lblGoldTitle setFont:[UIFont fontWithName: @"DecreeNarrow" size:30]];
        
        lblGold.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
        lblGold.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
        lblGold.alpha = 0.3;
        
        [self coinCenter];
        
        CGRect goldCountCentered = lblGold.frame;
        goldCountCentered.origin.x = ivGoldCoin.frame.origin.x+ivGoldCoin.frame.size.width + 5;
        lblGold.frame = goldCountCentered;
        
//        lblPoints.text = [NSString stringWithFormat:@"%d", playerAccount.accountPoints];
        
        ivBlueLine.hidden = YES;
        
//Images of ranks:
        if (playerAccount.accountLevel >= kCountOfLevels){
            NSString *name = [NSString stringWithFormat:@"fin_img_%drank.png", kCountOfLevels];
            ivCurrentRank.image = [UIImage imageNamed:name];
        }
        else{
            NSString *name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel];
            ivCurrentRank.image = [UIImage imageNamed:name];
            name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel+1];
            ivNextRank.image = [UIImage imageNamed:name];
        }
        
        if (finalViewDataSource.userWon) {
            [finalViewDataSource winScene];
        }
        else
        {
            [finalViewDataSource loseScene];
        }
        [finalViewDataSource lastScene];
        
    }
    
    return self;
}

-(void)startAnimations;
{

    ivBlueLine.hidden = YES;

    lblPoints.text = [NSString stringWithFormat:@"%d",startPoints ];
    
    lblGoldPlus = [[FXLabel alloc] initWithFrame:lblGold.frame];
    lblGoldPlus.shadowColor = [UIColor whiteColor];
    lblGoldPlus.shadowOffset=CGSizeMake(1.0, 1.0);
    lblGoldPlus.innerShadowColor = [UIColor whiteColor];
    lblGoldPlus.innerShadowOffset=CGSizeMake(1.0, 1.0);
    lblGoldPlus.shadowBlur = 1.0;
    [lblGoldPlus setFont:[UIFont fontWithName: @"MyriadPro-Bold" size:45]];
    lblGoldPlus.gradientStartColor = [UIColor colorWithRed:255.0/255.0 green:181.0/255.0 blue:0.0/255.0 alpha:1.0];
    lblGoldPlus.gradientEndColor = [UIColor colorWithRed:255.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
    lblGoldPlus.backgroundColor = [UIColor clearColor];
    [self addSubview:lblGoldPlus];
    
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
        [self winAnimation];
    }
    else
    {
        [self loseAnimation];
    }
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

-(void)winAnimation
{
    lblGold.alpha = 0.3;
    lblGoldPlus.text = [NSString stringWithFormat:@"+%d", finalViewDataSource.moneyExch];
    
    CGRect moveGolds = lblGoldPlus.frame;
    moveGolds.origin = ivGoldCoin.frame.origin;
    
    CGAffineTransform goldPlusZoomIn = CGAffineTransformScale(lblGoldPlus.transform, 1.5, 1.5);
    CGAffineTransform goldPlusZoomOut = CGAffineTransformScale(lblGoldPlus.transform, 1, 1);
    CGAffineTransform goldCoinZoomIn = CGAffineTransformScale(ivGoldCoin.transform, 2, 2);
    CGAffineTransform goldCoinZoomOut = CGAffineTransformScale(ivGoldCoin.transform, 1, 1);
    
    [UIView animateWithDuration:1.5
                     animations:^{
                         lblGoldPlus.transform = goldPlusZoomIn;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              ivGoldCoin.transform = goldCoinZoomIn;
                                              lblGoldPlus.transform = goldPlusZoomOut;
                                              lblGoldPlus.frame = moveGolds;
                                          }completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.7
                                                               animations:^{
                                                                   ivGoldCoin.transform = goldCoinZoomOut;
                                                                   lblGoldPlus.alpha = 0;
                                                                   lblGold.alpha = 1;
                                                               } completion:^(BOOL finished) {
                                                                   [self finalAnimation];
                                                               }];
                                          } ];
                     }];
    
}

-(void)loseAnimation
{
    lblGold.alpha = 0.3;
    lblGoldPlus.text = [NSString stringWithFormat:@"-%d", finalViewDataSource.moneyExch];
    
    CGRect coinFrame = lblGoldPlus.frame;
    coinFrame.origin = ivGoldCoin.frame.origin;
    lblGoldPlus.frame = coinFrame;
    
    CGRect moveGolds = lblGold.frame;
    
    CGAffineTransform goldPlusZoomIn = CGAffineTransformScale(lblGoldPlus.transform, 1.5, 1.5);
    CGAffineTransform goldPlusZoomOut = CGAffineTransformScale(lblGoldPlus.transform, 1, 1);
    CGAffineTransform goldCoinZoomIn = CGAffineTransformScale(ivGoldCoin.transform, 2, 2);
    CGAffineTransform goldCoinZoomOut = CGAffineTransformScale(ivGoldCoin.transform, 1, 1);
    
    [UIView animateWithDuration:1.5
                     animations:^{
                         lblGoldPlus.transform = goldPlusZoomIn;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              ivGoldCoin.transform = goldCoinZoomIn;
                                              lblGoldPlus.transform = goldPlusZoomOut;
                                              lblGoldPlus.frame = moveGolds;
                                          }completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.5
                                                               animations:^{
                                                                   ivGoldCoin.transform = goldCoinZoomOut;
                                                                   lblGoldPlus.alpha = 0;
                                                                   lblGold.alpha = 1;
                                                               } completion:^(BOOL finished) {
                                                                   [self finalAnimation];
                                                               }];
                                          } ];
                     }];

}

-(void)finalAnimation{
    [UIView animateWithDuration:1.4f
                     animations:^{
                         [self animationWithLable:lblGold andStartNumber:startMoney andEndNumber:endMoney];
                         
                         [self changePointsLine:startPoints maxValue:endPoints animated:YES];
                         [self animationWithLable:lblPoints andStartNumber:lbStartPoints andEndNumber:lbEndPoints];
                         
                     } completion:^(BOOL finished) {

                     }];
}

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

-(void)changePointsLine:(int)points maxValue:(int ) maxValue animated:(BOOL)animated;
{
    if (points <= 0) {
        ivBlueLine.hidden = YES;
        return;
    }
    
    CGRect backup = ivBlueLine.frame;
    CGRect temp = backup;
    temp.size.width = 0;
    ivBlueLine.frame = temp;
    if (points <= 0) points = 0;
    else ivBlueLine.hidden = NO;
    int firstWidthOfLine=lblPoints.frame.size.width;
    float changeWidth=(points*firstWidthOfLine)/maxValue;
    
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
    [activeDuelViewController.btnTry setEnabled:NO];
    LevelCongratViewController *lvlCongratulationViewController=[[LevelCongratViewController alloc] initForNewLevelPlayerAccount:playerAccount andController:activeDuelViewController tryButtonEnable:isTryAgainEnabled];
    [activeDuelViewController performSelector:@selector(showViewController:) withObject:lvlCongratulationViewController afterDelay:4.5];
}

-(void)showMessageOfMoreMoney:(NSInteger)money withLabel:(NSString *)labelForCongratulation
{
    [activeDuelViewController.btnTry setEnabled:NO];
    MoneyCongratViewController *moneyCongratulationViewController = [[MoneyCongratViewController alloc] initForAchivmentPlayerAccount:playerAccount withLabel:labelForCongratulation andController:activeDuelViewController tryButtonEnable:isTryAgainEnabled];
    [activeDuelViewController performSelector:@selector(showViewController:) withObject:moneyCongratulationViewController afterDelay:4.5];
}

@end