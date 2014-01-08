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
#import "CDVisualViewCharacterPartGuns.h"
#import "CDVisualViewCharacterPartJakets.h"
#import "CDVisualViewCharacterPartSuits.h"
#import "CDBuiderPurchaseGold.h"

typedef enum
{
    CharacterPartCap,
    CharacterPartFace,
    CharacterPartShirt,
    CharacterPartLegs,
    CharacterPartShoose,
    CharacterPartGun,
    CharacterPartJaket,
    CharacterPartSuit
}CharacterPart;

@interface VisualViewDataSource : NSObject<MemoryManagement>
@property (strong,nonatomic) NSMutableArray *arrayHead;
@property (strong,nonatomic) NSMutableArray *arrayCap;
@property (strong,nonatomic) NSMutableArray *arrayBody;
@property (strong,nonatomic) NSMutableArray *arrayLegs;
@property (strong,nonatomic) NSMutableArray *arrayShoose;
@property (strong,nonatomic) NSMutableArray *arrayGuns;
@property (strong,nonatomic) NSMutableArray *arrayJakets;
@property (strong,nonatomic) NSMutableArray *arraySuits;
@property (strong,nonatomic) NSMutableArray *arrayGold;

@end
