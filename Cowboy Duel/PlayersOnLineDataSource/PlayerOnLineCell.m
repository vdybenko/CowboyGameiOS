
#import "PlayerOnLineCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+Image+Title.h"
#import "Utils.h"
#import "UIView+Dinamic_BackGround.h"
#import "SSServer.h"
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

-(void) populateWithPlayer:(SSServer *)player;
{
    [self setPlayerIcon:[UIImage imageNamed:@"pv_photo_default.png"]];
    
    self.playerName.text=player.displayName;
    
    NSString *formattedNumberString = [numberFormatter stringFromNumber:player.money];
    self.gold.text=[NSString stringWithFormat:@"money %@",formattedNumberString];
    
    NSString *nameOfRank=[NSString stringWithFormat:@"%@Rank",player.rank];
    self.rank.text = NSLocalizedString(nameOfRank, @"");
  NSLog(@"%@", player.status);
    if([player.status isEqualToString: @"A"]){
        self.status.text = NSLocalizedString(@"Available", @"");
        self.status.textColor = [UIColor blackColor];
        [self.btnDuel setEnabled:YES];
    }else {
        self.status.text=NSLocalizedString(@"Busy", @"");
        self.status.textColor = [UIColor redColor];
        [self.btnDuel setEnabled:NO];
    }
    
    [self hideIndicatorConnectin];
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
