//
//  UIImageView+AttachedView.m
//  Cowboy Duel 1
//
//  Created by Taras on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+AttachedView.h"

@interface UIImageView_AttachedView()
{
    BOOL runAnimation;
    float arrowDirection;
    float arrowLimitRight;
    float arrowLimitLeft;
    float amplitude;
    CGRect frameFirstPosition;
    UIView *parentView;
    
    float frequency;
    DirectionToAnimate  direction;
}
@end

@implementation UIImageView_AttachedView

- (id) initWithImage:(UIImage *)image attachedToFrame: (UIView *) pParentView frequence: (float ) freq amplitude: (float) pAmplitude direction: (DirectionToAnimate ) dDirection
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
  [UIView animateWithDuration:frequency
                        delay:0.0
                      options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     CGRect frame = self.frame;
                     
                     
                     if (frame.origin.x >= arrowLimitRight)  arrowDirection = -1;
                     if (frame.origin.x <= arrowLimitLeft)  arrowDirection = 1;
                     frame.origin.x += arrowDirection*amplitude;
                     self.frame = frame;

                   } completion:^(BOOL finished) {
                     if (runAnimation)
                       [self performSelector:@selector(arrowAnimation)];                    
                   }];
}
@end
