//
//  CDVisualViewCharacterPartShoose.m
//  Bounty Hunter
//
//  Created by Taras on 26.03.13.
//
//

#import "CDVisualViewCharacterPartShoose.h"

@implementation CDVisualViewCharacterPartShoose
@synthesize action;

-(id)initWithArray:(NSArray *)arrayOfParametrs
{
    self = [super initWithArray:arrayOfParametrs];
    if (self) {
        action = [[arrayOfParametrs objectAtIndex:indexOfLastStaticValues+1] integerValue];
    }
    return self;
}
@end
