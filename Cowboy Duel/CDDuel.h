//
//  CDTransaction.h
//  Cowboy Duel
//
//  Created by Sergey Sobol on 29.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDDuel : NSObject<NSCoding>
{
    NSNumber *dRateFire;
    NSString *dOpponentId;
    NSNumber * dGps;
    NSString * dDate;
    
}

@property(nonatomic,strong) NSNumber *dRateFire;
@property(nonatomic,strong) NSString *dOpponentId;
@property(nonatomic, strong) NSNumber *dGps;
@property(nonatomic, strong) NSString *dDate;

@end

