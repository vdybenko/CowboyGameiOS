//
//  VisualStickView.m
//  SampleGame
//
//  Created by Zhang Xiang on 13-4-26.
//  Copyright (c) 2013年 Myst. All rights reserved.
//

#import "JoyStickView.h"

#define STICK_CENTER_TARGET_POS_LEN 20.0f
@interface JoyStickView()
{
    CGPoint dir;
}
@end

@implementation JoyStickView

@synthesize delegate;

-(void) initStick
{
    imgStickNormal = [UIImage imageNamed:@"stick_normal.png"];
    imgStickHold = [UIImage imageNamed:@"stick_hold.png"];
    stickView.image = imgStickNormal;
    mCenter.x = 64;
    mCenter.y = 64;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initStick];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
	{
        // Initialization code
        [self initStick];
    }
	
    return self;
}

- (void)dealloc {

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)notifyDir:(CGPoint)pDir
{
    NSValue *vdir = [NSValue valueWithCGPoint:pDir];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              vdir, @"dir", nil];
    
    [delegate onStickChanged:userInfo];
}

- (void)stickMoveTo:(CGPoint)deltaToCenter
{
    CGRect fr = stickView.frame;
    fr.origin.x = deltaToCenter.x;
    fr.origin.y = deltaToCenter.y;
    stickView.frame = fr;
}

- (void)touchEvent:(NSSet *)touches
{

    if([touches count] != 1)
        return ;
    
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    if(view != self)
        return ;
    
    CGPoint touchPoint = [touch locationInView:view];
    CGPoint dtarget;
    dir.x = touchPoint.x - mCenter.x;
    dir.y = touchPoint.y - mCenter.y;
    
    double len = sqrt(dir.x * dir.x + dir.y * dir.y);

    if(len < 4.0 && len > -4.0)
    {
        // center pos
        dtarget.x = 0.0;
        dtarget.y = 0.0;
        dir.x = 0;
        dir.y = 0;
    }
    else
    {
        dir.x = dir.x/(stickView.frame.size.width/2);
        dir.y = dir.y/(stickView.frame.size.height/2);
        
        if (dir.x>1) {
            dir.x = 1;
        }else if (dir.x<-1) {
            dir.x = -1;
        }
        
        if (dir.y>1) {
            dir.y = 1;
        }else if (dir.y<-1) {
            dir.y = -1;
        }

        dtarget.x = dir.x * STICK_CENTER_TARGET_POS_LEN;
        dtarget.y = dir.y * STICK_CENTER_TARGET_POS_LEN;
        
    }
    
    [self stickMoveTo:dtarget];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    stickView.image = imgStickHold;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchEvent:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    stickView.image = imgStickNormal;
    CGPoint dtarget;
    dtarget.x = 0.0;
    dtarget.y = 0.0;
    dir.x = 0;
    dir.y = 0;
    [self stickMoveTo:dtarget];
}

-(CGPoint)getDirectPoint;
{
    return dir;
}
@end
