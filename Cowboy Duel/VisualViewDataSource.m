//
//  VisualViewDataSource.m
//  Bounty Hunter
//
//  Created by Taras on 21.03.13.
//
//

#import "VisualViewDataSource.h"

// 1-image
// 2-price
// 3-id
// 4-action

#define VISUAL_VIEW_CHARACTER_CAP_ARRAY @[@[@"cap2.png",@100,@105,@3],@[@"cap1.png",@200,@106,@1],@[@"cap3.png",@300,@107,@4],@[@"cap4.png",@200,@116,@3]];

#define VISUAL_VIEW_CHARACTER_HEAD_ARRAY @[@[@"head1.png",@100,@101],@[@"head2.png",@200,@102],@[@"head3.png",@300,@103]];

#define VISUAL_VIEW_CHARACTER_BODY_ARRAY @[@[@"body1.png",@100,@108,@3],@[@"body2.png",@200,@109,@1],@[@"body3.png",@300,@110,@2]];

#define VISUAL_VIEW_CHARACTER_LEGS_ARRAY @[@[@"legth1.png",@300,@111,@2],@[@"legth2.png",@100,@112,@1],@[@"legth3.png",@100,@115,@1]];

#define VISUAL_VIEW_CHARACTER_SHOOSE_ARRAY @[@[@"shoose1.png",@200,@113,@3],@[@"shoose2.png",@10000,@114,@1]];

@interface VisualViewDataSource()
{
}
@end;

@implementation VisualViewDataSource
@synthesize arrayHead;
@synthesize arrayCap;
@synthesize arrayBody;
@synthesize typeOfTable;
@synthesize arrayLegs;
@synthesize arrayShoose;

-(id) init
{
    self = [super init];
	
	if (self) {
        arrayHead = [NSMutableArray array];
        arrayCap = [NSMutableArray array];
        arrayBody = [NSMutableArray array];
        arrayLegs = [NSMutableArray array];
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
        
        NSArray *arrayMainLegs = VISUAL_VIEW_CHARACTER_LEGS_ARRAY;
        for (NSArray *array in arrayMainLegs) {
            CDVisualViewCharacterPartLegs *cap=[[CDVisualViewCharacterPartLegs alloc] initWithArray:array];
            [arrayLegs addObject:cap];
        }
        arrayMainLegs = nil;
        
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
    arrayLegs = nil;
    arrayShoose = nil;
}

@end
