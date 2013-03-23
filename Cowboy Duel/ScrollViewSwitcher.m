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
        [self setBackgroundColor:[UIColor clearColor]];
        
        leftImage = [[UIImageView alloc] initWithFrame:(CGRect){0-rectForObjetc.size.width,0+rectForObjetc.origin.y,rectForObjetc.size.width,rectForObjetc.size.height}];
        leftImage.clipsToBounds = YES;
        leftImage.contentMode = UIViewContentModeScaleAspectFill;
        leftImage.hidden = YES;
        [self addSubview:leftImage];
        
        rightImage = [[UIImageView alloc] initWithFrame:(CGRect){self.frame.size.width,0+rectForObjetc.origin.y,rectForObjetc.size.width,rectForObjetc.size.height}];
        rightImage.clipsToBounds = YES;
        rightImage.contentMode = UIViewContentModeScaleAspectFill;
        rightImage.hidden = YES;
        [self addSubview:rightImage];
        
        centralImage = [[UIImageView alloc] initWithFrame:(CGRect){self.center.x-(rectForObjetc.size.width/2),0+rectForObjetc.origin.y,rectForObjetc.size.width,rectForObjetc.size.height}];
        centralImage.clipsToBounds = YES;
        centralImage.contentMode = UIViewContentModeScaleAspectFill;
        centralImage.hidden = YES;
        [self addSubview:centralImage];
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

#pragma mark

-(void)setObjectsForIndex:(NSInteger)index;
{
    if (index) {
        <#statements#>
    }else{
//        First object
        rightImage.image = [UIImage imageNamed:[arraySwitchObjects objectAtIndex:<#(NSUInteger)#>]];
    }
    curentObject = index;
}

-(void)switchToRight
{
    if (!curentObject) {
        [UIView animateWithDuration:time animations:^{
            
        }completion:^(BOOL finished) {
            
        }];
    }
}

-(void)switchToLeft
{
    [UIView animateWithDuration:time animations:^{
        
    }completion:^(BOOL finished) {
        
    }];
}

-(void)switchObjectInDirection:(DirectionToAnimate)direction;
{}


@end