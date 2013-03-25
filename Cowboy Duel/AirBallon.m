//
//  AirBallon.m
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 22.03.13.
//
//

#import "AirBallon.h"

@implementation AirBallon

@synthesize airBallonImg;
@synthesize airBalloonView;


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if(self){
            NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"AirBalloon" owner:self options:nil];
            UIView *nibView = [objects objectAtIndex:0];
            [self addSubview:nibView];
            
    }
    return self;
}
-(void)airBallonMove{
    [UIView animateWithDuration:10 animations:^{
        CGRect frame = self.frame;
        frame.origin.x -=460;
        self.frame = frame;
    }completion:^(BOOL complete){
        [self airBalloonView];
    }];

}
-(void)airBallonPosition{
    self.center = CGPointMake(0, 0);
    

}
-(void)releaseComponents{

    airBalloonView = nil;
    airBallonImg = nil;
}
@end
