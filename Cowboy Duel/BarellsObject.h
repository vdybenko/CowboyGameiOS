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
@property (weak, nonatomic) IBOutlet UIView *barellView;
@property (weak, nonatomic) IBOutlet UIImageView *barelAnimImg;

@property BOOL isTop;

-(void)explosionAnimation;
-(void)showBonus;
-(void)dropBarel;
-(BOOL) isShownBonus;
@end
