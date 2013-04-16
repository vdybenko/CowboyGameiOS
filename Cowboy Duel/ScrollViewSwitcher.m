//
//  ScrollView.m
//  Cowboy Duel
//
//  Created by Sergey Sobol on 06.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollViewSwitcher.h"
#import "CDVisualViewCharacterPart.h"
#import <math.h>

@interface ScrollViewSwitcher()
{
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
    grid = nil;
}

-(void)setMainControls;
{
    CGFloat differenceX = (self.frame.size.width - rectForObjetc.size.width)/2 - rectForObjetc.origin.x;
    grid = [[GMGridView alloc] initWithFrame:CGRectMake(-differenceX, rectForObjetc.origin.y, self.frame.size.width,  rectForObjetc.size.height)];
    grid.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontalPagedLTR];
    grid.minEdgeInsets = UIEdgeInsetsMake(0,(self.frame.size.width - rectForObjetc.size.width)/4,0,(self.frame.size.width - rectForObjetc.size.width)/4);
    grid.itemSpacing = (self.frame.size.width - rectForObjetc.size.width)/2;
    
    grid.backgroundColor = [UIColor clearColor];
    grid.showsHorizontalScrollIndicator = NO;
    grid.showsVerticalScrollIndicator = NO;
    grid.dataSource = self;
    grid.delegate = self;
    
    [self addSubview:grid];
    [self setObjectsForIndex:curentObject];
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
        [cell.contentView setUserInteractionEnabled:NO];
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rectForObjetc.size.width, rectForObjetc.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:imageView];
        
    CDVisualViewCharacterPart *visualViewCharacterPart = [arraySwitchObjects objectAtIndex:index];
    imageView.image = [visualViewCharacterPart imageForObject];
    
    return cell;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    NSInteger curentObjectIndexScrool = abs(scrollView.contentOffset.x/self.frame.size.width);
    if (curentObject!=curentObjectIndexScrool) {
        curentObject = curentObjectIndexScrool;
        if (didFinishBlock) {
            didFinishBlock(curentObject);
        }
    }
}

#pragma mark

-(void)trimObjectsToView:(UIView*)view;
{
    CGPoint trimRect = [[view superview] convertPoint:view.frame.origin toView:self];
    rectForObjetc.origin.x = trimRect.x;
    rectForObjetc.origin.y = trimRect.y;
}

-(void)setObjectsForIndex:(NSInteger)index;
{
   [grid scrollToObjectAtIndex:index atScrollPosition:GMGridViewScrollPositionNone animated:NO];
}

@end