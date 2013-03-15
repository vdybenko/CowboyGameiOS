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
@synthesize womanImg;
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

-(BOOL)shotInShapeWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;
{
    if ([super shotInShapeWithPoint:point superViewOfPoint:view]) {
        [self scream];
        [self womanAnimation];
        return YES;
    }else{
        return NO;
    }
}
-(void)womanAnimation;
{
    NSArray *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"womanScared.png"],
                         [UIImage imageNamed:@"woman.png"],
                         nil];
    womanImg.animationImages = imgArray;
    womanImg.animationDuration = 1.0f;
    [womanImg setAnimationRepeatCount:1];
    [womanImg startAnimating];
}
@end
