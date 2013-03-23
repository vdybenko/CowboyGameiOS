//
//  ScrollView.m
//  Cowboy Duel
//
//  Created by Sergey Sobol on 06.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollViewSwitcher.h"
@interface ScrollViewSwitcher()
{
    CGPoint startPoint;
}
@end
@implementation ScrollViewSwitcher

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    startPoint = [[touches anyObject] locationInView:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint endPoint = [[touches anyObject] locationInView:self];
    
    if (abs(endPoint.x - startPoint.x) < 10){
//        Touch
    }
    else
    {
        if (endPoint.x > startPoint.x){}
//            right
        if (endPoint.x < startPoint.x){}
//            left
    }
    
    if (abs(endPoint.y - startPoint.y) < 5){
//        Touch
    }

}

-(void)switchObjectInDirection:(DirectionToAnimate)direction;
{}

@end