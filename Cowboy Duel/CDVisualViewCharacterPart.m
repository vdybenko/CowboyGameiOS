//
//  CDVisualViewCharacterPart.m
//  Bounty Hunter
//
//  Created by Taras on 25.03.13.
//
//

#import "CDVisualViewCharacterPart.h"

@implementation CDVisualViewCharacterPart
@synthesize nameForImage;
@synthesize rectForImage;
@synthesize money;
@synthesize dId;

-(id)initWithArray:(NSArray*)arrayOfParametrs;
{
    self = [super init];
    if (self) {
        nameForImage = [arrayOfParametrs objectAtIndex:0];
        money = [[arrayOfParametrs objectAtIndex:1] integerValue];
        dId = [[arrayOfParametrs objectAtIndex:2] integerValue];
    }
    return self;
}

-(void)releaseComponents
{
    nameForImage = nil;
}

-(UIImage*) imageForObject;
{
    return [UIImage imageNamed:nameForImage];
}
@end
