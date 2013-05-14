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

+(CharacterPartGridCell*) cell;
-(void)simpleBackGround;
-(void)selectedBackGround;
-(void)lockedItem;
@end
