//
//  GunDrumViewController.h
//  Cowboy Duels
//
//  Created by Taras on 31.01.13.
//
//

#import <UIKit/UIKit.h>
@class GunDrumViewController;
typedef void (^GunDrumViewControllerResult)();


@interface GunDrumViewController : UIViewController<MemoryManagement,UIGestureRecognizerDelegate>
@property (nonatomic) BOOL isCharging;
@property (nonatomic) BOOL countOfBullets;
@property (weak, nonatomic) IBOutlet UIImageView *ivOponnentAvatar;
@property (copy) GunDrumViewControllerResult didFinishBlock;

-(void)openGun;
-(void)showGun;
-(void)hideGun;
-(void)closeController;
-(void)shotAnimation;
@end
