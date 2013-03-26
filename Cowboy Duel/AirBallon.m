//
//  AirBallon.m
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 22.03.13.
//
//

#import "AirBallon.h"
#import "UIImage+Sprite.h"

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
    UIImage *spriteSheetExp = [UIImage imageNamed:@"explosionBarelSpriteSheet"];
    NSArray *arrayWithSpritesExp = [spriteSheetExp spritesWithSpriteSheetImage:spriteSheetExp
                                                                    spriteSize:CGSizeMake(75, 75)];
    [airBallonImg setAnimationImages:arrayWithSpritesExp];
    [airBallonImg setAnimationRepeatCount:1];
    [airBallonImg setAnimationDuration:1];
    [airBallonImg startAnimating];
    
    [self performSelector:@selector(hideObj) withObject:nil afterDelay:0.7f];

}
-(void)hideObj{
    //[explosinPlayer stop];
    [airBallonImg stopAnimating];
    airBallonImg.hidden = YES;
    [self showBonus];
}
-(void)showBonus;
{
//    bonusImg.frame = airBallonImg.frame;
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
