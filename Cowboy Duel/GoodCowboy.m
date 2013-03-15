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
        return YES;
    }else{
        return NO;
    }
}
@end
