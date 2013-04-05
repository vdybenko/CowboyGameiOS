

#import <UIKit/UIKit.h>

@interface CactusObject : UIView<MemoryManagement>
@property (weak, nonatomic) IBOutlet UIView *cactusView;
@property (weak, nonatomic) IBOutlet UIImageView *cactusImg;

-(BOOL)shotInObstracleWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;

-(void)explosionAnimation;
@end
