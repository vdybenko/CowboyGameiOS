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

-(id)initWithArray:(NSArray*)arrayOfParametrs;
{
    self = [super init];
    if (self) {
        nameForImage = [arrayOfParametrs objectAtIndex:0];
//        rectForImage = CGRectFromString([[arrayOfParametrs objectAtIndex:1] string]);
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
