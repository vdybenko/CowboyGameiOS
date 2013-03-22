//
//  BarellsObject.h
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 21.03.13.
//
//

#import <UIKit/UIKit.h>


@interface BarellsObject : UIView <MemoryManagement>
@property (weak, nonatomic) IBOutlet UIImageView *bonusImg;
@property (weak, nonatomic) IBOutlet UIImageView *barellImg;
@property (strong, nonatomic) IBOutlet UIView *barellView;



-(void)explosionAnimation;
-(BOOL)showBonus;
-(void)gettingShot;
@end
