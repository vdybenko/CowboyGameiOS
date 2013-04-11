//
//  WomanShape.m
//  Bounty Hunter
//
//  Created by Taras on 12.03.13.
//
//

#import "WomanShape.h"
#import <AVFoundation/AVFoundation.h>

@interface WomanShape()
{
    AVAudioPlayer *audioPlayer;
}
@end

@implementation WomanShape
- (id)initWithCoder:(NSCoder *)aDecoder
{
   
    self = [super initWithCoder:aDecoder subViewFromNibFileName:@"WomanShape"];
    if(self){
        NSString *soundName = @"womanVoiceHelp";
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
        NSURL *soundFile = [NSURL fileURLWithPath:soundPath];
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFile error:&error];
        [audioPlayer prepareToPlay];
    }
    return self;
}

-(void)releaseComponents
{
    [super releaseComponents];
    [audioPlayer stop];
    audioPlayer = nil;
}
-(void)moveWoman;
{
    [self womanAnimation];
    int randomDirection = rand() % 3 - 1;
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = self.frame;
        frame.origin.x += randomDirection * 40;
        self.frame = frame;
    }completion:^(BOOL complete){
        [UIView animateWithDuration:0.4 animations:^{
            CGRect frame = self.frame;
            frame.origin.x += randomDirection * 40;
            self.frame = frame;
        }completion:^(BOOL complete){
            [UIView animateWithDuration:0.4 animations:^{
                CGRect frame = self.frame;
                frame.origin.x += randomDirection * 40;
                self.frame = frame;
            }completion:^(BOOL complete){
            }];
        }];
    }];
    

    
}
-(void)goLeft;
{}
-(void)goRight;
{}
-(void)stop;
{}

-(void)scream;
{    
    [audioPlayer play];
}

-(int)damageForShotInShapeWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;
{
    if ([super damageForShotInShapeWithPoint:point superViewOfPoint:view]!=NSNotFound && self.hidden !=YES) {
        [self scream];
        [self womanAnimation];
        
        CGPoint convertPoint =[view convertPoint:point toView:self.imageMain];
        int result = [super.imageMain checkNumberOfShotsAreas:@[@"{{0, 0}, {89,43}}", @"{{0,43}, {89,65}}", @"{{0,108}, {89,53}}"] forPoint:convertPoint];
        
        UIColor *color = [UIColor redColor];
        UIFont *font = [UIFont boldSystemFontOfSize:22];
        int damage = 3;
        switch (result) {
            case 0:
                [super.imageMain addFlyingPointToView:view centerPoint:CGPointMake(super.imageMain.center.x, 0)
                                                  text:[NSString stringWithFormat:@"-%d",damage]
                                                 color:color
                                                  font:font
                                             direction:FlyingPointDirectionUp];
                break;
            case 1:
                [super.imageMain addFlyingPointToView:view centerPoint:CGPointMake(super.imageMain.center.x, 0)
                                                        text:[NSString stringWithFormat:@"-%d",damage]
                                                       color:color
                                                        font:font
                                                   direction:FlyingPointDirectionUp];
                break;
            case 2:
                [super.imageMain addFlyingPointToView:view centerPoint:CGPointMake(super.imageMain.center.x, 0)
                                                        text:[NSString stringWithFormat:@"-%d",damage]
                                                       color:color
                                                        font:font
                                                   direction:FlyingPointDirectionUp];
                break;
            default:
                break;
        }
        
        return damage;
    }else{
        return NSNotFound;
    }
}
-(void)womanAnimation;
{
    NSArray *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"womanScared.png"],
                         [UIImage imageNamed:@"woman.png"],
                         nil];
    super.imageMain.animationImages = imgArray;
    super.imageMain.animationDuration = 1.0f;
    [super.imageMain setAnimationRepeatCount:1];
    [super.imageMain startAnimating];
}
@end
