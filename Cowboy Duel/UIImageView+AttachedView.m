//
//  UIImageView+AttachedView.m
//  Cowboy Duel 1
//
//  Created by Taras on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+AttachedView.h"

@implementation UIImageView_AttachedView


- (id) initWithImage:(UIImage *)image attachedToFrame: (UIView *) pParentView frequence: (NSInteger ) freq amplitude: (NSInteger) pAmplitude direction: (DirectionToAnimate ) dDirection   
{
    self = [super initWithImage:image];
    if (self) {
        frequency = freq;
        direction = dDirection;
        parentView = pParentView; 
        amplitude = pAmplitude;
        
        [self setStartPosition];
    }
    return self;   
    
};

- (void)changeAttacheObject:(UIView *)pParentView;
{
    [self stopAnimation];
    [self setStartPosition];
    parentView = pParentView;
    [self setStartPosition];
    [self startAnimation];
}


-(void)setStartPosition
{

    frameFirstPosition = self.frame;

    frameFirstPosition.origin.y = parentView.center.y - frameFirstPosition.size.height/2;

    switch (direction) {
        case DirectionToAnimateLeft:
            frameFirstPosition.origin.x = parentView.frame.origin.x - frameFirstPosition.size.width;
            arrowLimitLeft = frameFirstPosition.origin.x - amplitude;
            arrowLimitRight = frameFirstPosition.origin.x; 
            arrowDirection = -1;
            break;
        case DirectionToAnimateRight:  
            frameFirstPosition.origin.x = parentView.frame.origin.x + parentView.frame.size.width;   
            arrowLimitLeft = frameFirstPosition.origin.x ;
            arrowLimitRight = frameFirstPosition.origin.x + amplitude; 
            arrowDirection = 1;
            CGAffineTransform revert = CGAffineTransformMakeRotation(-3.14);
            self.transform=revert;
            break;
        default:
            break;
    }

    self.frame = frameFirstPosition;
}
- (void) startAnimation 
{
    runAnimation=YES;
    [self arrowAnimation];
    
}

- (void) stopAnimation 
{
    runAnimation = NO;     
    self.frame = frameFirstPosition;
}



-(void)arrowAnimation
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES]; 
    [UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
    [UIView setAnimationDuration:frequency];
    [UIView setAnimationDelegate:self];
    
    
    CGRect frame = self.frame;   
    
    
    if (frame.origin.x >= arrowLimitRight)  arrowDirection = -1;
    if (frame.origin.x <= arrowLimitLeft)  arrowDirection = 1;
    frame.origin.x += arrowDirection;
    self.frame = frame;
  
    if (runAnimation) [UIView setAnimationDidStopSelector:@selector(arrowAnimation)];
    [UIView commitAnimations]; 
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
