//
//  OpponentShape.h
//  Bounty Hunter
//
//  Created by Taras on 14.03.13.
//
//

#import <UIKit/UIKit.h>
#import "Shape.h"

typedef enum {
    OpponentShapeStatusLive,
    OpponentShapeStatusDead,
} OpponentShapeStatus;

@interface OpponentShape : Shape<MemoryManagement>
@property (weak, nonatomic) IBOutlet UIImageView *imgBody;
@property (weak, nonatomic) IBOutlet UIImageView *imgShot;
@property (weak, nonatomic) IBOutlet UIView *ivLifeBar;
@property (weak, nonatomic) IBOutlet UILabel *lbLifeLeft;
@property (weak, nonatomic) IBOutlet UIImageView *imgDieOpponentAnimation;
@property (nonatomic) OpponentShapeStatus opponentShapeStatus;


-(void) moveAnimation;
-(void)moveOponentInBackground;
-(void) stopMoveAnimation;

-(void) shot;
-(void)reboundOnShot;

-(void) changeLiveBarWithUserHitCount:(int)userHitCount maxShotCount:(int)maxShotCount;
-(void) refreshLiveBar;

-(void) setStatusBody:(OpponentShapeStatus)status;

-(void) hitTheOponentWithPoint:(CGPoint)hitPoint mainView:(UIView*)mainView;
-(void) cleareDamage;

@end
