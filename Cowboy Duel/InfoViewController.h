//
//  InfoViewController.h
//  Bounty Hunter 1.2
//
//  Created by Taras on 02.12.13.
//
//

#import <UIKit/UIKit.h>
typedef void(^InfoViewControllerBlock)();

@interface InfoViewController : UIViewController
@property(copy,nonatomic) InfoViewControllerBlock blkFinish;

-(id)initWithText:(NSString*)text interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(id)initWithText:(NSString*)text interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation withButtonTitle:(NSString*)title block:(InfoViewControllerBlock)block ;

@end
