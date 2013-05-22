//
//  OpponentShape.m
//  Bounty Hunter
//
//  Created by Taras on 14.03.13.
//
//

#import "VisualViewCharacter.h"
#import <QuartzCore/QuartzCore.h>

@implementation VisualViewCharacter
@synthesize mainSubView;
@synthesize jakets;
@synthesize head;
@synthesize cap;
@synthesize length;
@synthesize shoose;
@synthesize visualViewDataSource;
@synthesize shirt;
@synthesize gun;
@synthesize suits;
@synthesize gunFrontView;

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
    jakets = nil;
    head = nil;
    cap = nil;
    length = nil;
    shoose = nil;
    [visualViewDataSource releaseComponents];
    visualViewDataSource = nil;
    shirt = nil;
    gun = nil;
    suits = nil;
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
    shirt.image = [visualViewCharacterPartBody imageForObject];
    visualViewCharacterPartBody = nil;
    
    CDVisualViewCharacterPartJakets *visualViewCharacterPartJakets = [[visualViewDataSource arrayJakets] objectAtIndex:accountPlayer.visualViewJackets];
    jakets.image = [visualViewCharacterPartJakets imageForObject];
    visualViewCharacterPartJakets = nil;
    
    CDVisualViewCharacterPartShoose *visualViewCharacterPartShoose = [[visualViewDataSource arrayShoose] objectAtIndex:accountPlayer.visualViewShoose];
    shoose.image = [visualViewCharacterPartShoose imageForObject];
    visualViewCharacterPartShoose = nil;
    
    CDVisualViewCharacterPartGuns *visualViewCharacterPartGun = [[visualViewDataSource arrayGuns] objectAtIndex:accountPlayer.visualViewGuns];
    gun.image = [visualViewCharacterPartGun imageForObject];
    visualViewCharacterPartGun = nil;
    
    CDVisualViewCharacterPartLegs *visualViewCharacterPartLegs = [[visualViewDataSource arrayLegs] objectAtIndex:accountPlayer.visualViewLegs];
    length.image = [visualViewCharacterPartLegs imageForObject];
    visualViewCharacterPartLegs = nil;
    
    CDVisualViewCharacterPartSuits *visualViewCharacterPartSuits = [[visualViewDataSource arraySuits] objectAtIndex:accountPlayer.visualViewSuits];
    suits.image = [visualViewCharacterPartSuits imageForObject];
    visualViewCharacterPartSuits = nil;
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

-(UIImage*)imageFromCharacter;
{
    UIGraphicsBeginImageContext(mainSubView.bounds.size);
    [mainSubView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)setGunFrontViewHidden:(BOOL)result;
{
    if (result) {
        gunFrontView.hidden = YES;
        gun.hidden = NO;
    }else{
        gunFrontView.hidden = NO;
        gun.hidden = YES;
    }
}
@end
