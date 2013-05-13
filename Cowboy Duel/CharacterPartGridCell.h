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

+(CharacterPartGridCell*) cell;
-(void)simpleBackGround;
-(void)selectedBackGround;
@end
