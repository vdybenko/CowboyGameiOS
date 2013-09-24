//
//  UIButton+Image+Title.h
//  Bounty Hunter 1
//
//  Created by Taras on 05.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIButton(Hierarchy)
-(void)setImage:(NSString *)pImag title:(NSString *)pTitle;
-(void)setImage:(NSString *)pImag;
-(void)setTitleByLabel:(NSString *)pTitle;
-(void)setTitleByLabel:(NSString *)pTitle withColor:(UIColor*)color fontSize:(CGFloat)size;
-(void)changeTitleByLabel:(NSString *)pTitle;
-(void)changeColorOfTitleByLabel:(UIColor *)pColor;
-(UILabel*)labelForTitle;

@end