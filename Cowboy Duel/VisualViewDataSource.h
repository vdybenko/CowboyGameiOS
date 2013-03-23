//
//  VisualViewDataSource.h
//  Bounty Hunter
//
//  Created by Taras on 21.03.13.
//
//

#import <Foundation/Foundation.h>
#import "VisualViewCharacterViewController.h"

typedef enum {
    VisualViewCharacterPartHead,
    VisualViewCharacterPartCap,
    VisualViewCharacterPartBody
} VisualViewCharacterPart;

typedef enum {
    VisualViewCharacterHeadList1
} VisualViewCharacterHeadList;

#define VISUAL_VIEW_CHARACTER_HEAD_ARRAY @[@"head1.png"];

typedef enum {
    VisualViewCharacterCapList1,
    VisualViewCharacterCapList2
} VisualViewCharacterCapList;

#define VISUAL_VIEW_CHARACTER_CAP_ARRAY @[@"cap1.png",@"cap2.png"];

typedef enum {
    VisualViewCharacterBodyList1
} VisualViewCharacterBodyList;

#define VISUAL_VIEW_CHARACTER_BODY_ARRAY @[@"body1.png"];

@interface VisualViewDataSource : NSObject<MemoryManagement,UICollectionViewDataSource>
@property (weak,nonatomic) NSArray *arrayHead;
@property (weak,nonatomic) NSArray *arrayCap;
@property (weak,nonatomic) NSArray *arrayBody;
@property (weak,nonatomic) NSArray *arrayMain;
@property (nonatomic) VisualViewCharacterPart typeOfTable;

-(id) initWithCollectionView:(UICollectionView*)cv;
-(CGRect) getRectForPart:(VisualViewCharacterPart)part withIndex:(NSInteger)index;
-(CGRect) getRectForPart:(VisualViewCharacterPart)part withName:(NSString*)name;
@end
