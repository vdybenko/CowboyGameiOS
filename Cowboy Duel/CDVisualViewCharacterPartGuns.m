//
//  CDVisualViewCharacterPartGuns.m
//  Bounty Hunter
//
//  Created by Alex Novitsky on 5/10/13.
//
//

#import "CDVisualViewCharacterPartGuns.h"

@implementation CDVisualViewCharacterPartGuns
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
