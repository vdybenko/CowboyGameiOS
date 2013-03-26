//
//  ScrollView.h
//  Cowboy Duel
//
//  Created by Sergey Sobol on 06.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+AttachedView.h"

typedef void (^ScrollViewSwitcherResult)(NSInteger curentIndex);

@interface ScrollViewSwitcher : UIView<MemoryManagement>
@property (copy) ScrollViewSwitcherResult didFinishBlock;
@property (weak,nonatomic) NSArray *arraySwitchObjects;
@property (nonatomic) CGRect rectForObjetc;
@property (nonatomic) NSInteger curentObject;
@property (weak,nonatomic) UIImageView *colorizeImage;

-(void)setMainControls;
-(void)setObjectsForIndex:(NSInteger)index;
-(void)trimObjectsToView:(UIView*)view;
@end
