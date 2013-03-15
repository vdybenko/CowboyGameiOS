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
    audioPlayer = nil;
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
        return YES;
    }else{
        return NO;
    }
}
@end