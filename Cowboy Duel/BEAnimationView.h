//
//  BEAnimationView.h
//  tryAnimations
//
//  Created by AlexandrBezpalchuk on 08.11.12.
//  Copyright (c) 2012 AlexandrBezpalchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
  GUILLOTINE, //down-up-down cycle
  WHISKERS,   //rotate +- angle
  HAT,        //moving +- freedom
  FALL        //down with acceleration
} AnimationType;
 
@interface BEAnimationView : UIImageView
@property(nonatomic) float delays;        //delay between guillotine cycles and between whiskers cycles
@property(nonatomic) float angle;         //angle of whiskers rotation
@property(nonatomic) float depth;         //depth of fall
@property(nonatomic) float speed;         //duration of fall
@property(nonatomic) int freedom;         //freedom of hat moving
@property(nonatomic) BOOL stopAnimation;
- (void) animateWithType: (NSNumber *)number;
@end
