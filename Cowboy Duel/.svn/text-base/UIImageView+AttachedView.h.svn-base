//
//  UIImageView+AttachedView.h
//  Cowboy Duel 1
//
//  Created by Taras on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    DirectionToAnimateLeft,
    DirectionToAnimateRight
} DirectionToAnimate;


@interface UIImageView_AttachedView : UIImageView
{
    BOOL runAnimation;
    int arrowDirection;
    int arrowLimitRight;
    int arrowLimitLeft;
    int amplitude;
    CGRect frameFirstPosition;
    UIView *parentView;
    
    NSInteger frequency;
    DirectionToAnimate  direction;
}

- (id) initWithImage:(UIImage *)image attachedToFrame: (UIView *) pParentView frequence: (NSInteger ) freq amplitude: (NSInteger) amplitude direction: (DirectionToAnimate ) dDirection ;  
- (void) changeAttacheObject:(UIView *)pParentView;
- (void) startAnimation;
- (void) stopAnimation;
- (void) arrowAnimation;


@end
