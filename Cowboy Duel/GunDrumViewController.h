//
//  GunDrumViewController.h
//  Cowboy Duels
//
//  Created by Taras on 31.01.13.
//
//

#import <UIKit/UIKit.h>

@interface GunDrumViewController : UIViewController<MemoryManagement,UIGestureRecognizerDelegate>
@property (nonatomic) CGFloat chargeTime;
@property (nonatomic) BOOL isCharging;

-(void)openGun;
-(void)chargeBulletsForTime:(CGFloat)time;
-(void)closeDump;
-(void)showGun;
-(void)hideGun;
-(void)closeController;
-(void)shotAnimation;
@end
