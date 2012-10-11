
#import "PlayerOnLineCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+Image+Title.h"
#import "Utils.h"
#import "UIView+Dinamic_BackGround.h"
@interface PlayerOnLineCell(){
    NSNumberFormatter *numberFormatter;
}
@end
@implementation PlayerOnLineCell

@synthesize backGround;
@synthesize icon;
@synthesize playerName;
@synthesize gold;
@synthesize rank;
@synthesize btnDuel;
@synthesize status;
@synthesize indicatorConnectin;
@synthesize ribbon;

+(PlayerOnLineCell*) cell {
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"OnLinePlayersCell" owner:nil options:nil];
    return [objects objectAtIndex:0];
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
    
    [btnDuel setTitleByLabel:@"DUEL"];
    [btnDuel changeColorOfTitleByLabel:[UIColor colorWithRed:0.95 green:0.86 blue:0.68 alpha:1.0]];
    
    [backGround setDinamicHeightBackground];
}

-(void) populateWithPlayer:(CDPlayerOnLine *)player;
{
    [self setPlayerIcon:[UIImage imageNamed:@"pv_photo_default.png"]];
    
    self.playerName.text=player.dNickName;
    
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithInt:( player.dMoney)]];
    self.gold.text=[NSString stringWithFormat:@"money %@",formattedNumberString];
    
    NSString *nameOfRank=[NSString stringWithFormat:@"%dRank",player.dLevel];
    self.rank.text = NSLocalizedString(nameOfRank, @"");
    
    if(player.dOnline){
        self.status.text=NSLocalizedString(@"OnLine", @"");
        self.status.textColor = [UIColor blackColor];
    }else {
        self.status.text=NSLocalizedString(@"OffLine", @"");
        self.status.textColor = [UIColor redColor];
    }
    
    [self hideIndicatorConnectin];
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
