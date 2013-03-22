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


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if(self){
        @autoreleasepool {
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
        
               
    }
    return self;
}

-(void)explosionAnimation;
{
  
    //[explosinPlayer play];
    CGRect Frame = barellImg.frame;
    barelAnimImg.frame = Frame;
    barellImg.hidden = YES;
    UIImage *spriteSheetExp = [UIImage imageNamed:@"barelExp"];
    NSArray *arrayWithSpritesExp = [spriteSheetExp spritesWithSpriteSheetImage:spriteSheetExp
                                                                    spriteSize:CGSizeMake(75, 75)];
    [barelAnimImg setAnimationImages:arrayWithSpritesExp];
    [barelAnimImg setAnimationRepeatCount:1];
    [barelAnimImg setAnimationDuration:2];
    [barelAnimImg startAnimating];
   
    [self performSelector:@selector(hideObj) withObject:nil afterDelay:1.9f];
}
-(void)hideObj{
    //[explosinPlayer stop];
    [barelAnimImg stopAnimating];
    barelAnimImg.hidden = YES;
    [self showBonus];

}
-(BOOL)showBonus;
{
    //int luck = arc4random()%2;
   // if (luck == 2) {
    bonusImg.frame = barellImg.frame;
    bonusImg.hidden = NO;
    [UIView animateWithDuration:1.5 animations:^{
        bonusImg.alpha = 0;
        CGRect Frame = bonusImg.frame;
        Frame.origin.y -=100;
        bonusImg.frame = Frame;
    }completion:^(BOOL complete){
        bonusImg.hidden = YES;
    }];
   // [self releaseComponents];
    return YES;
    //}
}
-(void)dropBarel;{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect Frame = barellImg.frame;
        Frame.origin.y +=60;
        barellImg.frame = Frame;
    }completion:^(BOOL complete){
        [UIView animateWithDuration:0.1f animations:^{
            CGRect Frame = barellImg.frame;
            Frame.origin.y -=10;
            barellImg.frame = Frame;
        }completion:^(BOOL complete){
            [UIView animateWithDuration:0.1f animations:^{
                CGRect Frame = barellImg.frame;
                Frame.origin.y +=10;
                barellImg.frame = Frame;
            }completion:^(BOOL complete){

            }];

        }];

    }];
}
-(void)releaseComponents
{
    barellView = nil;
  //  barellImg = nil;
   //  bonusImg = nil;
}

@end
