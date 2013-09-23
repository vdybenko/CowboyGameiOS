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
#define VISUAL_VIEW_CHARACTER_CAP_ARRAY @[@[@"clearePicture.png",@0,@105,@-1,@0],@[@"builderHat2.png",@100,@106,@-1,@2],@[@"builderHat3.png",@100,@107,@-1,@2],@[@"builderHat1.png",@100,@108,@-1,@2]]; // Resorces/CharacterHats

//Faces
#define VISUAL_VIEW_CHARACTER_HEAD_ARRAY @[@[@"builderFace3.png",@0,@111,@-1,@0],@[@"builderFace1.png",@200,@112,@-1,@2],@[@"builderFace2.png",@300,@113,@2,@4]];// Resorces/CharacterFaces

//Sirts
#define VISUAL_VIEW_CHARACTER_BODY_ARRAY @[@[@"builderShirt4.png",@0,@117,@-1,@0],@[@"builderShirt5.png",@100,@118,@-1,@2],@[@"builderShirt3.png",@100,@119,@-1,@2],@[@"builderShirt2.png",@150,@120,@3,@3]]; // Resorces/CharacterSirts

//Pants 
#define VISUAL_VIEW_CHARACTER_LEGS_ARRAY @[@[@"builderPantsDef.png",@0,@123,@-1,@0],@[@"builderPants3.png",@100,@124,@-1,@1],@[@"builderPants2.png",@200,@125,@-1,@2],@[@"builderPants1.png",@250,@126,@3,@3]];// Resorces/CharacterPants

//Shoes
#define VISUAL_VIEW_CHARACTER_SHOOSE_ARRAY @[@[@"clearePicture.png",@0,@129,@-1,@0],@[@"buildershoes1.png",@200,@130,@-1,@4],@[@"buildershoes2.png",@200,@131,@-1,@4],@[@"buildershoes3.png",@250,@132,@-1,@4]];// Resorces/CharacterShoeses

//Guns
#define VISUAL_VIEW_CHARACTER_GUNS_ARRAY @[@[@"builderGunInHeand.png",@0,@135,@-1,@0],@[@"builderGunInHeand2.png",@200,@136,@-1,@5],@[@"builderGunInHeand3.png",@300,@137,@-1,@6],@[@"builderGunInHeand4.png",@400,@138,@3,@7]];// Resorces/CharacterGuns

//Jakets
#define VISUAL_VIEW_CHARACTER_JAKETS_ARRAY @[@[@"clearePicture.png",@0,@141,@-1,@0],@[@"builderJacket2.png",@200,@142,@-1,@2],@[@"builderJacket1.png",@250,@143,@2,@3],@[@"builderJacket3.png",@250,@143,@2,@3]];// Resorces/CharacterJakets

#define VISUAL_VIEW_CHARACTER_SUITS_ARRAY @[@[@"clearePicture.png",@0,@147,@-1,@0],@[@"builderSuit2.png",@600,@148,@-1,@10],@[@"builderSuit3.png",@600,@149,@-1,@10],@[@"builderSuit1.png",@600,@150,@5,@13]];// Resorces/CharacterSuits

@interface VisualViewDataSource()
{
}
@end;

@implementation VisualViewDataSource
@synthesize arrayHead;
@synthesize arrayCap;
@synthesize arrayBody;
@synthesize arrayLegs;
@synthesize arrayShoose;
@synthesize arrayGuns;
@synthesize arrayJakets;
@synthesize arraySuits;

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
        arraySuits = [NSMutableArray array];
        
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
        
        NSArray *arrayMainSuits = VISUAL_VIEW_CHARACTER_SUITS_ARRAY;
        for (NSArray *array in arrayMainSuits) {
            CDVisualViewCharacterPartSuits *cap=[[CDVisualViewCharacterPartSuits alloc] initWithArray:array];
            [arraySuits addObject:cap];
        }
        arrayMainSuits = nil;
        
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
    arraySuits = nil;
}

@end
