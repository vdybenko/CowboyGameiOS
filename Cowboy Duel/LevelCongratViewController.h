//
//  LevelCongratViewController.h
//  Cowboy Duel 1
//
//  Created by AlexandrBezpalchuk on 02.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AccountDataSource.h"
#import "ActivityIndicatorView.h"

@interface LevelCongratViewController : UIViewController<MemoryManagement>
- (id) initForNewLevelPlayerAccount:(AccountDataSource *)pPlayerAccount andController:(id)delegateController tryButtonEnable:(BOOL)tryButtonEnable;
-(void)blockTryAgain;
+(void)newLevelNumber:(NSInteger)level;

@end
