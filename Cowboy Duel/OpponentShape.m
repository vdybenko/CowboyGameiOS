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

static CGFloat oponentLiveImageViewStartWidth;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        @autoreleasepool {
            NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"OpponentShape" owner:self options:nil];
            UIView *nibView = [objects objectAtIndex:0];
            [self addSubview:nibView];
        }
        
        UIImage *spriteSheetSmoke = [UIImage imageNamed:@"smokeSpriteSheet"];
        NSArray *arrayWithSpritesSmoke = [spriteSheetSmoke spritesWithSpriteSheetImage:spriteSheetSmoke
                                                                            spriteSize:CGSizeMake(64, 64)];
        [imgShot setAnimationImages:arrayWithSpritesSmoke];
        
        float animationDurationSmoke = [imgShot.animationImages count] * 0.100; // 100ms per frame
        [imgShot setAnimationRepeatCount:1];
        [imgShot setAnimationDuration:animationDurationSmoke];
        
        oponentLiveImageViewStartWidth = ivLifeBar.frame.size.width;
        
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/oponent_shot.aif", [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        oponentShotAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [oponentShotAudioPlayer prepareToPlay];

    }
    return self;
}

-(void)releaseComponents
{
    vContainer = nil;
    imgBody = nil;
    imgShot = nil;
    ivLifeBar = nil;
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
    [self setStatusBody:OpponentShapeStatusLive];
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

-(void) changeLiveBarWithUserHitCount:(int)userHitCount maxShotCount:(int)maxShotCount;
{
    CGRect frame = ivLifeBar.frame;
    frame.size.width = (float)((maxShotCount - userHitCount)*oponentLiveImageViewStartWidth)/maxShotCount;
    ivLifeBar.frame = frame;
}

-(void) refreshLiveBar;
{
    CGRect frame = ivLifeBar.frame;
    frame.size.width = oponentLiveImageViewStartWidth;
    ivLifeBar.frame = frame;
}


-(void) setStatusBody:(OpponentShapeStatus)status;
{
    switch (status) {
        case OpponentShapeStatusDead:
            [self stopMoveAnimation];
            imgBody.image = [UIImage imageNamed:@"menLowDie.png"];
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
    ivHit.center = [mainView convertPoint:hitPoint toView:imgBody];
    [imgBody addSubview:ivHit];
    ivHit = nil;
}

-(void) cleareDamage;
{
    for(UIView *subview in [imgBody subviews])
    {
        [subview removeFromSuperview];
    }
}
@end
