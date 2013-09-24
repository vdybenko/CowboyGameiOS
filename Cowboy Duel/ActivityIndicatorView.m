//
//  MyClass.m
//  Bounty Hunter
//
//  Created by Taras on 17.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityIndicatorView.h"

@implementation ActivityIndicatorView

-(id)init{
    self = [super init];
    if (self) {
        UIView *hudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
        lbTopText=[[UILabel alloc]initWithFrame:CGRectMake(0, 10, 480, 150)];
        CGPoint center = lbTopText.center;
        center.x = hudView.center.x;
        lbTopText.center = center;
        
        [lbTopText setFont: [UIFont fontWithName: @"DecreeNarrow" size:80]];
        lbTopText.textAlignment = UITextAlignmentCenter;
        lbTopText.backgroundColor=[UIColor clearColor];
        [lbTopText setTextColor:[UIColor whiteColor]];
        [hudView addSubview:lbTopText];	
               
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicatorView.center = hudView.center;
        activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [activityIndicatorView startAnimating];
        
        [hudView addSubview:activityIndicatorView];	
        [self addSubview:hudView];
    }
    return self;
}

-(id)initWithoutRotate
{
    self = [super init];
    if (self) {
        UIView *hudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        	
        [self addSubview:hudView];
    }
    return self;
}


- (void)setText:(NSString *)text {  
    lbTopText.text=text;
}

- (void)showView{ 
    [self setHidden:NO];
    [ [self superview] setUserInteractionEnabled:NO];
}

- (void)hideView{  

    [self setHidden:YES];
    [ [self superview] setUserInteractionEnabled:YES];
}
@end
