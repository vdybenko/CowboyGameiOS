//
//  ScrollView.m
//  Cowboy Duel
//
//  Created by Sergey Sobol on 06.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollView.h"

@implementation ScrollView
@synthesize delegate;

-(id)initWithFrame:(CGRect)rect{
    self = [super initWithFrame:rect];
    if (self) {
        [self setUserInteractionEnabled:YES]; 
        [self setFrame:rect];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    startPoint = [[touches anyObject] locationInView:self];
    DLog(@"Point %f", startPoint.x);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint endPoint = [[touches anyObject] locationInView:self];
    
    DLog(@"Point %f %f", endPoint.x, startPoint.x);
    
    
    if (abs(endPoint.x - startPoint.x) < 10){ 
        DLog(@"Touch");
        if (startPoint.x < 148) 
            if([delegate respondsToSelector:@selector(clickLeftBtn)]) 
                [delegate clickLeftBtn];
        if (startPoint.x > 333)
            if([delegate respondsToSelector:@selector(clickRightBtn)]) 
            [delegate clickRightBtn];
    }
    else
    {
        DLog(@"Move");
        if (endPoint.x > startPoint.x)
            if([delegate respondsToSelector:@selector(clickLeftBtn)]) 
                [delegate clickLeftBtn];
        if (endPoint.x < startPoint.x)
            if([delegate respondsToSelector:@selector(clickRightBtn)]) 
                [delegate clickRightBtn];
    }
    
    if (abs(endPoint.y - startPoint.y) < 5){ 
        DLog(@"Touch");
        //        if (startPoint.x < 148) [delegate clickLeftBtn];
        //        if (startPoint.x > 333) [delegate clickRightBtn];
    }
    else{
        if (endPoint.y > startPoint.y){
        //            scrool show
            if([delegate respondsToSelector:@selector(scrollShow)]) 
                [delegate scrollShow];
        }
        else {
            //        scrool hide
            if([delegate respondsToSelector:@selector(scrollHide)]) 
                [delegate scrollHide];
        
        }
    }
    

}
@end