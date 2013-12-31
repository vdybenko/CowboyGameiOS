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
@synthesize lbUnlock;
@synthesize lbUnlock2;

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
-(void)lockedItemHiden:(BOOL)lock;
{
    [lockImg setHidden:lock];
    [lbUnlock setHidden:lock];
    [lbUnlock2 setHidden:lock];
}

-(void)setLockedLevel:(int)lockLevel;
{
    [lbUnlock setText:NSLocalizedString(@"UNLOCKED", @"")];
    [lbUnlock setText:[NSString stringWithFormat:NSLocalizedString(@"UNLOCKED", @""),lockLevel]];
}

-(void)rotateImage:(BOOL)turn;
{
    ivImage.transform = CGAffineTransformIdentity;
    if (turn) {
        ivImage.transform = CGAffineTransformMakeRotation((M_PI * 90 / 180.0));
    }
}
@end
