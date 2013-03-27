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
@synthesize barellImg;
@synthesize bonusImg;
@synthesize barellView;
@synthesize barelAnimImg;
@synthesize isTop;
@synthesize isHighest;
@synthesize isBottom;


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
               
    }
    return self;
}

-(void)explosionAnimation;
{
  
    //[explosinPlayer play];
    if ([barelAnimImg isAnimating]) {
        return;
    }
    CGRect frame = barellImg.frame;
    barelAnimImg.frame = frame;
    barellImg.hidden = YES;
    UIImage *spriteSheetExp = [UIImage imageNamed:@"barelExp"];
    NSArray *arrayWithSpritesExp = [spriteSheetExp spritesWithSpriteSheetImage:spriteSheetExp
                                                                    spriteSize:CGSizeMake(75, 75)];
    [barelAnimImg setAnimationImages:arrayWithSpritesExp];
    [barelAnimImg setAnimationRepeatCount:1];
    [barelAnimImg setAnimationDuration:1];
    [barelAnimImg startAnimating];
   
    [self performSelector:@selector(hideObj) withObject:nil afterDelay:0.7f];
    
}
-(void)hideObj{
    //[explosinPlayer stop];
    [barelAnimImg stopAnimating];
    barelAnimImg.hidden = YES;
    [self showBonus];
    NSLog(@"Shot on barel");

}
-(void)showBonus;
{
    bonusImg.frame = barellImg.frame;
    bonusImg.hidden = NO;
    [UIView animateWithDuration:1.5 animations:^{
        bonusImg.alpha = 0;
        CGRect frame = bonusImg.frame;
        frame.origin.y -=100;
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

-(void)dropBarel;{
    
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
-(void)releaseComponents
{
    barellView = nil;
    barellImg = nil;
    bonusImg = nil;
    barelAnimImg = nil;
}

@end
