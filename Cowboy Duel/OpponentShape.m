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
#import "UIView+ColorOfPoint.h"

@interface OpponentShape ()
{
    IBOutlet UIView *vContainer;
    AVAudioPlayer *oponentShotAudioPlayer;
    CGPoint anchP;
    BOOL isMove;
    UIView *mainViewOfBody;
    __weak IBOutlet UIImageView *shotSmoke;
}
@end

@implementation OpponentShape
@synthesize imgBody;
@synthesize ivLifeBar;
@synthesize typeOfBody;
@synthesize lbLifeLeft;
@synthesize opponentShapeStatus;
@synthesize imgDieOpponentAnimation;
@synthesize playerAccount;
@synthesize visualViewCharacter;

static CGFloat oponentLiveImageViewStartWidth;

#pragma mark

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder subViewFromNibFileName:@"OpponentShape"];
    if(self){
        isMove = NO;
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
        
        //smoke animation
        NSArray *imgSmokeArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"smoke1.png"], [UIImage imageNamed:@"smoke2.png"],[UIImage imageNamed:@"smoke3.png"],[UIImage imageNamed:@"smoke4.png"], [UIImage imageNamed:@"smoke5.png"],[UIImage imageNamed:@"smoke6.png"],[UIImage imageNamed:@"smoke7.png"], nil];
        
        shotSmoke.animationImages = imgSmokeArray;
        shotSmoke.animationDuration = 0.6f;
        [shotSmoke setAnimationRepeatCount:1];
        [self addSubview:shotSmoke];
       
   
    }
    return self;
    
}

-(void)releaseComponents
{
    vContainer = nil;
    ivLifeBar = nil;
    [imgDieOpponentAnimation stopAnimating];
    imgDieOpponentAnimation = nil;
    [oponentShotAudioPlayer stop];
    oponentShotAudioPlayer = nil;
    opponentShapeStatus = nil;
    lbLifeLeft = nil;
    [visualViewCharacter releaseComponents];
    visualViewCharacter = nil;
    imgBody = nil;
}

#pragma mark

-(void)refreshWithAccountPlayer:(AccountDataSource*)player;
{
    playerAccount = player;
    [visualViewCharacter refreshWithAccountPlayer:playerAccount];
    [visualViewCharacter setGunFrontViewHidden:NO];
    imgBody.image = [visualViewCharacter imageFromCharacter];
    
}

-(void) moveAnimation;
{
//    if (self.typeOfBody == OpponentShapeTypeScarecrow) {
//        return;
//    }
//    NSArray *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"oponent_step1.png"],
//                       [UIImage imageNamed:@"oponent_step2.png"],
//                       nil];
//    imgBody.animationImages = imgArray;
//    imgBody.animationDuration = 0.6f;
//    [imgBody setAnimationRepeatCount:0];
//    [imgBody startAnimating];
//    imgArray = nil;
}

-(void)moveOponentInBackground
{
    if (self.typeOfBody == OpponentShapeTypeScarecrow) {
        return;
    }
    isMove = YES;
     [self walkOpponent];
    int randomDirection = rand() % 3 - 1;
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.center;
        center.x += randomDirection * 40;
        if((center.x>0) && (center.x<[self superview].frame.size.width)){
            self.center = center;
        }else{
            isMove = NO;
            return;
        }
    }completion:^(BOOL complete){
        [UIView animateWithDuration:0.2 animations:^{
            CGPoint center = self.center;
            center.x += randomDirection * 40;
            if((center.x>0) && (center.x<[self superview].frame.size.width)){
                self.center = center;
                
            }else{
                 isMove = NO;
                return;
            }

        }completion:^(BOOL complete){
            [UIView animateWithDuration:0.2 animations:^{
                CGPoint center = self.center;
                center.x += randomDirection * 40;
                if((center.x>0) && (center.x<[self superview].frame.size.width)){
                    self.center = center;
                }else{
                     isMove = NO;
                    return;
                }
            }completion:^(BOOL complete){
                isMove = NO;
            }];
        }];
    }];
    if (randomDirection == 0) {
         isMove = NO;
        [self stopMoveAnimation];
    }else{
        [self moveAnimation];
    }
    
}

