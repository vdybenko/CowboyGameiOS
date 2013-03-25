//
//  CDVisualViewCharacterPartCap.m
//  Bounty Hunter
//
//  Created by Taras on 25.03.13.
//
//

#import "CDVisualViewCharacterPartCap.h"

@implementation CDVisualViewCharacterPartCap
@synthesize action;

-(id)initWithArray:(NSArray *)arrayOfParametrs
{
    self = [super initWithArray:arrayOfParametrs];
    if (self) {
        action = [arrayOfParametrs objectAtIndex:1];
    }
    return self;
}

@end
