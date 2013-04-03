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

typedef enum {
    OpponentShapeTypeManLow,
    OpponentShapeTypeMan,
    OpponentShapeTypeScarecrow
}OpponentShapeType;

@interface OpponentShape : Shape<MemoryManagement>

@property (weak, nonatomic) IBOutlet UIImageView *imgBody;
@property (weak, nonatomic) IBOutlet UIImageView *imgShot;
@property (weak, nonatomic) IBOutlet UIView *ivLifeBar;
@property (weak, nonatomic) IBOutlet UILabel *lbLifeLeft;
@property (weak, nonatomic) IBOutlet UIImageView *imgDieOpponentAnimation;
@property (nonatomic) OpponentShapeStatus opponentShapeStatus;


@property OpponentShapeType *typeOfBody;

-(void) moveAnimation;
-(void)moveOponentInBackground;
-(void) stopMoveAnimation;

-(void) shot;
-(void)reboundOnShot;

-(void) changeLiveBarWithUserHitCount:(int)userHitCount maxShotCount:(int)maxShotCount;
-(void) refreshLiveBarWithLives: (int )lives;

-(void) setStatusBody:(OpponentShapeStatus)status;
-(void) setBodyType:(OpponentShapeType)type;

-(void) hitTheOponentWithPoint:(CGPoint)hitPoint mainView:(UIView*)mainView;
-(void) cleareDamage;

@end
