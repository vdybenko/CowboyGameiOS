//
//  CDPlayerOnLine.h
//  Bounty Hunter 1
//
//  Created by Taras on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDPlayerMain.h"

@interface CDTopPlayer : CDPlayerMain<NSCoding>
{
    int dPoints;
    int dPositionInList;
}
@property(nonatomic) int dPoints;
@property(nonatomic) int dPositionInList;

@end
