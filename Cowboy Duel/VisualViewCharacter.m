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
@synthesize length;
@synthesize shoose;
@synthesize visualViewDataSource;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        [[NSBundle mainBundle] loadNibNamed:@"VisualViewCharacter" owner:self options:nil];
        [self addSubview:mainSubView];
        
        CGRect frame = mainSubView.frame;
        frame.size = self.frame.size;
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
    length = nil;
    shoose = nil;
    [visualViewDataSource releaseComponents];
    visualViewDataSource = nil;
}

-(void)refreshWithAccountPlayer:(AccountDataSource*)accountPlayer;
{
    if (!visualViewDataSource) {
        visualViewDataSource = [[VisualViewDataSource alloc] init];
        self.visualViewDataSource = visualViewDataSource;
    }
    CDVisualViewCharacterPartCap *visualViewCharacterPartCap = [[visualViewDataSource arrayCap] objectAtIndex:accountPlayer.visualViewCap];
    cap.image = [visualViewCharacterPartCap imageForObject];
    visualViewCharacterPartCap = nil;
    
    CDVisualViewCharacterPartHead *visualViewCharacterPartHead = [[visualViewDataSource arrayHead] objectAtIndex:accountPlayer.visualViewHead];
    head.image = [visualViewCharacterPartHead imageForObject];
    visualViewCharacterPartHead = nil;
    
    CDVisualViewCharacterPartBody *visualViewCharacterPartBody = [[visualViewDataSource arrayBody] objectAtIndex:accountPlayer.visualViewBody];
    body.image = [visualViewCharacterPartBody imageForObject];
    visualViewCharacterPartBody = nil;
}

-(void)cleareView;
{
    for(UIView *subview in [self subviews])
    {
        if (subview.tag!=404) {
            [subview removeFromSuperview];
        }
    }
}
@end
