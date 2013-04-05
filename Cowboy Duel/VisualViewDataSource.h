//
//  VisualViewDataSource.h
//  Bounty Hunter
//
//  Created by Taras on 21.03.13.
//
//

#import <Foundation/Foundation.h>
#import "VisualViewCharacterViewController.h"
#import "CDVisualViewCharacterPart.h"
#import "CDVisualViewCharacterPartCap.h"
#import "CDVisualViewCharacterPartHead.h"
#import "CDVisualViewCharacterPartBody.h"
#import "CDVisualViewCharacterPartLegs.h"
#import "CDVisualViewCharacterPartShoose.h"

typedef enum {
    VisualViewCharacterPartHead,
    VisualViewCharacterPartCap,
    VisualViewCharacterPartBody
} VisualViewCharacterPart;

// 1-image
// 2-price
// 3-id
// 4-action

#define VISUAL_VIEW_CHARACTER_HEAD_ARRAY @[@[@"head1.png",@100,@101],@[@"head2.png",@200,@102],@[@"head3.png",@300,@103],@[@"head4.png",@300,@104]];

#define VISUAL_VIEW_CHARACTER_CAP_ARRAY @[@[@"cap2.png",@100,@105,@3],@[@"cap1.png",@200,@106,@1],@[@"cap2.png",@300,@107,@4]];

#define VISUAL_VIEW_CHARACTER_BODY_ARRAY @[@[@"body1.png",@100,@108,@3],@[@"body1.png",@200,@109,@1],@[@"body1.png",@300,@110,@2]];

#define VISUAL_VIEW_CHARACTER_LEGS_ARRAY @[@[@"legth1.png",@300,@111,@2],@[@"legth1.png",@100,@112,@1]];

#define VISUAL_VIEW_CHARACTER_SHOOSE_ARRAY @[@[@"shoose1.png",@200,@113,@3],@[@"shoose1.png",@10000,@114,@1]];


@interface VisualViewDataSource : NSObject<MemoryManagement>
@property (strong,nonatomic) NSMutableArray *arrayHead;
@property (strong,nonatomic) NSMutableArray *arrayCap;
@property (strong,nonatomic) NSMutableArray *arrayBody;
@property (strong,nonatomic) NSMutableArray *arrayLegs;
@property (strong,nonatomic) NSMutableArray *arrayShoose;

@property (nonatomic) VisualViewCharacterPart typeOfTable;
@end
