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
        
        UIImage *spriteSheetDie = [UIImage imageNamed:@"opponentSpritSeet"];
        NSArray *arrayWithSpritesDie = [spriteSheetDie spritesWithSpriteSheetImage:spriteSheetDie inRange:NSRangeFromString(@"{0,4}")
                                                                        spriteSize:CGSizeMake(89, 161)];
        [imgDieOpponentAnimation setAnimationImages:arrayWithSpritesDie];
        [imgDieOpponentAnimation setAnimationRepeatCount:1];
        float animationDurationDie = [imgDieOpponentAnimation.animationImages count] * 0.100; 
        [imgDieOpponentAnimation setAnimationDuration:animationDurationDie];
        arrayWithSpritesDie = nil;
        
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

    float x = ivLifeBar.frame.size.width*100/oponentLiveImageViewStartWidth;
    lbLifeLeft.text = [NSString stringWithFormat:@"%d%%",(int)x];

    CGRect frameLife = lbLifeLeft.frame;
    frameLife.size.width = frame.size.width;
    lbLifeLeft.frame = frameLife;
    
}

-(void) refreshLiveBar;
{
    CGRect frame = ivLifeBar.frame;
    frame.size.width = oponentLiveImageViewStartWidth;
    ivLifeBar.frame = frame;
    lbLifeLeft.text =[NSString stringWithFormat:@"100%%"];
}

-(void) setStatusBody:(OpponentShapeStatus)status;
{
    opponentShapeStatus = status;
    switch (opponentShapeStatus) {
        case OpponentShapeStatusDead:
        {
            
            [self stopMoveAnimation];
            //imgBody.image = [UIImage imageNamed:@"menLowDie.png"];
            imgBody.hidden = YES;
            
            [imgDieOpponentAnimation startAnimating];
            
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
    switch (result) {
        case 0:
            [imgBody addFlyingPointToView:mainView centerPoint:p
                                                    text:@"-10"
                                                   color:color
                                                    font:font
                                               direction:FlyingPointDirectionUp];
            break;
        case 1:
            [imgBody addFlyingPointToView:mainView centerPoint:p
                                            text:@"-10"
                                           color:color
                                            font:font
                                       direction:FlyingPointDirectionUp];
            break;
        case 2:
            [imgBody addFlyingPointToView:mainView centerPoint:p
                                            text:@"-10"
                                           color:color
                                            font:font
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
