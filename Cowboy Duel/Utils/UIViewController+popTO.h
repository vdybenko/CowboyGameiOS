//
//  UIViewController+popTO.h
//  Bounty Hunter 1.2
//
//  Created by Taras on 25.09.13.
//
//

#import <UIKit/UIKit.h>

@interface  UIViewController(popTo)
- (void) popToControllersNumber:(int)number animated:(BOOL)animated;
- (BOOL) popToControllersClass:(Class)pClass animated:(BOOL)animated;
- (UIViewController*) controllerOfClass:(Class)pClass;

@end
