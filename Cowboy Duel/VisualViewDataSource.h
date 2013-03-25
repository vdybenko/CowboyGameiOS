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

typedef enum {
    VisualViewCharacterPartHead,
    VisualViewCharacterPartCap,
    VisualViewCharacterPartBody
} VisualViewCharacterPart;

#define VISUAL_VIEW_CHARACTER_HEAD_ARRAY @[@[@"head1.png",@1],@[@"head2.png",@2],@[@"head3.png",@3],@[@"head4.png",@3]];

#define VISUAL_VIEW_CHARACTER_CAP_ARRAY @[@[@"cap2.png",@1],@[@"cap1.png",@2],@[@"cap2.png",@3]];

#define VISUAL_VIEW_CHARACTER_BODY_ARRAY @[@[@"body1.png",@1],@[@"body1.png",@2],@[@"body1.png",@3]];

@interface VisualViewDataSource : NSObject<MemoryManagement>
@property (strong,nonatomic) NSMutableArray *arrayHead;
@property (strong,nonatomic) NSMutableArray *arrayCap;
@property (strong,nonatomic) NSMutableArray *arrayBody;
@property (nonatomic) VisualViewCharacterPart typeOfTable;

-(CGRect) getRectForPart:(VisualViewCharacterPart)part withIndex:(NSInteger)index;
-(CGRect) getRectForPart:(VisualViewCharacterPart)part withName:(NSString*)name;
@end
