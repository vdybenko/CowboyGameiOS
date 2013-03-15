//
//  WomanShape.m
//  Bounty Hunter
//
//  Created by Taras on 12.03.13.
//
//

#import "Shape.h"

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
    UIView *firstView = [self.subviews objectAtIndex:0];
    firstView = nil;
    imageMain = nil;
}

-(BOOL)shotInShapeWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;
{
    CGRect convertBody = [[self.imageMain superview] convertRect:self.imageMain.frame toView:view];
    if (CGRectContainsPoint(convertBody, point)) {
        return YES;
    }else{
        return NO;
    }
}

-(void)randomPositionWithView:(UIView*)view;
{
    CGPoint body = self.center;
    
    int randPosition = rand() % 300;
    int direction = rand() % 2?-1:1;
    body.x = (view.frame.origin.x + direction*randPosition);
    self.center = body;
}
@end
