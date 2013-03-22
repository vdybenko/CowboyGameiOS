//
//  OpponentShape.m
//  Bounty Hunter
//
//  Created by Taras on 14.03.13.
//
//

#import "VisualViewCharacter.h"

@implementation VisualViewCharacter
@synthesize mainSubView;
@synthesize body;
@synthesize head;
@synthesize cap;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"VisualViewCharacter" owner:self options:nil];
        [self addSubview:mainSubView];
        
        CGRect frame = mainSubView.frame;
        frame.size.width = self.frame.size.width;
        frame.size.height = self.frame.size.height;
        mainSubView.frame = frame;
    }
    return self;
}

-(void)releaseComponents
{
    mainSubView = nil;
    body = nil;
    head = nil;
    cap = nil;
}

@end
