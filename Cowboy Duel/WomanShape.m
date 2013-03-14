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
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFile error:&error];
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

-(void)randomPositionWithView:(UIView*)view;
{
    CGPoint body = self.center;
    
    int randPosition = rand() % 100;
    int direction = rand() % 2?-1:1;
    body.x = (view.frame.origin.x + direction*randPosition);
    self.center = body;
}
@end
