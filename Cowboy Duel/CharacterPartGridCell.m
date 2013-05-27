//
//  CharacterPartGridCell.m
//  Bounty Hunter
//
//  Created by Taras on 13.05.13.
//
//

#import "CharacterPartGridCell.h"

@implementation CharacterPartGridCell
@synthesize ivBackGround;
@synthesize ivImage;
@synthesize lockImg;
+(CharacterPartGridCell*) cell {
    @autoreleasepool {
        NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"CharacterPartGridCell" owner:nil options:nil];
        return [objects objectAtIndex:0];
    }
}

-(void)simpleBackGround;
{
    [ivBackGround setHighlighted:NO];
}
-(void)selectedBackGround;
{
    [ivBackGround setHighlighted:YES];
}
-(void)lockedItem
{
    [lockImg setHidden:NO];
}

-(void)rotateImage:(BOOL)turn;
{
    ivImage.transform = CGAffineTransformIdentity;
    if (turn) {
        ivImage.transform = CGAffineTransformMakeRotation((M_PI * 90 / 180.0));
    }
}
@end
