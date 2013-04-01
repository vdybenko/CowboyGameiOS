//
//  OpponentShape.m
//  Bounty Hunter
//
//  Created by Taras on 14.03.13.
//
//

#import "OpponentShape.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Sprite.h"
#import <AVFoundation/AVFoundation.h>
#import "UILabel+FlyingPoint.h"

@interface OpponentShape ()
{
    IBOutlet UIView *vContainer;
    AVAudioPlayer *oponentShotAudioPlayer;
}
@end

@implementation OpponentShape
@synthesize imgBody;
@synthesize imgShot;
@synthesize ivLifeBar;
@synthesize lbLifeLeft;
@synthesize opponentShapeStatus;
@synthesize imgDieOpponentAnimation;

static CGFloat oponentLiveImageViewStartWidth;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder subViewFromNibFileName:@"OpponentShape"];
    if(self){
        UIImage *spriteSheetSmoke = [UIImage imageNamed:@"smokeSpriteSheet"];
        NSArray *arrayWithSpritesSmoke = [spriteSheetSmoke spritesWithSpriteSheetImage:spriteSheetSmoke
                                                                            spriteSize:CGSizeMake(64, 64)];
        [imgShot setAnimationImages:arrayWithSpritesSmoke];
        
        float animationDurationSmoke = [imgShot.animationImages count] * 0.100; // 100ms per frame
        [imgShot setAnimationRepeatCount:1];
        [imgShot setAnimationDuration:animationDurationSmoke];
        
        NSArray *imgDieArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"menDieFrame1.png"], [UIImage imageNamed:@"menDieFrame1.png"],[UIImage imageNamed:@"menDieFrame1.png"],
                             [UIImage imageNamed:@"menDieFrame2.png"], [UIImage imageNamed:@"menDieFrame3.png"],[UIImage imageNamed:@"menDieFrame4.png"],[UIImage imageNamed:@"menDieFrame5.png"],[UIImage imageNamed:@"menDieFrame6.png"],[UIImage imageNamed:@"menDieFrame8.png"],
                             nil];
        
        imgDieOpponentAnimation.animationImages = imgDieArray;
        imgDieOpponentAnimation.animationDuration = 0.6f;
        [imgDieOpponentAnimation setAnimationRepeatCount:1];
        imgDieArray = nil;
        
        oponentLiveImageViewStartWidth = ivLifeBar.frame.size.width;
        
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/oponent_shot.aif", [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        oponentShotAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [oponentShotAudioPlayer prepareToPlay];
        
        opponentShapeStatus = OpponentShapeStatusLive;
    }
    return self;
    
}

-(void)releaseComponents
{
    vContainer = nil;
    imgBody = nil;
    imgShot = nil;
    ivLifeBar = nil;
    [imgDieOpponentAnimation stopAnimating];
    imgDieOpponentAnimation = nil;
    [oponentShotAudioPlayer stop];
    oponentShotAudioPlayer = nil;
    opponentShapeStatus = nil;
    lbLifeLeft = nil;
}

-(void) moveAnimation;
{
    
    NSArray *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"oponent_step1.png"],
                       [UIImage imageNamed:@"oponent_step2.png"],
                       nil];
    imgBody.animationImages = imgArray;
    imgBody.animationDuration = 0.6f;
    [imgBody setAnimationRepeatCount:0];
    [imgBody startAnimating];
    imgArray = nil;
}
-(void)moveOponentInBackground
{
    int randomDirection = rand() % 3 - 1;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.frame;
        frame.origin.x += randomDirection * 40;
        self.frame = frame;
    }completion:^(BOOL complete){
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.frame;
            frame.origin.x += randomDirection * 40;
            self.frame = frame;
        }completion:^(BOOL complete){
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = self.frame;
                frame.origin.x += randomDirection * 40;
                self.frame = frame;
            }completion:^(BOOL complete){
            }];
        }];
    }];
    if (randomDirection == 0) {
        [self stopMoveAnimation];
    }else{
        [self moveAnimation];
    }

}

-(void) stopMoveAnimation;
{
    [imgBody stopAnimating];
    if (opponentShapeStatus == OpponentShapeStatusLive) {
        [self setStatusBody:OpponentShapeStatusLive];
    }
}
-(void) shot;
{
    if ([imgShot isAnimating]) {
        [imgShot stopAnimating];
    }
    [imgShot startAnimating];
    
    [oponentShotAudioPlayer stop];
    [oponentShotAudioPlayer setCurrentTime:0.0];
    [oponentShotAudioPlayer performSelectorInBackground:@selector(play) withObject:nil];
}

