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
        
        [self choiceImg];
        
        NSArray *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"cactusFrame1.png"],
                             [UIImage imageNamed:@"cactusFrame2.png"], [UIImage imageNamed:@"cactusFrame3.png"],[UIImage imageNamed:@"cactusFrame4.png"], [UIImage imageNamed:@"cactusFrame5.png"],[UIImage imageNamed:@"cactusFrame6.png"],  nil];
        
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
-(void)choiceImg{
    switch (arc4random()%2) {
        case 0:
              cactusImg.image = [UIImage imageNamed:@"cactusNew1.png"];
        break;

        case 1:
             cactusImg.image = [UIImage imageNamed:@"cactusNew2.png"];
        break;
        default:
            break;
    }
   
}

@end