-(void) stopMoveAnimation;
{
    if (opponentShapeStatus == OpponentShapeStatusLive) {
        [self setStatusBody:OpponentShapeStatusLive];
    }
}
-(void) shot;
{
    [oponentShotAudioPlayer stop];
    [oponentShotAudioPlayer setCurrentTime:0.0];
    [oponentShotAudioPlayer performSelectorInBackground:@selector(play) withObject:nil];
    [shotSmoke startAnimating];
}

-(void)reboundOnShot;
{
//    return;
    CGPoint body = self.center;
    int direction = rand() % 2?-1:1;
    int randPosition;
    
    if ( self.typeOfBody == OpponentShapeTypeScarecrow ){
        randPosition = rand() % (int)[self superview].frame.size.width;
        body.x = randPosition;
        if((body.x>0) && (body.x<[self superview].frame.size.width))self.center = body;
        [self setHidden:NO];
        return;
    }
    else
        randPosition = (rand() % 50) + 50;

    body.x += direction*randPosition;

    
    float duraction = (randPosition * 0.5)/100;
    [UIView animateWithDuration:duraction animations:^{
        if((body.x>0) && (body.x<[self superview].frame.size.width)) {
            self.center = body;
        }else{
            return;
        }

    }completion:^(BOOL complete){
        [self stopMoveAnimation];
    }];
    
    [self moveAnimation];
}

-(void)flip
{
    CGRect frame = self.frame;
    int y = frame.origin.y;
    frame.origin.y *=2;
    anchP = self.layer.anchorPoint;
    self.frame = frame;
    self.layer.anchorPoint = CGPointMake(0.5, 1.0);
    
    [UIView animateWithDuration:0.7 delay:0.2 options:UIViewAnimationCurveEaseOut animations:^{
        // Flip Down
        self.layer.transform = CATransform3DMakeRotation(M_PI/2, 1, 0, 0);
    } completion:^(BOOL finished) {
        [self cleareDamage];
        [self reboundOnShot];
        [UIView animateWithDuration:0.7 delay:0.2 options:UIViewAnimationCurveEaseOut animations:^{
            // Flip Up
            self.layer.transform = CATransform3DMakeScale(1, 1, 1);
            self.layer.anchorPoint = anchP;
            CGRect frame = self.frame;
            frame.origin.y = y;
            self.frame = frame;
            
        } completion:^(BOOL finished) {
           
            
        }];

       
    }];
}

-(void) changeLiveBarWithUserHitCount:(int)userHitCount maxShotCount:(int)maxShotCount;
{
    if (userHitCount>=maxShotCount) {
        userHitCount = maxShotCount;
    }
    DLog(@"changeLiveBarWithUserHitCount %d %d",userHitCount,maxShotCount)
    CGRect frame = ivLifeBar.frame;
    frame.size.width = (float)((maxShotCount - userHitCount)*oponentLiveImageViewStartWidth)/maxShotCount;
    ivLifeBar.frame = frame;

    int x = (maxShotCount - userHitCount);
    lbLifeLeft.text = [NSString stringWithFormat:@"%d",x];
   /*
    CGAffineTransform trf0 = lbLifeLeft.transform;
    CGAffineTransform trf1 = CGAffineTransformMakeScale(1.5, 1.5);
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         lbLifeLeft.transform = trf1;
                     } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.3
                                         animations:^{
                                             lbLifeLeft.transform = trf0;
                                         } completion:^(BOOL finished) {
                                         }];
                     }];
    */
}

-(void) refreshLiveBarWithLives: (int )lives;
{
    if (lives<0) {
        lives = 0;
    }
    CGRect frame = ivLifeBar.frame;
    frame.size.width = oponentLiveImageViewStartWidth;
    ivLifeBar.frame = frame;
    lbLifeLeft.text =[NSString stringWithFormat:@"%d", lives];
    lbLifeLeft.textAlignment = UITextAlignmentLeft;
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
        }
            break;
        case OpponentShapeStatusLive:
            [self setBodyType:self.typeOfBody];
            break;
        default:
            break;
    }
}

