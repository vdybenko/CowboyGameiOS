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
    [audioPlayer stop];
    audioPlayer = nil;
}


-(void)scream;
{
    [audioPlayer play];
}

-(int)damageForShotInShapeWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;
{
    if ([super damageForShotInShapeWithPoint:point superViewOfPoint:view]!=NSNotFound && self.hidden !=YES) {
        [self scream];
        [self goodCowboyAnimation];
        
        CGPoint convertPoint =[view convertPoint:point toView:self.imageMain];
        int result = [super.imageMain checkNumberOfShotsAreas:@[@"{{0, 0}, {89,43}}", @"{{0,43}, {89,65}}", @"{{0,108}, {89,53}}"] forPoint:convertPoint];
        
        UIColor *color = [UIColor redColor];
        UIFont *font = [UIFont boldSystemFontOfSize:22];
        int damage = 3;
        switch (result) {
            case 0:
                [super.imageMain addFlyingPointToView:view centerPoint:CGPointMake(super.imageMain.center.x, -5)
                                                        text:@"-3"
                                                       color:color
                                                        font:font
                                                   direction:FlyingPointDirectionUp];
                break;
            case 1:
                [super.imageMain addFlyingPointToView:view centerPoint:CGPointMake(super.imageMain.center.x, -5)
                                                        text:@"-3"
                                                       color:color
                                                        font:font
                                                   direction:FlyingPointDirectionUp];
                break;
            case 2:
                [super.imageMain addFlyingPointToView:view centerPoint:CGPointMake(super.imageMain.center.x, -5)
                                                        text:@"-3"
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
    super.imageMain.animationImages = imgArray;
    super.imageMain.animationDuration = 1.0f;
    [super.imageMain setAnimationRepeatCount:1];
    [super.imageMain startAnimating];
}

@end
