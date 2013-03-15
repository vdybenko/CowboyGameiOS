//
//  WomanShape.h
//  Bounty Hunter
//
//  Created by Taras on 12.03.13.
//
//

#import <UIKit/UIKit.h>
#import "Shape.h"

@interface WomanShape : Shape
@property (weak, nonatomic) IBOutlet UIImageView *womanImg;

-(void)goLeft;
-(void)goRight;
-(void)moveWoman;
-(void)stop;
-(void)scream;
-(void)womanAnimation;

@end
