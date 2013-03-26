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
#import "CDVisualViewCharacterPartLegth.h"
#import "CDVisualViewCharacterPartShoose.h"

typedef enum {
    VisualViewCharacterPartHead,
    VisualViewCharacterPartCap,
    VisualViewCharacterPartBody
} VisualViewCharacterPart;

#define VISUAL_VIEW_CHARACTER_HEAD_ARRAY @[@[@"head1.png",@1],@[@"head2.png",@2],@[@"head3.png",@3],@[@"head4.png",@3]];

#define VISUAL_VIEW_CHARACTER_CAP_ARRAY @[@[@"cap2.png",@1],@[@"cap1.png",@2],@[@"cap2.png",@3]];

#define VISUAL_VIEW_CHARACTER_BODY_ARRAY @[@[@"body1.png",@1],@[@"body1.png",@2],@[@"body1.png",@3]];

#define VISUAL_VIEW_CHARACTER_LEGTH_ARRAY @[@[@"legth1.png",@1],@[@"legth1.png",@1]];

#define VISUAL_VIEW_CHARACTER_SHOOSE_ARRAY @[@[@"shoose1.png",@1],@[@"shoose1.png",@1]];


@interface VisualViewDataSource : NSObject<MemoryManagement>
@property (strong,nonatomic) NSMutableArray *arrayHead;
@property (strong,nonatomic) NSMutableArray *arrayCap;
@property (strong,nonatomic) NSMutableArray *arrayBody;
@property (strong,nonatomic) NSMutableArray *arrayLegth;
@property (strong,nonatomic) NSMutableArray *arrayShoose;

@property (nonatomic) VisualViewCharacterPart typeOfTable;
@end
