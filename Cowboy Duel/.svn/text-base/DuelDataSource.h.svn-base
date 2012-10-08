//
//  DuelDataSource.h
//  Test
//
//  Created by Sobol on 27.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountDataSource.h"


@interface DuelDataSource : NSObject {
    NSMutableURLRequest *__unsafe_unretained lastRequest;
    AccountDataSource *playerAccount;
    BOOL isAuthenticated;
    NSMutableData *receivedData;
}
@property(unsafe_unretained, nonatomic) NSMutableURLRequest *lastRequest;
@property (assign, readonly) BOOL isAuthenticated;

-(id)initWithLogin:(GKLocalPlayer *)localPlayer;

@end
