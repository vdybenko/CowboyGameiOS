//
//  VisualViewDataSource.m
//  Bounty Hunter
//
//  Created by Taras on 21.03.13.
//
//

#import "VisualViewDataSource.h"
@interface VisualViewDataSource()
{
    
}
@end;

@implementation VisualViewDataSource
@synthesize arrayHead;
@synthesize arrayCap;
@synthesize arrayBody;

-(id) init;
{
    self = [super init];
	
	if (self) {
        arrayHead = VISUAL_VIEW_CHARACTER_HEAD_ARRAY;
        arrayCap = VISUAL_VIEW_CHARACTER_CAP_ARRAY;
        arrayBody = VISUAL_VIEW_CHARACTER_BODY_ARRAY;
	}
    
	return self;
}

-(void)releaseComponents
{
    arrayHead = nil;
    arrayCap = nil;
    arrayBody = nil;
}

-(CGRect) getRectForPart:(VisualViewCharacter)part withIndex:(NSInteger)index;
{}
-(CGRect) getRectForPart:(VisualViewCharacter)part withName:(NSString*)name;
{}
@end
