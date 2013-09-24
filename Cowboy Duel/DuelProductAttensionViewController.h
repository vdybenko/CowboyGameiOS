//
//  DuelProductAttensionViewController.h
//  Bounty Hunter
//
//  Created by Taras on 26.10.12.
//
//

#import <UIKit/UIKit.h>
#import "AccountDataSource.h"

@interface DuelProductAttensionViewController : UIViewController<MemoryManagement>
- (id)initWithAccount:(AccountDataSource*)account parentVC:(UIViewController*)vc;
+ (BOOL)isAttensionNeedForOponent:(AccountDataSource*)oponentAccount;
@end
