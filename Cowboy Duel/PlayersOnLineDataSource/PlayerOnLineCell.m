
#import "PlayerOnLineCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+Image+Title.h"
#import "Utils.h"
#import "UIView+Dinamic_BackGround.h"
#import "SSServer.h"
#import "DuelRewardLogicController.h"
@interface PlayerOnLineCell(){
    NSNumberFormatter *numberFormatter;
}
@end
@implementation PlayerOnLineCell

@synthesize backGround;
@synthesize icon;
@synthesize playerName;
@synthesize gold;
@synthesize goldTitle;
@synthesize btnDuel;
@synthesize status;
@synthesize indicatorConnectin;
@synthesize ribbon;
@synthesize userAttackTitle;
@synthesize userAtack;
@synthesize userDefenseTitle;
@synthesize userDefense;
@synthesize favoriteStart;

+(PlayerOnLineCell*) cell {
    @autoreleasepool {
        NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"OnLinePlayersCell" owner:nil options:nil];
        return [objects objectAtIndex:0];
    }
}

+(NSString*) cellID { return @"OnLinePlayersCell"; }

-(void) initMainControls {
    numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    UILabel *rankLevelCode=[[UILabel alloc] initWithFrame:CGRectMake(2, 21, 40 , 11)];
    rankLevelCode.font = [UIFont systemFontOfSize:10.0f];
    rankLevelCode.backgroundColor = [UIColor clearColor];
    rankLevelCode.textColor=[UIColor whiteColor];
    [rankLevelCode setTextAlignment:UITextAlignmentCenter];
    
    CGFloat angle = M_PI * -0.25;
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    rankLevelCode.transform = transform;
    rankLevelCode.text=@"TOP 10";
    [ribbon addSubview:rankLevelCode];
    
    rankLevelCode = nil;
    self.goldTitle.text = NSLocalizedString(@"Award:", "");
    self.goldTitle = nil;
    
    self.userAttackTitle.text = NSLocalizedString(@"Attack:", "");
    self.userAttackTitle = nil;
    
    self.userDefenseTitle.text = NSLocalizedString(@"Defense:", "");
    self.userDefenseTitle = nil;
    
    
    [btnDuel setTitleByLabel:@"DUEL" withColor:[UIColor colorWithRed:0.95 green:0.86 blue:0.68 alpha:1.0] fontSize:18];
    [backGround setDinamicHeightBackground];
}

-(void) populateWithPlayer:(SSServer *)player;
{    
    self.playerName.text=player.displayName;
    
    int moneyExch  = [player.money intValue]< 10 ? 1: [player.money intValue] / 10.0;
    self.gold.text = [NSString stringWithFormat:@"%d $",moneyExch];
  
    if([player.status isEqualToString: @"A"]){
        [btnDuel changeTitleByLabel:@"DUEL"];
        self.status.textColor = [UIColor blackColor];
        [self.btnDuel setEnabled:YES];
    }else {
        [btnDuel changeTitleByLabel:@"Busy"];
        self.status.textColor = [UIColor redColor];
        [self.btnDuel setEnabled:NO];
    }
    if (([player.serverName rangeOfString:@"F:"].location != NSNotFound))
    {
        [self.facebookAvatar setHidden:NO];
        NSMutableString *serverName = [player.serverName mutableCopy];
        [serverName replaceCharactersInRange:[player.serverName rangeOfString:@"F:"] withString:@""];
        self.facebookAvatar.profileID = serverName;
    } else {
        [self.facebookAvatar setHidden:YES];
    }
    
    userAtack.text = [NSString stringWithFormat:@"%d",player.weapon + [DuelRewardLogicController countUpBuletsWithPlayerLevel:[player.rank intValue]]];
    userAtack.hidden = NO;
    userAtack = nil;
    
    userDefense.text = [NSString stringWithFormat:@"%d",player.defense + [DuelRewardLogicController countUpBuletsWithPlayerLevel:[player.rank intValue]]];
    userDefense.hidden = NO;
    userDefense = nil;

    [self hideIndicatorConnectin];
    
    if (player.favorite) {
        favoriteStart.hidden = NO;
    }else{
        favoriteStart.hidden = YES;
    }
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated;
{
    [self setSelected:selected];
}

-(void)setSelected:(BOOL)selected;
{
    if (selected) {
        backGround.layer.masksToBounds = NO;
        backGround.layer.shadowColor = [[UIColor yellowColor] CGColor];
        backGround.layer.shadowOffset = CGSizeMake(0,1);
        backGround.layer.shadowRadius = 5;
        backGround.layer.shadowOpacity = 2;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                backGround.layer.masksToBounds = NO;
                backGround.layer.shadowColor = [[UIColor yellowColor] CGColor];
                backGround.layer.shadowOffset = CGSizeMake(0,1);
                backGround.layer.shadowRadius = 5;
                backGround.layer.shadowOpacity = 2;
            });
            
            [NSThread sleepForTimeInterval:0.4];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                 backGround.layer.shadowColor = [[UIColor clearColor] CGColor];
            });
        });
    }else {
        backGround.layer.shadowColor = [[UIColor clearColor] CGColor];
    }
}

-(void) setPlayerIcon:(UIImage*)iconImage;
{
    [icon setImage:iconImage];
}

-(void)showIndicatorConnectin;
{
    [indicatorConnectin startAnimating];
    NSArray *arr=[btnDuel subviews];
    UILabel *label1=(UILabel*)[arr objectAtIndex:([arr count]-2)];
    [label1 setHidden:YES];
}

-(void)hideIndicatorConnectin;
{
    [indicatorConnectin stopAnimating];
    NSArray *arr=[btnDuel subviews];
    UILabel *label1=(UILabel*)[arr objectAtIndex:([arr count]-2)];
    [label1 setHidden:NO];
}

-(void)setRibbonHide:(BOOL)hide;
{
    if (hide) {
        [ribbon setHidden:YES];
    }else {
        [ribbon setHidden:NO];
    }
}
@end
