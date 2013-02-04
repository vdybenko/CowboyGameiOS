//
//  GunDrumViewController.h
//  Cowboy Duels
//
//  Created by Taras on 31.01.13.
//
//

#import <UIKit/UIKit.h>
//#import <Core>

@interface GunDrumViewController : UIViewController<MemoryManagement>
@property (nonatomic) CGFloat chargeTime;
@property (nonatomic) BOOL isCharging;

-(void)openGun;
-(void)chargeBulletsForTime:(CGFloat)time;
-(void)closeDump;
-(void)showGun;
-(void)hideGun;
-(void)closeController;
@end
