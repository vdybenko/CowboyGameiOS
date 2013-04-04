//
//  AirBallon.m
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 22.03.13.
//
//

#import "AirBallon.h"
#import "UIImage+Sprite.h"
#import "UIView+ColorOfPoint.h"

@implementation AirBallon
@synthesize airBallonImg;
@synthesize airBalloonView;
@synthesize bonusImg;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if(self){
       
        NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"AirBalloon" owner:self options:nil];
        UIView *nibView = [objects objectAtIndex:0];
        [self addSubview:nibView];
        
        NSArray *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"exp1.png"],
                             [UIImage imageNamed:@"exp2.png"], [UIImage imageNamed:@"exp3.png"],[UIImage imageNamed:@"exp4.png"],[UIImage imageNamed:@"exp5.png"],[UIImage imageNamed:@"exp6.png"],[UIImage imageNamed:@"exp7.png"],
                             nil];
        airBallonImg.animationImages = imgArray;
        airBallonImg.animationDuration = 0.6f;
        [airBallonImg setAnimationRepeatCount:1];
        imgArray = nil;
        
        
    }
    return self;
}
-(void)airBallonMove{
    [UIView animateWithDuration:10 animations:^{
        CGRect frame = self.frame;
        frame.origin.x -=460;
        self.frame = frame;
    }completion:^(BOOL complete){
    
    }];
}
-(void)releaseComponents{

    airBalloonView = nil;
    airBallonImg = nil;
    bonusImg = nil;
}
-(void)explosionAnimation{
    if ([airBallonImg isAnimating]) {
        return;
    }
    CGRect frame = airBallonImg.frame;
    airBallonImg.frame = frame;
//    airBallonImg.hidden = YES;

    [airBallonImg startAnimating];
    
    [self performSelector:@selector(hideObj) withObject:nil afterDelay:0.5f];

}

-(BOOL)shotInObstracleWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;
{
    CGRect convertBody;
    convertBody = [[self.airBalloonView superview] convertRect:self.airBallonImg.frame toView:view];
    if (!CGRectContainsPoint(convertBody, point)) {
        return NO;
    }
    
    BOOL shotInShape;
    
    CGPoint convertPoint = [view convertPoint:point toView:self.airBalloonView];
    UIColor *color = [self.airBalloonView colorOfPoint:convertPoint];
    shotInShape = (color != [color colorWithAlphaComponent:0.0f]);
    
    return shotInShape;
}

-(void)hideObj{
 
    [airBallonImg stopAnimating];
    airBallonImg.hidden = YES;
    //[self showBonus];
}
-(void)showBonus;
{

    bonusImg.hidden = NO;
    [UIView animateWithDuration:1.5 animations:^{
        bonusImg.alpha = 0;
        CGRect frame = bonusImg.frame;
        frame.origin.y +=100;
        bonusImg.frame = frame;
    }completion:^(BOOL complete){
        bonusImg.hidden = YES;
    }];
}

-(BOOL) isShownBonus
{
    return YES;
//    int luck = arc4random()%2;
//    return (luck == 2);
}

@end
