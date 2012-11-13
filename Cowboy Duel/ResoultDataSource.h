//
//  ResoultDataSource.h
//  Test
//
//  Created by Sobol on 06.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResoultDataSource : NSObject {
    int mutchNumber;
	int deltaTime;
    BOOL result;
    int UserTime;
    BOOL deadHeat;
}
@property(nonatomic) int mutchNumber;
@property(nonatomic) int deltaTime;
@property(nonatomic) BOOL result;
@property(nonatomic) BOOL foll;
@property(nonatomic) int UserTime;
@property(nonatomic) BOOL deadHeat;


-(id)init;
@end
