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
                                [UIImage imageNamed:@"barrelFrame2.png"], [UIImage imageNamed:@"barrelFrame3.png"],[UIImage imageNamed:@"barrelFrame4.png"],
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
        frame.origin.y +=frame.size.height;
        barellImg.frame = frame;
    }completion:^(BOOL complete){
        [UIView animateWithDuration:0.1f animations:^{
            CGRect frame = barellImg.frame;
            frame.origin.y -=30;
            barellImg.frame = frame;
        }completion:^(BOOL complete){
            [UIView animateWithDuration:0.1f animations:^{
                CGRect frame = barellImg.frame;
                frame.origin.y +=30;
                barellImg.frame = frame;
            }completion:^(BOOL complete){
               
            }];

        }];

    }];
}
-(void)releaseComponents
{
    barellView = nil;
    bonusImg = nil;
    barelAnimImg = nil;
}

@end
