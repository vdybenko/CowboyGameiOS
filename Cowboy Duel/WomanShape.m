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
    NSMutableArray *arrAudioPlayers;
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
        
        arrAudioPlayers = [NSMutableArray array];
        
        for ( int i = 1; i < 5; i++ ) {
            NSString *soundName = [NSString stringWithFormat:@"scream%d", i];
            NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
            NSURL *soundFile = [NSURL fileURLWithPath:soundPath];
            AVAudioPlayer *p = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFile error:nil];
            [arrAudioPlayers addObject:(id)p];
            p = nil;
        }
    }
    return self;
}

-(void)releaseComponents
{
    for (id __strong p in arrAudioPlayers) {
        p = nil;
    }
    arrAudioPlayers = nil;
}

-(void)goLeft;
{}
-(void)goRight;
{}
-(void)stop;
{}

-(void)scream;
{
    int numberOfAnimation = rand() % 4;
    
    AVAudioPlayer *audioPlayer = [arrAudioPlayers objectAtIndex:numberOfAnimation];
    [audioPlayer prepareToPlay];
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
