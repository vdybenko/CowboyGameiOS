//
//  ScrollView.m
//  Cowboy Duel
//
//  Created by Sergey Sobol on 06.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define time 0.4
#define kScrollViewSwitcherNotification @"ScrollViewSwitcherNotification"

#import "ScrollViewSwitcher.h"
#import <QuartzCore/QuartzCore.h>
#import "CDVisualViewCharacterPart.h"

@interface ScrollViewSwitcher()
{
    CGPoint startPoint;
    UIImageView *leftImage;
    UIImageView *rightImage;
    UIImageView *centralImage;
    
    CGPoint ptLeftPosition;
    CGPoint ptCenterPosition;
    CGPoint ptRightPosition;
    
    UIImage *newColorizeImage;
}
@end
@implementation ScrollViewSwitcher
@synthesize didFinishBlock;
@synthesize arraySwitchObjects;
@synthesize rectForObjetc;
@synthesize curentObject;
@synthesize colorizeImage;

#pragma mark

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        curentObject = 0;
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
    newColorizeImage = nil;
    colorizeImage = nil;
}

-(void)setMainControls;
{
    ptLeftPosition = (CGPoint){0-rectForObjetc.size.width,0+rectForObjetc.origin.y};
    ptCenterPosition = (CGPoint){self.center.x-(rectForObjetc.size.width/2),0+rectForObjetc.origin.y};
    ptRightPosition = (CGPoint){self.frame.size.width,0+rectForObjetc.origin.y};
    
    leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(ptLeftPosition.x,ptLeftPosition.y,rectForObjetc.size.width,rectForObjetc.size.height)];
    leftImage.clipsToBounds = YES;
    leftImage.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:leftImage];
    
    rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(ptRightPosition.x,ptRightPosition.y,rectForObjetc.size.width,rectForObjetc.size.height)];
    rightImage.clipsToBounds = YES;
    rightImage.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:rightImage];
    
    centralImage = [[UIImageView alloc] initWithFrame:CGRectMake(ptCenterPosition.x,ptCenterPosition.y,rectForObjetc.size.width,rectForObjetc.size.height)];
    centralImage.clipsToBounds = YES;
    centralImage.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:centralImage];
    
    [self setAllElementsHide:YES];
    [self setObjectsForIndex:curentObject];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    startPoint = [[touches anyObject] locationInView:self];
    [self touchView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
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

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouchView];
//    CGPoint endPoint = [[touches anyObject] locationInView:self];
//    
//    if (abs(endPoint.x - startPoint.x) < 10){
////        Touch
//    }
//    else
//    {
//        if (endPoint.x > startPoint.x){
//            //            right
//            [self switchToRight];
//        }
//        
//        if (endPoint.x < startPoint.x){
//            //            left
//            [self switchToLeft];
//        }
//    }
//    
//    if (abs(endPoint.y - startPoint.y) < 5){
////        Touch
//    }
}

#pragma mark

-(void)setObjectsForIndex:(NSInteger)index;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CDVisualViewCharacterPart *visualViewCharacterPart = [arraySwitchObjects objectAtIndex:index];
        centralImage.image = [visualViewCharacterPart imageForObject];
        if (index) {
            CDVisualViewCharacterPart *visualViewCharacterPartLeft = [arraySwitchObjects objectAtIndex:index-1];
            leftImage.image = [visualViewCharacterPartLeft imageForObject];
        }
        if (index<[arraySwitchObjects count]-1) {
            CDVisualViewCharacterPart *visualViewCharacterPartRight = [arraySwitchObjects objectAtIndex:index+1];
            rightImage.image = [visualViewCharacterPartRight imageForObject];
        }
    });
}

-(void)switchToRight
{
    if ((curentObject)&&([arraySwitchObjects count])) {
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
    if ((curentObject<[arraySwitchObjects count]-1)&&([arraySwitchObjects count])) {
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

-(void)trimObjectsToView:(UIView*)view;
{
    CGPoint trimRect = [[view superview] convertPoint:view.frame.origin toView:self];
    rectForObjetc.origin.y = trimRect.y;
}

-(void)touchView
{
    NSArray *imgArray = [NSArray arrayWithObjects:colorizeImage.image,
                         newColorizeImage,
                         nil];
    colorizeImage.animationImages = imgArray;
    colorizeImage.animationDuration = 0.6f;
    [colorizeImage setAnimationRepeatCount:0];
    [colorizeImage startAnimating];
}

-(void)endTouchView
{
    [colorizeImage stopAnimating];
}

@end