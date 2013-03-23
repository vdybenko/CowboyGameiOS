//
//  VisualViewDataSource.m
//  Bounty Hunter
//
//  Created by Taras on 21.03.13.
//
//

#import "VisualViewDataSource.h"
@interface VisualViewDataSource()
{
}
@end;

@implementation VisualViewDataSource
@synthesize arrayHead;
@synthesize arrayCap;
@synthesize arrayBody;
@synthesize arrayMain;
@synthesize typeOfTable;

-(id) initWithCollectionView:(UICollectionView*)cv;
{
    self = [super init];
	
	if (self) {
        arrayHead = VISUAL_VIEW_CHARACTER_HEAD_ARRAY;
        arrayCap = VISUAL_VIEW_CHARACTER_CAP_ARRAY;
        arrayBody = VISUAL_VIEW_CHARACTER_BODY_ARRAY;
        arrayMain = arrayCap;
        
        [cv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
	}
    
	return self;
}

-(void)releaseComponents
{
    arrayHead = nil;
    arrayCap = nil;
    arrayBody = nil;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return [arrayMain count]+3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *st = [arrayMain objectAtIndex:1];
    cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:st]];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = st;
    [cell addSubview:label];
    
    return cell;
}

#pragma mark

-(CGRect) getRectForPart:(VisualViewCharacterPart)part withIndex:(NSInteger)index;
{}
-(CGRect) getRectForPart:(VisualViewCharacterPart)part withName:(NSString*)name;
{}

@end
