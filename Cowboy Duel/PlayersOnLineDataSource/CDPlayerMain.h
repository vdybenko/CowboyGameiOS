//
//  CDPlayerOnLine.h
//  Bounty Hunter 1
//
//  Created by Taras on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDPlayerMain : NSObject<NSCoding>
{
    NSString *dAuth;
    NSString *dNickName;
    NSString *dAvatar;
    int dMoney;
    int dLevel;
}
@property(nonatomic,strong) NSString *dAuth;
@property(nonatomic,strong) NSString *dNickName;
@property(nonatomic,strong) NSString *dAvatar;
@property(nonatomic) int dMoney;
@property(nonatomic) int dLevel;

@end
