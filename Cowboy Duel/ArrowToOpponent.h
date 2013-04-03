//
//  ArrowToOpponent.h
//  Bounty Hunter
//
//  Created by Taras on 20.03.13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    ArrowToOpponentDirectionLeft,
    ArrowToOpponentDirectionRight,
    ArrowToOpponentDirectionCenter
} ArrowToOpponentDirection;

@interface ArrowToOpponent : UIView<MemoryManagement>
@property (weak, nonatomic) IBOutlet UIImageView *ivOpponent;
- (void) setDirection:(ArrowToOpponentDirection)direction;
- (void) updateRelateveToView:(UIView*)view mainView:(UIView*)mainView;

@end
