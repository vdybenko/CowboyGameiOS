//
//  UIView+Dinamic_BackGround.h
//  Cowboy Duel 1
//
//  Created by Taras on 25.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AttachedView.h"

@interface UIView (dinamic_height_backgroud)
-(void)setDinamicHeightBackground;
-(void)dinamicAttachToView:(UIView*)attachedToView withDirection:(DirectionToAnimate)direction;
-(CGSize)fitSizeToText:(UILabel*)label;
@end
