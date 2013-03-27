//
//  CDVisualViewCharacterPartLegth.m
//  Bounty Hunter
//
//  Created by Taras on 26.03.13.
//
//

#import "CDVisualViewCharacterPartLegth.h"

@implementation CDVisualViewCharacterPartLegth
@synthesize action;

-(id)initWithArray:(NSArray *)arrayOfParametrs
{
    self = [super initWithArray:arrayOfParametrs];
    if (self) {
        action = [[arrayOfParametrs objectAtIndex:2] integerValue];
    }
    return self;
}
@end
