//
//  UIButton+Image+Title.m
//  Cowboy Duel 1
//
//  Created by Taras on 05.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIButton+Image+Title.h"

@implementation UIButton (Hierarchy)
-(void)setImage:(NSString *)pImag title:(NSString *)pTitle;
{
    [self setImage:pImag];
    [self setTitleByLabel:pTitle];
}

-(void)setTitleByLabel:(NSString *)pTitle;
{    
    [self setTitleByLabel:pTitle withColor:[UIColor colorWithRed:0.243 green:0.2 blue:0.142 alpha:1] fontSize:24];
}

-(void)setTitleByLabel:(NSString *)pTitle withColor:(UIColor*)color fontSize:(CGFloat)size;
{
    CGRect frame=self.frame;
    frame.origin.x=10;
    frame.origin.y=0;
    frame.size.width=frame.size.width-20;
    UILabel *label1 = [[UILabel alloc] initWithFrame:frame];
    [label1 setFont: [UIFont fontWithName: @"DecreeNarrow" size:size]];
    label1.textAlignment = UITextAlignmentCenter;
    [label1 setBackgroundColor:[UIColor clearColor]];
    [label1 setTextColor:color];
    [label1 setText:NSLocalizedString(pTitle, @"")];
    [self addSubview:label1];
}

-(void)changeTitleByLabel:(NSString *)pTitle;
{
    NSArray *arr=[self subviews];
    UILabel *label1=(UILabel*)[arr objectAtIndex:([arr count]-1)];
    [label1 setText:NSLocalizedString(pTitle, @"")];
}

-(void)changeColorOfTitleByLabel:(UIColor *)pColor;
{
    NSArray *arr=[self subviews];
    UILabel *label1=(UILabel*)[arr objectAtIndex:([arr count]-1)];
    [label1 setTextColor:pColor];
}

-(void)setImage:(NSString *)pImag;
{
    UIImage *_img=[UIImage imageNamed:pImag];
    [self setBackgroundImage:_img forState:UIControlStateNormal];
    CGRect frame=self.frame;
    frame.size=_img.size;
    [self setFrame:frame];
}


@end