-(void)reboundOnShot;
{
    CGPoint body = self.center;
    
    int randPosition = (rand() % 50) + 50;
    int direction = rand() % 2?-1:1;
    body.x = (body.x + direction*randPosition);
    
    [self moveAnimation];
    float duraction = (randPosition * 0.5)/100;
    [UIView animateWithDuration:duraction animations:^{
        self.center = body;
    }completion:^(BOOL complete){
        [self stopMoveAnimation];
    }];
}

-(void) changeLiveBarWithUserHitCount:(int)userHitCount maxShotCount:(int)maxShotCount;
{
    CGRect frame = ivLifeBar.frame;
    frame.size.width = (float)((maxShotCount - userHitCount)*oponentLiveImageViewStartWidth)/maxShotCount;
    ivLifeBar.frame = frame;

    int x = (maxShotCount - userHitCount);
    lbLifeLeft.text = [NSString stringWithFormat:@"%d",x];

    CGRect frameLife = lbLifeLeft.frame;
    frameLife.size.width = frame.size.width;
    lbLifeLeft.frame = frameLife;
    
}

-(void) refreshLiveBarWithLives: (int )lives;
{
    CGRect frame = ivLifeBar.frame;
    frame.size.width = oponentLiveImageViewStartWidth;
    ivLifeBar.frame = frame;
    lbLifeLeft.text =[NSString stringWithFormat:@"%d", lives];
}

-(void) setStatusBody:(OpponentShapeStatus)status;
{
    opponentShapeStatus = status;
    switch (opponentShapeStatus) {
        case OpponentShapeStatusDead:
        {
            
            [self stopMoveAnimation];
            imgBody.hidden = YES;
            [imgDieOpponentAnimation startAnimating];
            /*
            UIImageView *dieImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menLowDie.png"]];
            [self addSubview:dieImg];
            dieImg.frame = imgBody.frame;
            
            [UIView animateWithDuration:1 animations:^{
                CGRect frame = dieImg.frame;
                frame.origin.y -= 100;
                dieImg.frame = frame;
                dieImg.alpha = 0;
            }completion:^(BOOL complete){
                 
            }];*/
      
        
        }
            break;
        case OpponentShapeStatusLive:
            imgBody.image = [UIImage imageNamed:@"men_low.png"];
            break;
        default:
            break;
    }
}
-(void) hitTheOponentWithPoint:(CGPoint)hitPoint mainView:(UIView*)mainView;
{
    
    UIImageView *ivHit = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ivHit.png"]];
    CGPoint convertPoint = [mainView convertPoint:hitPoint toView:imgBody];
    ivHit.center = convertPoint;
    [imgBody addSubview:ivHit];
    ivHit = nil;

    int result = [imgBody checkNumberOfShotsAreas:@[@"{{0, 0}, {89,43}}", @"{{0,43}, {89,65}}", @"{{0,108}, {89,53}}"] forPoint:convertPoint];
    
    UIColor *color = [UIColor greenColor];
    UIFont *font = [UIFont boldSystemFontOfSize:22];
    CGPoint p= (CGPoint){44,-5};
    CGPoint p1 = (CGPoint){p.x, 8};
    switch (result) {
        case 0:
            [imgBody addFlyingPointToView:mainView centerPoint:p
                                                    text:@"-1"
                                                   color:color
                                                    font:font
                                               direction:FlyingPointDirectionUp];
            [imgBody addFlyingImageToView:mainView
                              centerPoint:p1
                                imageName:@"crossbones.png"
                                direction:FlyingPointDirectionUp];
            break;
        case 1:
            [imgBody addFlyingPointToView:mainView centerPoint:p
                                            text:@"-1"
                                           color:color
                                            font:font
                                       direction:FlyingPointDirectionUp];
            [imgBody addFlyingImageToView:mainView
                              centerPoint:p1
                                imageName:@"crossbones.png"
                                direction:FlyingPointDirectionUp];            
            break;
        case 2:
            [imgBody addFlyingPointToView:mainView centerPoint:p
                                            text:@"-1"
                                           color:color
                                            font:font
                                       direction:FlyingPointDirectionUp];
            [imgBody addFlyingImageToView:mainView
                              centerPoint:p1
                                imageName:@"crossbones.png"
                                direction:FlyingPointDirectionUp];            
            break;
        default:
            break;
    }
    
    [self reboundOnShot];
}

-(void) cleareDamage;
{
    for(UIView *subview in [imgBody subviews])
    {
        [subview removeFromSuperview];
    }
}
@end
