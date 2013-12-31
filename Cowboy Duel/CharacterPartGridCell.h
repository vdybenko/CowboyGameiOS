//
//  CharacterPartGridCell.h
//  Bounty Hunter
//
//  Created by Taras on 13.05.13.
//
//

#import "GMGridViewCell.h"

@interface CharacterPartGridCell : GMGridViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ivBackGround;
@property (weak, nonatomic) IBOutlet UIImageView *ivImage;
@property (weak, nonatomic) IBOutlet UIImageView *lockImg;
@property (weak, nonatomic) IBOutlet UILabel *lbUnlock;
@property (weak, nonatomic) IBOutlet UILabel *lbUnlock2;

+(CharacterPartGridCell*) cell;
-(void)simpleBackGround;
-(void)selectedBackGround;
-(void)lockedItemHiden:(BOOL)lock;
-(void)setLockedLevel:(int)lockLevel;
-(void)rotateImage:(BOOL)turn;
@end
