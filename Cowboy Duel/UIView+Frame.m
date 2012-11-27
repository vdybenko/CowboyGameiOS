//
//  UIView+Frame.m
//  Cowboy Duels
//
//  Created by Taras on 19.11.12.
//
//

#import "UIView+Frame.h"

@implementation UIView_Frame

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor clearColor];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 3.0);
    UIColor *color = [UIColor colorWithRed:98.0f/255.0f green:68.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGRect rectangle = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGContextAddRect(context, rectangle);
    CGContextStrokePath(context);
}

@end
