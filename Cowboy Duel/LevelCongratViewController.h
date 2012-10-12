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
#import "DuelViewController.h"
#import "ActivityIndicatorView.h"

@interface LevelCongratViewController : UIViewController
- (id) initForNewLevelPlayerAccount:(AccountDataSource *)pPlayerAccount andController:(id)delegateController;
+(void)newLevelNumber:(NSInteger)level;

@end
