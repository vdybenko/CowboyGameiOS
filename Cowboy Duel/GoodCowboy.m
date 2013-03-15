//
//  GoodCowboy.m
//  Bounty Hunter
//
//  Created by Taras on 14.03.13.
//
//

#import "GoodCowboy.h"
#import <AVFoundation/AVFoundation.h>
@interface GoodCowboy()
{
    AVAudioPlayer *audioPlayer;
}
@end

@implementation GoodCowboy
@synthesize goodCowboyImg;
- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder subViewFromNibFileName:@"GoodCowboy"];
    if(self){
        NSString *soundName = @"goodCowboyVoice1";
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


-(void)scream;
{
    [audioPlayer play];
}

-(BOOL)shotInShapeWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;
{
    if ([super shotInShapeWithPoint:point superViewOfPoint:view]) {
        [self scream];
        [self goodCowboyAnimation];
        return YES;
    }else{
        return NO;
    }
}
-(void)moveGoodCowboy;
{
   
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
-(void)goodCowboyAnimation;{

    NSArray *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"goodCowboyScared.png"],
                         [UIImage imageNamed:@"goodCowboy.png"],
                         nil];
    goodCowboyImg.animationImages = imgArray;
    goodCowboyImg.animationDuration = 1.0f;
    [goodCowboyImg setAnimationRepeatCount:1];
    [goodCowboyImg startAnimating];
}

@end
