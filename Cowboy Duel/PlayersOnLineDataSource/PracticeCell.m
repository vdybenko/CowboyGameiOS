
#import "PracticeCell.h"
#import "UIButton+Image+Title.h"

@implementation PracticeCell

@synthesize btnDuel;

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
    [label1 setFont: [UIFont fontWithName: @"DecreeNarrow" size:30]];
    label1.textAlignment = UITextAlignmentCenter;
    [label1 setBackgroundColor:[UIColor clearColor]];
    [label1 setTextColor:[UIColor colorWithRed:0.95 green:0.86 blue:0.68 alpha:1.0]];
    [label1 setText:NSLocalizedString(@"PRAC",@"")];
    [btnDuel addSubview:label1];
}

@end
