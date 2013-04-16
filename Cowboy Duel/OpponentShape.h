//
//  OpponentShape.h
//  Bounty Hunter
//
//  Created by Taras on 14.03.13.
//
//

#import <UIKit/UIKit.h>
#import "Shape.h"
#import "AccountDataSource.h"
#import "VisualViewCharacter.h"

typedef enum {
    OpponentShapeStatusLive,
    OpponentShapeStatusDead,
} OpponentShapeStatus;

typedef enum {
    OpponentShapeTypeManLow,
    OpponentShapeTypeScarecrow
}OpponentShapeType;

@interface OpponentShape : Shape<MemoryManagement>
@property (weak, nonatomic) IBOutlet UIImageView *imgBody;
@property (weak, nonatomic) IBOutlet UIImageView *imgShot;
@property (weak, nonatomic) IBOutlet UIView *ivLifeBar;
@property (weak, nonatomic) IBOutlet UILabel *lbLifeLeft;
@property (weak, nonatomic) IBOutlet UIImageView *imgDieOpponentAnimation;
@property (weak, nonatomic) IBOutlet IBOutlet VisualViewCharacter *visualViewCharacter;
@property (nonatomic) OpponentShapeStatus opponentShapeStatus;
@property (nonatomic) OpponentShapeType typeOfBody;
@property (weak, nonatomic) AccountDataSource *playerAccount;

-(void)refreshWithAccountPlayer:(AccountDataSource*)player;

-(void) moveAnimation;
-(void)moveOponentInBackground;
-(void) stopMoveAnimation;

-(void) shot;
-(void)reboundOnShot;

-(void) changeLiveBarWithUserHitCount:(int)userHitCount maxShotCount:(int)maxShotCount;
-(void) refreshLiveBarWithLives: (int )lives;

-(void) setStatusBody:(OpponentShapeStatus)status;
-(void) setBodyType:(OpponentShapeType)type;

-(int) damageForHitTheOponentWithPoint:(CGPoint)hitPoint mainView:(UIView*)mainView;
-(void) cleareDamage;

@end
