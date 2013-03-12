//
//  WomanShape.h
//  Bounty Hunter
//
//  Created by Taras on 12.03.13.
//
//

#import <UIKit/UIKit.h>

@interface WomanShape : UIView<MemoryManagement>
@property (weak, nonatomic) IBOutlet UIImageView *imageMain;

-(void)goLeft;
-(void)goRight;
-(void)stop;
-(void)scream;
-(BOOL)shotInWomanWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;
@end
