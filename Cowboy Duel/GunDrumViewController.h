//
//  GunDrumViewController.h
//  Cowboy Duels
//
//  Created by Taras on 31.01.13.
//
//

#import <UIKit/UIKit.h>

@interface GunDrumViewController : UIViewController<MemoryManagement,UIGestureRecognizerDelegate>
@property (nonatomic) BOOL isCharging;
@property (nonatomic) BOOL countOfBullets;
@property (weak, nonatomic) IBOutlet UIImageView *ivOponnentAvatar;

-(void)openGun;
-(void)closeDump;
-(void)showGun;
-(void)hideGun;
-(void)closeController;
-(void)shotAnimation;
@end
