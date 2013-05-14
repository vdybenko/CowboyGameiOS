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
// 4-lockLevel
// 5-action

//Тут все елементы по 6 штук

//Hats
#define VISUAL_VIEW_CHARACTER_CAP_ARRAY @[@[@"builderHat1.png",@100,@105,@-1,@3],@[@"builderHat2.png",@200,@106,@2,@1],@[@"builderHat2.png",@300,@107,@2,@4],@[@"builderHat1.png",@200,@108,@3,@3],@[@"builderHat2.png",@200,@109,@3,@3],@[@"builderHat1.png",@200,@110,@4,@3]]; // Resorces/CharacterHats

//Faces
#define VISUAL_VIEW_CHARACTER_HEAD_ARRAY @[@[@"builderFace1.png",@100,@111,@-1],@[@"builderFace2.png",@200,@112,@2],@[@"builderFace1.png",@300,@113,@2],@[@"builderFace2.png",@300,@114,@3],@[@"builderFace1.png",@300,@115,@3],@[@"builderFace2.png",@300,@116,@4]];// Resorces/CharacterFaces

//Sirts
#define VISUAL_VIEW_CHARACTER_BODY_ARRAY @[@[@"builderShirt1.png",@100,@117,@-1,@3],@[@"builderShirt2.png",@200,@118,@2,@1],@[@"builderShirt3.png",@300,@119,@2,@2],@[@"builderShirt4.png",@100,@120,@3,@3],@[@"builderShirt1.png",@100,@121,@3,@3],@[@"builderShirt2.png",@100,@122,@4,@3]]; // Resorces/CharacterSirts

//Pants 
#define VISUAL_VIEW_CHARACTER_LEGS_ARRAY @[@[@"builderPants1.png",@300,@123,@-1,@2],@[@"builderPants2.png",@100,@124,@2,@1],@[@"builderPants3.png",@100,@125,@2,@1],@[@"builderPants1.png",@100,@126,@3,@1],@[@"builderPants2.png",@100,@127,@3,@1],@[@"builderPants3.png",@100,@128,@4,@1]];// Resorces/CharacterPants

//Shoes
#define VISUAL_VIEW_CHARACTER_SHOOSE_ARRAY @[@[@"buildershoes1.png",@200,@129,@-1,@3],@[@"buildershoes1.png",@10000,@130,@2,@1],@[@"buildershoes1.png",@10000,@131,@2,@1],@[@"buildershoes1.png",@10000,@132,@3,@1],@[@"buildershoes1.png",@10000,@133,@3,@1],@[@"buildershoes1.png",@10000,@134,@4,@1]];// Resorces/CharacterShoeses

//Guns
#define VISUAL_VIEW_CHARACTER_GUNS_ARRAY @[@[@"builderGunInHeand.png",@200,@135,@-1,@3],@[@"builderGunInHeand.png",@10000,@136,@2,@1],@[@"builderGunInHeand.png",@10000,@137,@2,@1],@[@"builderGunInHeand.png",@10000,@138,@3,@1],@[@"builderGunInHeand.png",@10000,@139,@3,@1],@[@"builderGunInHeand.png",@10000,@140,@4,@1]];// Resorces/CharacterGuns

//Jakets
#define VISUAL_VIEW_CHARACTER_JAKETS_ARRAY @[@[@"builderJacket1.png",@200,@141,@-1,@3],@[@"builderJacket2.png",@10000,@142,@2,@1],@[@"builderJacket1.png",@10000,@143,@2,@1],@[@"builderJacket2.png",@10000,@144,@3,@1],@[@"builderJacket1.png",@10000,@145,@3,@1],@[@"builderJacket2.png",@10000,@146,@4,@1]];// Resorces/CharacterJakets






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
@synthesize arrayGuns;
@synthesize arrayJakets;

-(id) init
{
    self = [super init];
	
	if (self) {
        arrayHead = [NSMutableArray array];
        arrayCap = [NSMutableArray array];
        arrayBody = [NSMutableArray array];
        arrayLegs = [NSMutableArray array];
        arrayShoose = [NSMutableArray array];
        arrayJakets = [NSMutableArray array];
        arrayGuns = [NSMutableArray array];
        
        
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
        
        NSArray *arrayMainGuns = VISUAL_VIEW_CHARACTER_GUNS_ARRAY;
        for (NSArray *array in arrayMainGuns) {
            CDVisualViewCharacterPartGuns *cap=[[CDVisualViewCharacterPartGuns alloc] initWithArray:array];
            [arrayGuns addObject:cap];
        }
        arrayMainGuns = nil;
        
        NSArray *arrayMainJakets = VISUAL_VIEW_CHARACTER_JAKETS_ARRAY;
        for (NSArray *array in arrayMainJakets) {
            CDVisualViewCharacterPartJakets *cap=[[CDVisualViewCharacterPartJakets alloc] initWithArray:array];
            [arrayJakets addObject:cap];
        }
        arrayMainJakets = nil;
        
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
    arrayJakets = nil;
    arrayGuns = nil;
}

@end
