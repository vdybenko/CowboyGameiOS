//
//  MoneyCongratViewController.h
//  Bounty Hunter 1
//
//  Created by AlexandrBezpalchuk on 02.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"
#import "ActivityIndicatorView.h"

@interface MoneyCongratViewController : UIViewController<MemoryManagement>
- (id) initForAchivmentPlayerAccount:(AccountDataSource *)pPlayerAccount withLabel:(NSString*)pLabel andController:(id)delegateController tryButtonEnable:(BOOL)tryButtonEnable;
-(void)blockTryAgain;
+(void)achivmentMoney:(NSUInteger)money;

@end
