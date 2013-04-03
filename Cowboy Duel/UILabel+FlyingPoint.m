//
//  UILabel+FlyingPoint.m
//  Bounty Hunter
//
//  Created by Taras on 18.03.13.
//
//

#import "UILabel+FlyingPoint.h"

@implementation UIView(FlyingPoint)

int deltaX = 0;

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
    
    deltaX = frame.size.width+10;
    
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

-(void)addFlyingImageToView:(UIView *)view
                centerPoint:(CGPoint)point
                  imageName:(NSString *)nameOfImg
                  direction:(FlyingPointDirection)direction;
{
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:nameOfImg]];
    
    CGPoint currPoint = point;
    currPoint.x += deltaX;
    
    CGPoint convertPoint =[self convertPoint:currPoint toView:view];
    imgView.center = convertPoint;
    
    int maxIndex = [[view subviews]count];
    [view insertSubview:imgView atIndex:(maxIndex-2)];
    
    UIImageView __block *imgBlock = imgView;
    imgView = nil;
    
    switch (direction) {
        case FlyingPointDirectionUp:
        {
            [UIView animateWithDuration:0.5 animations:^{
                imgBlock.center = CGPointMake(imgBlock.center.x, (imgBlock.center.y-30));
            }completion:^(BOOL complete){
                [UIView animateWithDuration:0.3 animations:^{
                    imgBlock.center = CGPointMake(imgBlock.center.x, (imgBlock.center.y-20));
                    imgBlock.alpha = 0.f;
                }completion:^(BOOL complete){
                    [imgBlock removeFromSuperview];
                    imgBlock = nil;
                }];
            }];
        }
            break;
        case FlyingPointDirectionLeftUp:
        {
            [UIView animateWithDuration:0.7 animations:^{
                imgBlock.center = CGPointMake(imgBlock.center.x-30, (imgBlock.center.y-20));
            }completion:^(BOOL complete){
                [UIView animateWithDuration:0.5 animations:^{
                    imgBlock.center = CGPointMake(imgBlock.center.x, (imgBlock.center.y-30));
                    imgBlock.alpha = 0.f;
                }completion:^(BOOL complete){
                    [imgBlock removeFromSuperview];
                    imgBlock = nil;
                }];
            }];
        }
            break;
        case FlyingPointDirectionRightUp:
        {
            [UIView animateWithDuration:0.7 animations:^{
                imgBlock.center = CGPointMake(imgBlock.center.x+30, (imgBlock.center.y-20));
            }completion:^(BOOL complete){
                [UIView animateWithDuration:0.5 animations:^{
                    imgBlock.center = CGPointMake(imgBlock.center.x, (imgBlock.center.y-30));
                    imgBlock.alpha = 0.f;
                }completion:^(BOOL complete){
                    [imgBlock removeFromSuperview];
                    imgBlock = nil;
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
