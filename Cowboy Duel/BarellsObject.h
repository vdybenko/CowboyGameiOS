//
//  BarellsObject.h
//  Bounty Hunter
//
//  Created by Bezpalchuk Olexandr on 21.03.13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    BarellPositionBottom,
    BarellPositionMiddle,
    BarellPositionHighest
} BarellPosition;

@interface BarellsObject : UIView <MemoryManagement>
@property (weak, nonatomic) IBOutlet UIImageView *bonusImg;
@property (weak, nonatomic) IBOutlet UIView *barellView;
@property (weak, nonatomic) IBOutlet UIImageView *barelAnimImg;

@property (weak, nonatomic) IBOutlet UIImageView *barellImgBottom;
@property (weak, nonatomic) IBOutlet UIImageView *barellImgHighest;
@property (weak, nonatomic) IBOutlet UIImageView *barellImgMiddle;



@property (nonatomic) BarellPosition barellPosition;
-(void)explosionAnimation;
-(void)showBonus;
-(void)dropBarel:(UIImageView *)barellImg;
-(BOOL) isShownBonus;
@end
