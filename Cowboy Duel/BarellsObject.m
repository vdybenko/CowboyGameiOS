//
//  BarellsObject.m
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 21.03.13.
//
//

#import "BarellsObject.h"
#import "UIImage+Sprite.h"
#import <AVFoundation/AVFoundation.h>

#import "UIView+ColorOfPoint.h"

@interface BarellsObject ()
{
    AVAudioPlayer *explosinPlayer;

}
@end

@implementation BarellsObject
@synthesize bonusImg;
@synthesize barellView;
@synthesize barelAnimImg;
@synthesize barellPosition;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if(self){
            NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"Barrles" owner:self options:nil];
            UIView *nibView = [objects objectAtIndex:0];
            [self addSubview:nibView];
            
            NSString *soundName = @"barellExplosionEfect";
            NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
            NSURL *soundFile = [NSURL fileURLWithPath:soundPath];
            NSError *error;
            explosinPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFile error:&error];
            [explosinPlayer prepareToPlay];
        
        NSArray *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"barrelFrame1.png"],
                                [UIImage imageNamed:@"barrelFrame2.png"], [UIImage imageNamed:@"barrelFrame3.png"],[UIImage imageNamed:@"barrelFrame4.png"],[UIImage imageNamed:@"barrelFrame5.png"],
                                nil];
        barelAnimImg.animationImages = imgArray;
        barelAnimImg.animationDuration = 0.3f;
        [barelAnimImg setAnimationRepeatCount:1];
        imgArray = nil;
    }
    return self;
}

-(void)explosionAnimation;
{
    if ([barelAnimImg isAnimating]) {
        [barelAnimImg stopAnimating];
        [barelAnimImg setHidden:YES];
        
    }
    CGRect frame;
    switch (self.barellPosition) {
        case BarellPositionBottom:
            frame = self.barellImgBottom.frame;
            barelAnimImg.frame = frame;
            self.barellImgBottom.hidden = YES;
            if (!self.barellImgMiddle.hidden) {
                [self dropBarel:self.barellImgMiddle];
        }
            
            if (!self.barellImgHighest.hidden) {
                [self dropBarel:self.barellImgHighest];
            }
            break;
            
        case BarellPositionMiddle:
            frame = self.barellImgMiddle.frame;
            barelAnimImg.frame = frame;
            
            self.barellImgMiddle.hidden = YES;
            if (!self.barellImgHighest.hidden) {
                [self dropBarel:self.barellImgHighest];
            }
            break;
            
        case BarellPositionHighest:
            frame = self.barellImgHighest.frame;
            barelAnimImg.frame = frame;
            self.barellImgHighest.hidden = YES;
            break;
            
        default:
            break;
    }
    barelAnimImg.hidden = NO;
    [barelAnimImg startAnimating];
   
    [self performSelector:@selector(hideObj) withObject:nil afterDelay:0.7f];

}
-(void)hideObj{
    //[explosinPlayer stop];
    [barelAnimImg stopAnimating];
    barelAnimImg.hidden = YES;
//    [self showBonus];

}
-(void)showBonus;
{
    bonusImg.frame = barelAnimImg.frame;
    bonusImg.hidden = NO;
    bonusImg.alpha = 1;
    [UIView animateWithDuration:0.7 animations:^{
        bonusImg.alpha = 0;
        CGRect frame = bonusImg.frame;
        frame.origin.y -= 100;
        bonusImg.frame = frame;
    }completion:^(BOOL complete){
        bonusImg.hidden = YES;
    }];
}

-(BOOL) isShownBonus
{
    return NO;
    //    int luck = arc4random()%2;
    //    return (luck == 2);
}

-(void)dropBarel:(UIImageView *)barellImg;{
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = barellImg.frame;
        frame.origin.y +=60;
        barellImg.frame = frame;
    }completion:^(BOOL complete){
        [UIView animateWithDuration:0.1f animations:^{
            CGRect frame = barellImg.frame;
            frame.origin.y -=10;
            barellImg.frame = frame;
        }completion:^(BOOL complete){
            [UIView animateWithDuration:0.1f animations:^{
                CGRect frame = barellImg.frame;
                frame.origin.y +=10;
                barellImg.frame = frame;
            }completion:^(BOOL complete){
               
            }];

        }];

    }];
}

-(BOOL)shotInObstracleWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;
{
    CGRect convertBody;
    switch (self.barellPosition) {
        case BarellPositionHighest:
            convertBody = [[self.barellView superview] convertRect:self.barellImgHighest.frame toView:view];
            
            break;
            
        case BarellPositionMiddle:
            convertBody = [[self.barellView superview] convertRect:self.barellImgMiddle.frame toView:view];
            
            break;
            
        case BarellPositionBottom:
            convertBody = [[self.barellView superview] convertRect:self.barellImgBottom.frame toView:view];

            break;

        default:
            break;
    }
    if (!CGRectContainsPoint(convertBody, point)) {
        return NO;
    }
    
    BOOL shotInShape;
    
    CGPoint convertPoint = [view convertPoint:point toView:self.barellView];
    UIColor *color = [self.barellView colorOfPoint:convertPoint];
    shotInShape = (color != [color colorWithAlphaComponent:0.0f]);
    
    return shotInShape;
}

-(void)releaseComponents
{
    barellView = nil;
    bonusImg = nil;
    barelAnimImg = nil;
}

@end
