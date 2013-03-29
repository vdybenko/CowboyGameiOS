//
//  CactusObject.m
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 21.03.13.
//
//

#import "CactusObject.h"
#import "UIImage+Sprite.h"

@implementation CactusObject

@synthesize cactusImg;
@synthesize cactusView;


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if(self){
            NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"Cactus" owner:self options:nil];
            UIView *nibView = [objects objectAtIndex:0];
            [self addSubview:nibView];
        
    }
    return self;
}

-(void)explosionAnimation;
{
    if ([cactusImg isAnimating]) {
        return;
    }

    UIImage *spriteSheetExp = [UIImage imageNamed:@"cactusSpreetSeet3"];
    NSArray *arrayWithSpritesExp = [spriteSheetExp spritesWithSpriteSheetImage:spriteSheetExp
                                                                    spriteSize:CGSizeMake(90, 140)];
    [cactusImg setAnimationImages:arrayWithSpritesExp];
    [cactusImg setAnimationRepeatCount:1];
    [cactusImg setAnimationDuration:1];
    [cactusImg startAnimating];

     [cactusImg startAnimating];
    [self performSelector:@selector(hideObj) withObject:nil afterDelay:0.9f];
}
-(void)hideObj{
    
    [cactusImg stopAnimating];
    cactusImg.hidden = YES;
    
}
-(void)releaseComponents
{
    cactusImg = nil;
    cactusView = nil;
}


@end
