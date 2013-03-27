//
//  CDVisualViewCharacterPartBody.m
//  Bounty Hunter
//
//  Created by Taras on 25.03.13.
//
//

#import "CDVisualViewCharacterPartBody.h"

@implementation CDVisualViewCharacterPartBody
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