-(void)setBodyType:(OpponentShapeType)type;
{
    switch (type) {
        case OpponentShapeTypeManLow:
            imgBody.hidden = NO;
            mainViewOfBody = imgBody;
            break;
        case OpponentShapeTypeScarecrow:
            imgBody.image = [UIImage imageNamed:@"scarecrow.png"];
            imgBody.hidden = NO;
            mainViewOfBody = imgBody;
            break;
        default:
            break;
    }
}

-(int) damageForHitTheOponentWithPoint:(CGPoint)hitPoint mainView:(UIView*)mainView;
{
    UIImageView *ivHit;
    if(self.typeOfBody == OpponentShapeTypeScarecrow){
        ivHit= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ivHitPractice.png"]];
    } else{
        ivHit= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ivHit.png"]];  
    }
    
    CGPoint convertPoint = [mainView convertPoint:hitPoint toView:mainViewOfBody];
    ivHit.center = convertPoint;
    [mainViewOfBody addSubview:ivHit];
    ivHit = nil;

    int result = [imgBody checkNumberOfShotsAreas:@[@"{{0, 0}, {89,43}}", @"{{0,43}, {89,65}}", @"{{0,108}, {89,53}}"] forPoint:convertPoint];
    
    UIColor *color = [UIColor greenColor];
    UIFont *font = [UIFont boldSystemFontOfSize:22];
    CGPoint p= (CGPoint){44,-5};
    CGPoint p1 = (CGPoint){p.x, 8};
    int damageCount = 1;
    switch (result) {
        case 0:
            damageCount = 3;
            [mainViewOfBody addFlyingPointToView:mainView centerPoint:p
                                                    text:[NSString stringWithFormat:@"-%d",damageCount]
                                                   color:color
                                                    font:font
                                               direction:FlyingPointDirectionUp];
            [mainViewOfBody addFlyingImageToView:mainView
                              centerPoint:p1
                                imageName:@"crossbones.png"
                                direction:FlyingPointDirectionUp];
            break;
        case 1:
            damageCount = 2;
            [mainViewOfBody addFlyingPointToView:mainView centerPoint:p
                                            text:[NSString stringWithFormat:@"-%d",damageCount]
                                           color:color
                                            font:font
                                       direction:FlyingPointDirectionUp];
            [mainViewOfBody addFlyingImageToView:mainView
                              centerPoint:p1
                                imageName:@"crossbones.png"
                                direction:FlyingPointDirectionUp];
            break;
        case 2:
            damageCount = 1;
            [mainViewOfBody addFlyingPointToView:mainView centerPoint:p
                                            text:[NSString stringWithFormat:@"-%d",damageCount]
                                           color:color
                                            font:font
                                       direction:FlyingPointDirectionUp];
            [mainViewOfBody addFlyingImageToView:mainView
                              centerPoint:p1
                                imageName:@"crossbones.png"
                                direction:FlyingPointDirectionUp];
            break;
        default:
            break;
    }
    
    if (self.typeOfBody == OpponentShapeTypeScarecrow) {
        [self flip];
    }else
        [self reboundOnShot];
    
    return damageCount;
}

-(int)damageForShotInShapeWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;
{
    CGRect opponentBodyFrame = [[mainViewOfBody superview] convertRect:mainViewOfBody.frame toView:view];
        
    BOOL shotInFrame = (CGRectContainsPoint(opponentBodyFrame, point));
    BOOL shotInShape;
    
    CGPoint convertPoint = [view convertPoint:point toView:mainViewOfBody];

    UIColor *color = [mainViewOfBody colorOfPoint:convertPoint];

    shotInShape = (color != [color colorWithAlphaComponent:0.0f]);
    
    if (shotInFrame && shotInShape) {
        return 0;
    }else{
        return NSNotFound;
    }
}

-(void) cleareDamage;
{
    for(UIView *subview in [imgBody subviews])
    {
        [subview removeFromSuperview];
    }
}
-(void)walkOpponent
{
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        self.imgBody.transform = CGAffineTransformMakeRotation(((360*M_PI)/180) - 0.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
            self.imgBody.transform = CGAffineTransformMakeRotation(((360*M_PI)/180) + 0.1);
        } completion:^(BOOL finished) {
            if (isMove == YES) {
                [self walkOpponent];
            }else{ self.imgBody.transform = CGAffineTransformMakeRotation(((360*M_PI)/180));}
        }];

    }];
    
}
@end
