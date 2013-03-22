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
    [explosinPlayer play];
    UIImage *spriteSheetExp = [UIImage imageNamed:@"barelExp3"];
    NSArray *arrayWithSpritesExp = [spriteSheetExp spritesWithSpriteSheetImage:spriteSheetExp
                                                                    spriteSize:CGSizeMake(74, 75)];
    [barellImg setAnimationImages:arrayWithSpritesExp];
    [barellImg setAnimationRepeatCount:1];
    [barellImg setAnimationDuration:1.5];
    [barellImg startAnimating];
    [self performSelector:@selector(hideObj) withObject:nil afterDelay:1.5f];
}
-(void)hideObj{
    [explosinPlayer stop];
    [barellImg stopAnimating];
    barellImg.hidden = YES;
    [self showBonus];

}
-(BOOL)showBonus;
{
    //int luck = arc4random()%2;
   // if (luck == 2) {
        bonusImg.hidden = NO;
    [UIView animateWithDuration:1 animations:^{
        bonusImg.alpha = 0;
    }completion:^(BOOL complete){
        bonusImg.hidden = YES;
    }];
    [self releaseComponents];
    return YES;
    //}
}
-(void)gettingShot;{

}
-(void)releaseComponents
{
    barellView = nil;
  //  barellImg = nil;
   //  bonusImg = nil;
}

@end
