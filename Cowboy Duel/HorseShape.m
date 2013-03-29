//
//  HorseShape.m
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 26.03.13.
//
//

#import "HorseShape.h"
#import "UIImage+Sprite.h"


@implementation HorseShape

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder subViewFromNibFileName:@"Horse"];
    if(self){
          
        NSArray *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"horses_1.png"],
                             [UIImage imageNamed:@"horses_2.png"], [UIImage imageNamed:@"horses_3.png"],[UIImage imageNamed:@"horses_4.png"], [UIImage imageNamed:@"horses_5.png"],[UIImage imageNamed:@"horses_6.png"], [UIImage imageNamed:@"horses_7.png"],[UIImage imageNamed:@"horses_8.png"], [UIImage imageNamed:@"horses_9.png"], [UIImage imageNamed:@"horses_10.png"],
                             nil];
        super.imageMain.animationImages = imgArray;
        super.imageMain.animationDuration = 0.8f;
        [super.imageMain setAnimationRepeatCount:1];
        imgArray = nil;
    }
    return self;
}

-(void)horseAnimation;
{
    [super.imageMain startAnimating];
}

-(BOOL)shotInShapeWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view{
    if ([super shotInShapeWithPoint:point superViewOfPoint:view]) {
        [self horseAnimation];
        return YES;
    }
    return NO;
}

-(void)releaseComponents{
    [super releaseComponents];
}
@end
