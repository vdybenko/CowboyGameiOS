
#import "PracticeCell.h"
#import "UIButton+Image+Title.h"

@implementation PracticeCell

@synthesize btnDuel;
@synthesize lbInvite;
@synthesize ivTargets;
@synthesize cellImg;
@synthesize bgInvite;
@synthesize bgPractice;

+(PracticeCell*) cell {
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"PracticaCell" owner:nil options:nil];
    return [objects objectAtIndex:0];
}

+(NSString*) cellID { return @"PracticaCell"; }

-(void) initMainControls {
    
    CGRect frame=btnDuel.frame;
    frame.origin.x=7;
    frame.origin.y=0;
    frame.size.width=frame.size.width-14;
    UILabel *label1 = [[UILabel alloc] initWithFrame:frame];
    [label1 setFont: [UIFont fontWithName: @"DecreeNarrow" size:18]];
    label1.textAlignment = UITextAlignmentCenter;
    [label1 setBackgroundColor:[UIColor clearColor]];
    [label1 setTextColor:[UIColor colorWithRed:0.95 green:0.86 blue:0.68 alpha:1.0]];
    [label1 setText:NSLocalizedString(@"PRAC",@"")];
    [btnDuel addSubview:label1];
    label1 = nil;
    
    [lbInvite setFont: [UIFont fontWithName: @"DecreeNarrow" size:30]];
    [lbInvite setText:NSLocalizedString(@"INVITE_FRIENDS_FB",@"")];
    

}

-(void) cellForPractice:(BOOL)practice;
{
    if (practice) {
        btnDuel.hidden = NO;
        ivTargets.hidden = NO;
        lbInvite.hidden = YES;
        // cellImg.image = [UIImage imageNamed:@"topPlayerCell_blue.png"];
        bgInvite.hidden = YES;
        bgPractice.hidden = NO;
    }else{
        btnDuel.hidden = YES;
        ivTargets.hidden = YES;
        lbInvite.hidden = NO;
        bgInvite.hidden = NO;
        bgPractice.hidden = YES;
       // cellImg.image = [UIImage imageNamed:@"topPlayerCell.png"];
    }
}
@end
