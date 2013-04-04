//
//  ScrollView.m
//  Cowboy Duel
//
//  Created by Sergey Sobol on 06.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define time 0.4
#define kScrollViewSwitcherNotification @"ScrollViewSwitcherNotification"

#import "ScrollViewSwitcher.h"
#import <QuartzCore/QuartzCore.h>
#import "CDVisualViewCharacterPart.h"

@interface ScrollViewSwitcher()
{
    CGPoint startPoint;
    UIImageView *leftImage;
    UIImageView *rightImage;
    UIImageView *centralImage;
    
    CGPoint ptLeftPosition;
    CGPoint ptCenterPosition;
    CGPoint ptRightPosition;
    
    GMGridView *grid;
}
@end
@implementation ScrollViewSwitcher
@synthesize didFinishBlock;
@synthesize arraySwitchObjects;
@synthesize rectForObjetc;
@synthesize curentObject;

#pragma mark

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        curentObject = 0;
    }
    return self;
}

-(void)releaseComponents
{
    didFinishBlock = nil;
    arraySwitchObjects = nil;
    leftImage = nil;
    rightImage = nil;
    centralImage = nil;
    grid = nil;
}

-(void)setMainControls;
{
    CGFloat differenceX = (self.frame.size.width - rectForObjetc.size.width)/2 - rectForObjetc.origin.x;
    grid = [[GMGridView alloc] initWithFrame:CGRectMake(-differenceX, rectForObjetc.origin.y, self.frame.size.width, self.frame.size.height)];
    grid.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontalPagedLTR];
    grid.minEdgeInsets = UIEdgeInsetsMake(0,100,0,100);
    grid.itemSpacing = 50.0;
    grid.backgroundColor = [UIColor clearColor];
    grid.dataSource = self;
    [self addSubview:grid];
}

#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [arraySwitchObjects count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(rectForObjetc.size.width, rectForObjetc.size.height);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    GMGridViewCell * cell = nil;;
    cell = [gridView dequeueReusableCellWithIdentifier:@"object"];
    
    if (cell == nil)
    {
        cell = [[GMGridViewCell alloc] init];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rectForObjetc.size.width, rectForObjetc.size.height)];
        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rectForObjetc.size.width, rectForObjetc.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:imageView];
        
    CDVisualViewCharacterPart *visualViewCharacterPart = [arraySwitchObjects objectAtIndex:index];
    imageView.image = [visualViewCharacterPart imageForObject];
    
    return cell;
}

#pragma mark

-(void)setObjectsForIndex:(NSInteger)index;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CDVisualViewCharacterPart *visualViewCharacterPart = [arraySwitchObjects objectAtIndex:index];
        centralImage.image = [visualViewCharacterPart imageForObject];
        if (index) {
            CDVisualViewCharacterPart *visualViewCharacterPartLeft = [arraySwitchObjects objectAtIndex:index-1];
            leftImage.image = [visualViewCharacterPartLeft imageForObject];
        }
        if (index<[arraySwitchObjects count]-1) {
            CDVisualViewCharacterPart *visualViewCharacterPartRight = [arraySwitchObjects objectAtIndex:index+1];
            rightImage.image = [visualViewCharacterPartRight imageForObject];
        }
    });
}

-(void)switchToRight
{
    if ((curentObject)&&([arraySwitchObjects count])) {
        [self setAllElementsHide:NO];
        [UIView animateWithDuration:time animations:^{
            CGRect frame = leftImage.frame;
            frame.origin = ptCenterPosition;
            leftImage.frame = frame;
            
            frame = centralImage.frame;
            frame.origin = ptRightPosition;
            centralImage.frame = frame;
        }completion:^(BOOL finished) {
            [self setAllElementsHide:YES];
            [self setStartPosition];
            curentObject--;
            [self setObjectsForIndex:curentObject];
            if (didFinishBlock) {
                didFinishBlock(curentObject);
            }
        }];
    }
}

-(void)switchToLeft
{
    if ((curentObject<[arraySwitchObjects count]-1)&&([arraySwitchObjects count])) {
        [self setAllElementsHide:NO];
        [UIView animateWithDuration:time animations:^{
            CGRect frame = rightImage.frame;
            frame.origin = ptCenterPosition;
            rightImage.frame = frame;
            
            frame = centralImage.frame;
            frame.origin = ptLeftPosition;
            centralImage.frame = frame;
        }completion:^(BOOL finished) {
            [self setAllElementsHide:YES];
            [self setStartPosition];
            curentObject++;
            [self setObjectsForIndex:curentObject];
            if (didFinishBlock) {
                didFinishBlock(curentObject);
            }
        }];
    }
}

-(void)setStartPosition
{
    CGRect frame = leftImage.frame;
    frame.origin = ptLeftPosition;
    leftImage.frame = frame;
    
    frame = centralImage.frame;
    frame.origin = ptCenterPosition;
    centralImage.frame = frame;

    frame = rightImage.frame;
    frame.origin = ptRightPosition;
    rightImage.frame = frame;
}

-(void)setAllElementsHide:(BOOL)hide
{
    leftImage.hidden = hide;
    centralImage.hidden = hide;
    rightImage.hidden = hide;
}

-(void)trimObjectsToView:(UIView*)view;
{
    CGPoint trimRect = [[view superview] convertPoint:view.frame.origin toView:self];
    rectForObjetc.origin.x = trimRect.x;
    rectForObjetc.origin.y = trimRect.y;
}

@end