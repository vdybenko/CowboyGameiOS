//
//  RefreshContentDataController.h
//  Cowboy Duel 1
//
//  Created by Taras on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"
#import "ValidationUtils.h"

@protocol RefreshContentDataControllerDelegate

-(void)finishRefresh;
-(void)finishWithError;

@end

@interface RefreshContentDataController : NSObject{
    int _numberRevision;
    NSMutableData *responseData;
    
    NSMutableArray *arrToInput;
    NSDictionary *elementOfArray;
    NSString *keyOfElement;
    NSString *keyForUserDefualts;
}
@property (strong, nonatomic) id<RefreshContentDataControllerDelegate> deledate;

+(BOOL) isRefreshEvailable:(int)serverRevision;
-(void) refreshContent;
-(NSString*)downloadImage:(NSString *)pUrl;

@end
