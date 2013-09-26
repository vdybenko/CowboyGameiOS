//
//  UIViewController+popTO.m
//  Bounty Hunter 1.2
//
//  Created by Taras on 25.09.13.
//
//

#import "UIViewController+popTO.h"

@implementation UIViewController(popTo)

- (void) popToControllersNumber:(int)number animated:(BOOL)animated;
{
    if (number <= 1)
        [[self navigationController] popViewControllerAnimated:animated];
    else
    {
        NSArray* controller = [[self navigationController] viewControllers];
        int requiredIndex = [controller count] - number - 1;
        if (requiredIndex < 0) requiredIndex = 0;
        UIViewController* requireController = [[[self navigationController] viewControllers] objectAtIndex:requiredIndex];
        [[self navigationController] popToViewController:requireController animated:animated];
    }
}
- (BOOL) popToControllersClass:(Class)pClass animated:(BOOL)animated;
{
    UIViewController *vc = [self controllerOfClass:pClass];
    if (vc) {
        [[self navigationController] popToViewController:vc animated:animated];
        return YES;
    }else{
        return NO;
    }
}

- (UIViewController*) controllerOfClass:(Class)pClass;
{
    NSArray* controllers = [[self navigationController] viewControllers];
    for (UIViewController *vc in controllers) {
        if ([vc isKindOfClass:pClass]) {
            return vc;
        }
    }
    return nil;
}
@end
