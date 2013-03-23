//
//  ScrollView.m
//  Cowboy Duel
//
//  Created by Sergey Sobol on 06.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define time 0.6

#import "ScrollViewSwitcher.h"
@interface ScrollViewSwitcher()
{
    CGPoint startPoint;
    UIImageView *leftImage;
    UIImageView *rightImage;
    UIImageView *centralImage;
    
    CGPoint ptLeftPosition;
    CGPoint ptCenterPosition;
    CGPoint ptRightPosition;
}
@end
@implementation ScrollViewSwitcher
@synthesize didFinishBlock;
@synthesize arraySwitchObjects;
@synthesize rectForObjetc;
@synthesize curentObject;

#pragma mark

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        curentObject = 0;
        [self setAllElementsHide:YES];
    }
    return self;
}

-(void)releaseComponents
{
    didFinishBlock = nil;
    arraySwitchObjects = nil;
    leftImage = nil;
    rightImage = nil;
    centralImage = nil;
}

-(void)setMainControls;
{
    ptLeftPosition = (CGPoint){0-rectForObjetc.size.width,0+rectForObjetc.origin.y};
    ptCenterPosition = (CGPoint){self.center.x-(rectForObjetc.size.width/2),0+rectForObjetc.origin.y};
    ptRightPosition = (CGPoint){self.frame.size.width,0+rectForObjetc.origin.y};
    
    leftImage = [[UIImageView alloc] initWithFrame:(CGRect){ptLeftPosition.x,ptLeftPosition.y,rectForObjetc.size.width,rectForObjetc.size.height}];
    leftImage.clipsToBounds = YES;
    leftImage.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:leftImage];
    
    rightImage = [[UIImageView alloc] initWithFrame:(CGRect){ptRightPosition.x,ptRightPosition.y,rectForObjetc.size.width,rectForObjetc.size.height}];
    rightImage.clipsToBounds = YES;
    rightImage.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:rightImage];
    
    centralImage = [[UIImageView alloc] initWithFrame:(CGRect){ptCenterPosition.x,ptCenterPosition.y,rectForObjetc.size.width,rectForObjetc.size.height}];
    centralImage.clipsToBounds = YES;
    centralImage.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:centralImage];
    
    [self setObjectsForIndex:curentObject];
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
        if (endPoint.x > startPoint.x){
            //            right
            [self switchToRight];
        }
        
        if (endPoint.x < startPoint.x){
            //            left
            [self switchToLeft];
        }
    }
    
    if (abs(endPoint.y - startPoint.y) < 5){
//        Touch
    }

}

#pragma mark

-(void)setObjectsForIndex:(NSInteger)index;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        centralImage.image = [UIImage imageNamed:[arraySwitchObjects objectAtIndex:index]];
        if (index) {
            leftImage.image = [UIImage imageNamed:[arraySwitchObjects objectAtIndex:index-1]];
        }
        if (index<[arraySwitchObjects count]-1) {
            rightImage.image = [UIImage imageNamed:[arraySwitchObjects objectAtIndex:index+1]];
        }
    });
}

-(void)switchToRight
{
    if (curentObject) {
        NSLog(@"right");
        [self setAllElementsHide:NO];
        [UIView animateWithDuration:time animations:^{
            CGRect frame = leftImage.frame;
            frame.origin = ptCenterPosition;
            leftImage.frame = frame;
            
            frame = centralImage.frame;
            frame.origin = ptRightPosition;
            centralImage.frame = frame;
        }completion:^(BOOL finished) {
            [self setAllElementsHide:YES];
            [self setStartPosition];
            curentObject--;
            [self setObjectsForIndex:curentObject];
            if (didFinishBlock) {
                didFinishBlock(curentObject);
            }
        }];
    }
}

-(void)switchToLeft
{
    if (curentObject<[arraySwitchObjects count]-1) {
        NSLog(@"left");
        [self setAllElementsHide:NO];
        [UIView animateWithDuration:time animations:^{
            CGRect frame = rightImage.frame;
            frame.origin = ptCenterPosition;
            rightImage.frame = frame;
            
            frame = centralImage.frame;
            frame.origin = ptLeftPosition;
            centralImage.frame = frame;
        }completion:^(BOOL finished) {
            [self setAllElementsHide:YES];
            [self setStartPosition];
            curentObject++;
            [self setObjectsForIndex:curentObject];
            if (didFinishBlock) {
                didFinishBlock(curentObject);
            }
        }];
    }
}

-(void)setStartPosition
{
    CGRect frame = leftImage.frame;
    frame.origin = ptLeftPosition;
    leftImage.frame = frame;
    
    frame = centralImage.frame;
    frame.origin = ptCenterPosition;
    centralImage.frame = frame;

    frame = rightImage.frame;
    frame.origin = ptRightPosition;
    rightImage.frame = frame;
}

-(void)setAllElementsHide:(BOOL)hide
{
    leftImage.hidden = hide;
    centralImage.hidden = hide;
    rightImage.hidden = hide;
}

-(void)switchObjectInDirection:(DirectionToAnimate)direction;
{}


@end