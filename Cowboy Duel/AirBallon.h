//
//  AirBallon.h
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 22.03.13.
//
//

#import <UIKit/UIKit.h>

@interface AirBallon : UIView <MemoryManagement>
@property (weak, nonatomic) IBOutlet UIView *airBalloonView;
@property (weak, nonatomic) IBOutlet UIImageView *airBallonImg;
@property (weak, nonatomic) IBOutlet UIImageView *bonusImg;

-(void)airBallonMove;
-(void)explosionAnimation;
-(BOOL) isShownBonus;
-(BOOL)shotInObstracleWithPoint:(CGPoint)point superViewOfPoint:(UIView *)view;

@end
