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
        
        NSArray *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"cactusFraim1.png"],
                             [UIImage imageNamed:@"cactusFraim2.png"], [UIImage imageNamed:@"cactusFraim3.png"],[UIImage imageNamed:@"cactusFraim4.png"], [UIImage imageNamed:@"cactusFraim5.png"],[UIImage imageNamed:@"cactusFraim6.png"],[UIImage imageNamed:@"cactusFraim7.png"],
                             nil];
        cactusImg.animationImages = imgArray;
        cactusImg.animationDuration = 0.5f;
        [cactusImg setAnimationRepeatCount:1];
        imgArray = nil;

        
    }
    return self;
}

-(void)explosionAnimation;
{
    if ([cactusImg isAnimating]) {
        return;
    }

     [cactusImg startAnimating];
    [self performSelector:@selector(hideObj) withObject:nil afterDelay:0.4f];
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
