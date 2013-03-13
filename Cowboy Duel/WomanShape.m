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
@synthesize imageMain;
- (id)initWithCoder:(NSCoder *)aDecoder
{
   
    self = [super initWithCoder:aDecoder];
    if(self){
        @autoreleasepool {
            NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"WomanShape" owner:self options:nil];
            UIView *nibView = [objects objectAtIndex:0];
            [self addSubview:nibView];
        }
        
        NSString *soundName = @"scream1";
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
        NSURL *soundFile = [NSURL fileURLWithPath:soundPath];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFile error:nil];
        [audioPlayer prepareToPlay];
    }
    return self;
}

-(void)releaseComponents
{
    audioPlayer = nil;
    imageMain = nil;
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

-(BOOL)shotInWomanWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;
{
    CGRect convertBody = [[self.imageMain superview] convertRect:self.imageMain.frame toView:view];
    if (CGRectContainsPoint(convertBody, point)) {
        [self scream];
        return YES;
    }else{
        return NO;
    }
}

@end
