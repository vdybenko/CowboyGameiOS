//
//  BuilderViewController.h
//  Bounty Hunter
//
//  Created by Alex Novitsky on 5/6/13.
//
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"
#import "VisualViewDataSource.h"
#import "DuelProductDownloaderController.h"

@class VisualViewDataSource;

@protocol BuilderViewControllerDelegate <NSObject>

@optional
-(void) grid:(GMGridView*)grid selectIndex:(NSInteger)index forType:(CharacterPart)type;
-(void) grid:(GMGridView*)grid buyProductForIndex:(NSInteger)index forType:(CharacterPart)type;
@end

@interface BuilderViewController : UIViewController<MemoryManagement,GMGridViewDataSource,GMGridViewActionDelegate,UIScrollViewDelegate,BuilderViewControllerDelegate,DuelProductDownloaderControllerDelegate>

@property (strong, nonatomic) VisualViewDataSource *visualViewDataSource;
@property (nonatomic) NSInteger curentObject;
@end
