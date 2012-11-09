//
//  BEAnimationView.m
//  tryAnimations
//
//  Created by AlexandrBezpalchuk on 08.11.12.
//  Copyright (c) 2012 AlexandrBezpalchuk. All rights reserved.
//

#import "BEAnimationView.h"
#import <QuartzCore/QuartzCore.h>
int oldMovingKey = 4;

@implementation BEAnimationView

@synthesize delays,angle,depth,freedom,speed;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void) animateWithType:(NSNumber *)type
{
  switch ([type intValue]) {
    case GUILLOTINE:
    {
      CGRect currentPosition = self.frame;
      [self guillCycleWithCurrPosition:currentPosition andDelay:delays];
        break;
    }
    
    case HAT:
    {
      [self hatAnimationWithFreedom:freedom];
        break;
    }
    
    
    case WHISKERS:
    {
      [self whiskersCycleWithAngle:angle];
        break;
    }
      
    
    case FALL:
    {
      [self fallFromPosition:self.frame withDepth:depth andSpeed:speed];
        break;
    }
      
       
    default:
      break;
  }
}
//case Guillotine:
- (void) guillCycleWithCurrPosition: (CGRect )curr andDelay: (float )wait{
  float tWait;
  CGRect currentPosition = self.frame;
  if (!wait) {
    tWait = 0.7;
  }
  else
    tWait = wait;
  [UIView animateWithDuration:1.0
                        delay:tWait
                      options:UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction
                   animations:^{

                     CGRect moveDown = currentPosition;
                     moveDown.origin.y += 50;
                     self.frame = moveDown;
                     
                   } completion:^(BOOL finished) {
                     [UIView animateWithDuration:1.3
                                           delay:0.0
                                         options:UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction
                                      animations:^{
                                        CGRect currentPosition = self.frame;
                                        CGRect moveUp = currentPosition;
                                        moveUp.origin.y -= 40;
                                        self.frame = moveUp;
                                        
                                      } completion:^(BOOL finished) {
                                        [UIView animateWithDuration:1.0
                                                              delay:0.1
                                                            options:UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction
                                                         animations:^{
                                                           CGRect currentPosition = self.frame;
                                                           CGRect moveDown = currentPosition;
                                                           moveDown.origin.y += 20;
                                                           self.frame = moveDown;

                                                         } completion:^(BOOL finished) {
                                                           NSLog(@"y: %f",self.frame.origin.y);
                                                           NSLog(@"h: %f",self.frame.size.height);
                                                           NSLog(@"abs(y): %d",abs(self.frame.origin.y));
                                                           NSLog(@"h/2: %f",self.frame.size.height/2);

                                                           if (self.frame.origin.y+self.frame.size.height <= [UIScreen mainScreen].bounds.size.height/2) {
                                                             [self guillCycleWithCurrPosition:self.frame andDelay:tWait];
                                                           }
                                                         }];
                                      }];
                   }];
}
;

//case Whiskers:
- (void) whiskersCycleWithAngle:(float) angleRotate {

  if(!angleRotate)
    angleRotate = M_1_PI/4;

  float flRand;
  
  srand ( time(NULL) );
  
  flRand = (rand() % 10 + 3)*0.1;
    
  [UIView animateWithDuration:flRand
                        delay:delays
                      options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveLinear
                   animations:^{
                     
                     CGAffineTransform rightDown = CGAffineTransformRotate(self.transform, angleRotate);
                     self.transform = rightDown;
                     
                   } completion:^(BOOL finished) {
                     [UIView animateWithDuration:flRand animations:^{
                       CGAffineTransform leftDown = CGAffineTransformRotate(self.transform, -angleRotate);
                       self.transform = leftDown;
                       
                     }completion:^(BOOL finished) {
                       [self whiskersCycleWithAngle:angleRotate];
                     }];
                     
                   }];
  
}

//case Hat:
-(void) hatAnimationWithFreedom: (int)freed {
  CGRect original = self.frame;
    if(self.stopAnimation) return;
  if (!freed) {
    freed = 5;
  }
  
  int movingFreedom = freed;
  
  float flRand;
  
  srand ( time(NULL) );
  
  flRand = (rand() % 10 + 3)*0.1;
  
  float movingRand = (rand()%movingFreedom+3);
  int movingKey = (rand()%4);
  if (movingKey == oldMovingKey) {
    movingKey += 1;
  }
  oldMovingKey = movingKey;
  
  [UIView animateWithDuration:flRand
                        delay:delays
                      options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveLinear
                   animations:^{
                     switch (movingKey) {
                       case 0:
                       {
                         CGRect temp = self.frame;
                         temp.origin.x -= movingRand;
                         temp.origin.y -= movingRand;
                         self.frame = temp;
                       }
                         break;
                       case 1:
                       {
                         CGRect temp = self.frame;
                         temp.origin.x += movingRand;
                         temp.origin.y -= movingRand;
                         self.frame = temp;
                       }
                         break;
                       case 2:
                       {
                         CGRect temp = self.frame;
                         temp.origin.x -= movingRand;
                         temp.origin.y += movingRand;
                         self.frame = temp;
                       }
                         break;
                       case 3:
                       {
                         CGRect temp = self.frame;
                         temp.origin.x += movingRand;
                         temp.origin.y += movingRand;
                         self.frame = temp;
                       }
                         break;

                         
                       default:
                         self.frame = original;
                         break;
                     }
                   }completion:^(BOOL finished) {
                       if (!self.stopAnimation) {
                           [UIView animateWithDuration:flRand animations:^{
                               self.frame = original;
                           } completion:^(BOOL finished) {
                               [self hatAnimationWithFreedom:freedom];
                           }];
                       }
   

                   }
   ];
}

//case Fall:
-(void)fallFromPosition: (CGRect )currentPosition withDepth: (float )tdepth andSpeed: (float) speedd{
  [self.layer removeAllAnimations];
  self.stopAnimation = YES;
  self.frame = currentPosition;
  float tSpeed = speedd;
  if (!tdepth) {
    tdepth = 220;
  }
  if (!speed) {
    tSpeed = 0.7;
  }
  [UIView animateWithDuration:tSpeed
                        delay:0.0
                      options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn
                   animations:^{
                     CGRect tmpPos = self.frame;
                     tmpPos.origin.y += tdepth;
                     self.frame = tmpPos;
                     
                   } completion:^(BOOL finished) {
                   }];
}

@end