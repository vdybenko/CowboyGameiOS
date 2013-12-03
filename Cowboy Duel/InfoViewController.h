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

-(id)initWithText:(NSString*)text;
-(id)initWithText:(NSString*)text withButtonTitle:(NSString*)title block:(InfoViewControllerBlock)block;

@end
