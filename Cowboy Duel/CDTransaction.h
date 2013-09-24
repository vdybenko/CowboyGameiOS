//
//  Bounty Hunter
//
//  Created by Sergey Sobol on 29.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDTransaction : NSObject<NSCoding>
{
    NSNumber * trType;
    NSNumber * trMoneyCh;
    NSString * trDescription;
    NSNumber * trLocalID;
    NSNumber * trGlobalID;
    NSString * trOpponentID;
   
}

@property(nonatomic, strong) NSNumber *trType;
@property(nonatomic, strong) NSNumber *trMoneyCh;
@property(nonatomic, strong) NSString *trDescription;
@property(nonatomic, strong) NSNumber *trLocalID;
@property(nonatomic, strong) NSNumber *trGlobalID;
@property(nonatomic, strong) NSString * trOpponentID;

@end
