//
//  UILabel+FlyingPoint.h
//  Bounty Hunter
//
//  Created by Taras on 18.03.13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    FlyingPointDirectionUp,
    FlyingPointDirectionLeftUp,
    FlyingPointDirectionRightUp
} FlyingPointDirection;

@interface UIView(FlyingPoint)

-(void)addFlyingPointToView:(UIView*)view centerPoint:(CGPoint)point text:(NSString*)st color:(UIColor*)color font:(UIFont*)font direction:(FlyingPointDirection)direction;
-(int)checkNumberOfShotsAreas:(NSArray*)arrayAreas forPoint:(CGPoint)point;

-(void)addFlyingImageToView:(UIView *)view
                centerPoint:(CGPoint)point
                  imageName:(NSString *)nameOfImg
                  direction:(FlyingPointDirection)direction;

@end
