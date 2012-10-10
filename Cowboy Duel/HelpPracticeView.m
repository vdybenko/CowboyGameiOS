//
//  HelpPracticeView.m
//  Cowboy Duel
//
//  Created by Sergey Sobol on 06.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpPracticeView.h"

@interface HelpPracticeView()
{
    UILabel *lbTopText;
    UILabel *lbBottomText;
    UIImageView *helpView;
}
@end

@implementation HelpPracticeView
-(id)init{
    self = [super init];
    if (self) {
        UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 480)];
        hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65];
        
        lbTopText=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 150)];
        
        [lbTopText setFont: [UIFont fontWithName: @"DecreeNarrow" size:30]];
        lbTopText.textAlignment = UITextAlignmentCenter;
        lbTopText.backgroundColor=[UIColor clearColor];
        [lbTopText setTextColor:[UIColor whiteColor]];
        [lbTopText setTextColor:[[UIColor alloc] initWithRed:0.819 green:0.709 blue:0.513 alpha:1]];
        [lbTopText setText:NSLocalizedString(@"LOWER", @"")];
        [hudView addSubview:lbTopText];
        [lbTopText setHidden:NO];
        
        helpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dv_arm.png"]];
        CGRect frame = helpView.frame;
       
        frame.origin.x +=50;
        frame.origin.y += 100;
        helpView.frame = frame;
        [hudView addSubview:helpView];
                
        [self addSubview:hudView];
    }
    return self;
}

@end
