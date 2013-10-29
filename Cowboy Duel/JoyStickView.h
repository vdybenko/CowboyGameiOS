//
//  VisualStickView.h
//  SampleGame
//
//  Created by Zhang Xiang on 13-4-26.
//  Copyright (c) 2013年 Myst. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JoyStickViewDelegate <NSObject>

- (void)onStickChanged:(id)notification;

@end

@interface JoyStickView : UIView

{
    IBOutlet UIImageView *stickViewBase;
    IBOutlet UIImageView *stickView;
    
    UIImage *imgStickNormal;
    UIImage *imgStickHold;
    
    CGPoint mCenter;
}
@property(weak,nonatomic) id <JoyStickViewDelegate> delegate;

@end
