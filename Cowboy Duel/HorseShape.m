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
        UIImage *spriteSheet = [UIImage imageNamed:@"horseAnimation2"];
        NSArray *arrayWithSprites = [spriteSheet spritesWithSpriteSheetImage:spriteSheet inRange:NSRangeFromString(@"{0,8}")
                                                                  spriteSize:super.imageMain.frame.size];
        
        NSMutableArray *imgArray =[NSMutableArray arrayWithArray: arrayWithSprites];
        [imgArray addObject:[UIImage imageNamed:@"horses_1.png"]];
        super.imageMain.animationImages = imgArray;
        super.imageMain.animationDuration = 0.7;
        [super.imageMain setAnimationRepeatCount:1];
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
