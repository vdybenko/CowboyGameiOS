//
//  WomanShape.m
//  Bounty Hunter
//
//  Created by Taras on 12.03.13.
//
//

#import "Shape.h"
#import "UIView+ColorOfPoint.h"

@implementation Shape
@synthesize imageMain;

-(id)initWithCoder:(NSCoder *)aDecoder subViewFromNibFileName:(NSString*)name;
{
    self = [super initWithCoder:aDecoder];
    if(self){
        @autoreleasepool {
            NSArray* objects = [[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];
            UIView *nibView = [objects objectAtIndex:0];
            [self addSubview:nibView];
        }
    }
    return self;
}

-(void)releaseComponents
{
    imageMain = nil;
}

-(BOOL)shotInShapeWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;
{
    CGRect convertBody = [[self.imageMain superview] convertRect:self.imageMain.frame toView:view];
    BOOL shotInShape;
    
    CGPoint convertPoint = [view convertPoint:point toView:self.imageMain];
    
    UIColor *color = [self.imageMain colorOfPoint:convertPoint];
    
    shotInShape = (color != [color colorWithAlphaComponent:0.0f]);
    if (CGRectContainsPoint(convertBody, point) && shotInShape) {
        return YES;
    }else{
        return NO;
    }
}

-(void)randomPositionWithView:(UIView*)view;
{
    CGPoint body = self.center;
    
    int randPosition = rand() % (int)[self superview].frame.origin.x;
    int direction = 1;//rand() % 2?-1:1;
    body.x = (direction*randPosition);
    self.center = body;
}
@end
