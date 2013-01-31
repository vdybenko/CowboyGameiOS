//
//  GunDrumViewController.h
//  Cowboy Duels
//
//  Created by Taras on 31.01.13.
//
//

#import <UIKit/UIKit.h>

@interface GunDrumViewController : UIViewController<MemoryManagement>

-(void)openGun;
-(void)chargeBullets;
-(void)closeGun;
-(void)closeController;
@end
