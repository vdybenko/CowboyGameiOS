

#import <UIKit/UIKit.h>

@interface CactusObject : UIView<MemoryManagement>
@property (strong, nonatomic) IBOutlet UIView *cactusView;
@property (weak, nonatomic) IBOutlet UIImageView *cactusImg;

-(void)explosionAnimation;
@end
