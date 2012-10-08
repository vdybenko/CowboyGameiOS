//
//  ScrollView.h
//  Cowboy Duel
//
//  Created by Sergey Sobol on 06.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScrollViewCustom
-(void)scrollShow;
-(void)scrollHide;
-(void)clickLeftBtn;
-(void)clickRightBtn;
@end

@interface ScrollView : UIView
{
    id __unsafe_unretained delegate;
    CGPoint startPoint;
}
@property ( unsafe_unretained, readwrite)id<ScrollViewCustom> delegate;

@end
