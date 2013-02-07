//
//  CDFavPlayer.h
//  Bounty Hunter
//
//  Created by AlexandrBezpalchuk on 07.02.13.
//
//

#import <Foundation/Foundation.h>
#import "CDPlayerMain.h"

@interface CDFavPlayer : CDPlayerMain<NSCoding>
{
    int dDefense;
    int dAttack;
}

@property (nonatomic) int dDefense;
@property (nonatomic) int dAttack;

@end
