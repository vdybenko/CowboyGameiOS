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
@end
