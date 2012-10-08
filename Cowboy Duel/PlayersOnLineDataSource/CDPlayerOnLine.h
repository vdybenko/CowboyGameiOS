//
//  CDPlayerOnLine.h
//  Cowboy Duel 1
//
//  Created by Taras on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDPlayerMain.h"

@interface CDPlayerOnLine : CDPlayerMain<NSCoding>
{
    NSString * dPlayerIP;
    NSString * dPlayerPublicIP;
    int dWinCount;
    BOOL dOnline;
    BOOL dInTop;
}
@property(nonatomic, strong) NSString * dPlayerIP;
@property(nonatomic, strong) NSString * dPlayerPublicIP;
@property(nonatomic) int dWinCount;
@property(nonatomic) BOOL dOnline;
@property(nonatomic) BOOL dInTop;


@end
