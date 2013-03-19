//
//  UILabel+FlyingPoint.m
//  Bounty Hunter
//
//  Created by Taras on 18.03.13.
//
//

#import "UILabel+FlyingPoint.h"

@implementation UIView(FlyingPoint)

-(void)addFlyingPointToView:(UIView*)view centerPoint:(CGPoint)point text:(NSString*)st color:(UIColor*)color font:(UIFont*)font direction:(FlyingPointDirection)direction;
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = color;
    label.text = st;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = font;
    
    CGPoint convertPoint =[self convertPoint:point toView:view];
    label.center = convertPoint;
    CGRect frame = label.frame;
    CGSize suggestedSize = [st sizeWithFont:label.font];
    frame.size = suggestedSize;
    label.frame = frame;
    
    int maxIndex = [[view subviews]count];
    [view insertSubview:label atIndex:(maxIndex-2)];
    
    UILabel __block *labelBlock = label;
    label = nil;
    
    switch (direction) {
        case FlyingPointDirectionUp:
            {
                [UIView animateWithDuration:0.5 animations:^{
                    labelBlock.center = CGPointMake(labelBlock.center.x, (labelBlock.center.y-30));
                }completion:^(BOOL complete){
                    [UIView animateWithDuration:0.3 animations:^{
                        labelBlock.center = CGPointMake(labelBlock.center.x, (labelBlock.center.y-20));
                        labelBlock.alpha = 0.f;
                    }completion:^(BOOL complete){
                        [labelBlock removeFromSuperview];
                        labelBlock = nil;
                    }];
                }];
            }
            break;
        case FlyingPointDirectionLeftUp:
        {
            [UIView animateWithDuration:0.7 animations:^{
                labelBlock.center = CGPointMake(labelBlock.center.x-30, (labelBlock.center.y-20));
            }completion:^(BOOL complete){
                [UIView animateWithDuration:0.5 animations:^{
                    labelBlock.center = CGPointMake(labelBlock.center.x, (labelBlock.center.y-30));
                    labelBlock.alpha = 0.f;
                }completion:^(BOOL complete){
                    [labelBlock removeFromSuperview];
                    labelBlock = nil;
                }];
            }];
        }
            break;
        case FlyingPointDirectionRightUp:
        {
            [UIView animateWithDuration:0.7 animations:^{
                labelBlock.center = CGPointMake(labelBlock.center.x+30, (labelBlock.center.y-20));
            }completion:^(BOOL complete){
                [UIView animateWithDuration:0.5 animations:^{
                    labelBlock.center = CGPointMake(labelBlock.center.x, (labelBlock.center.y-30));
                    labelBlock.alpha = 0.f;
                }completion:^(BOOL complete){
                    [labelBlock removeFromSuperview];
                    labelBlock = nil;
                }];
            }];
        }
            break;
        default:
        {}
            break;
    }
}

-(int)checkNumberOfShotsAreas:(NSArray*)arrayAreas forPoint:(CGPoint)point;
{
    for (int i=0; i<[arrayAreas count]-1; i++) {
        NSString *st=[arrayAreas objectAtIndex:i];
        CGRect rect = CGRectFromString(st);
        if (CGRectContainsPoint(rect, point)){
            return i;
        }
    }
    return NSNotFound;
}
@end
