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
@synthesize typeOfTable;
@synthesize arrayLegth;
@synthesize arrayShoose;

-(id) init
{
    self = [super init];
	
	if (self) {
        arrayHead = [NSMutableArray array];
        arrayCap = [NSMutableArray array];
        arrayBody = [NSMutableArray array];
        arrayLegth = [NSMutableArray array];
        arrayShoose = [NSMutableArray array];
        
        NSArray *arrayMainCap = VISUAL_VIEW_CHARACTER_CAP_ARRAY;
        for (NSArray *array in arrayMainCap) {
            CDVisualViewCharacterPartCap *cap=[[CDVisualViewCharacterPartCap alloc] initWithArray:array];
            [arrayCap addObject:cap];
        }
        arrayMainCap = nil;
    
        NSArray *arrayMainHead = VISUAL_VIEW_CHARACTER_HEAD_ARRAY;
        for (NSArray *array in arrayMainHead) {
            CDVisualViewCharacterPartHead *head=[[CDVisualViewCharacterPartHead alloc] initWithArray:array];
            [arrayHead addObject:head];
        }
        arrayMainHead = nil;
        
        NSArray *arrayMainBody = VISUAL_VIEW_CHARACTER_BODY_ARRAY;
        for (NSArray *array in arrayMainBody) {
            CDVisualViewCharacterPartBody *cap=[[CDVisualViewCharacterPartBody alloc] initWithArray:array];
            [arrayBody addObject:cap];
        }
        arrayMainBody = nil;
        
        NSArray *arrayMainLegth = VISUAL_VIEW_CHARACTER_LEGTH_ARRAY;
        for (NSArray *array in arrayMainLegth) {
            CDVisualViewCharacterPartLegth *cap=[[CDVisualViewCharacterPartLegth alloc] initWithArray:array];
            [arrayLegth addObject:cap];
        }
        arrayMainLegth = nil;
        
        NSArray *arrayMainShoose = VISUAL_VIEW_CHARACTER_SHOOSE_ARRAY;
        for (NSArray *array in arrayMainShoose) {
            CDVisualViewCharacterPartShoose *cap=[[CDVisualViewCharacterPartShoose alloc] initWithArray:array];
            [arrayShoose addObject:cap];
        }
        arrayMainShoose = nil;
    }
    
	return self;
}

-(void)releaseComponents
{
    arrayHead = nil;
    arrayCap = nil;
    arrayBody = nil;
    arrayLegth = nil;
    arrayShoose = nil;
}

@end
