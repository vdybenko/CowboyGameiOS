//
//  CDVisualViewCharacterPartSuits.m
//  Bounty Hunter
//
//  Created by Alex Novitsky on 5/15/13.
//
//

#import "CDVisualViewCharacterPartSuits.h"

@implementation CDVisualViewCharacterPartSuits
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
