//
//  WomanShape.h
//  Bounty Hunter
//
//  Created by Taras on 12.03.13.
//
//

#import <UIKit/UIKit.h>
#import "UILabel+FlyingPoint.h"

@interface Shape : UIView<MemoryManagement>
@property (weak, nonatomic) IBOutlet UIImageView *imageMain;

-(id)initWithCoder:(NSCoder *)aDecoder subViewFromNibFileName:(NSString*)name;
-(void)randomPositionWithView:(UIView*)view;
-(BOOL)shotInShapeWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;
@end
