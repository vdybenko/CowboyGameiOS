//
//  ItemsDataSource.m
//  ScopeAndSequence
//
//  Created by Developer on 21.06.11.
//  Copyright 2011 Company Name. All rights reserved.
//

#import "ItemsDataSource.h"

@implementation ItemsDataSource
@synthesize arrItemsList,collectionAppWrapper;

#define TAG_IMAGE 1001
#define TAG_TEXT 1002
#define TAG_DETAIL_TEXT 1003

#pragma mark - Instance initialization

-(id) init {
	self = [super init];
	
	if (self) {
		collectionAppWrapper=[[CollectionAppWrapper alloc]init];
        [self reloadDataSource];
	}
	return self;
}

-(void) reloadDataSource;
{
    NSData *loadData = [[NSUserDefaults standardUserDefaults] objectForKey:@"colectionApp"];
    arrItemsList=[[NSArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:loadData]];
    
    for (CDCollectionApp *_app in arrItemsList) {
        [collectionAppWrapper checkAllAppForInstall:_app];
    }
    NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:arrItemsList];
    [[NSUserDefaults standardUserDefaults] setObject:saveData forKey:@"colectionApp"];
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *subjectCellIdentifier = @"itemCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:subjectCellIdentifier];
    
    UIImageView *customImage;
    UILabel *customDetailText;
    UILabel *customText;
    UIWebView *webMainText;
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subjectCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setShowsReorderControl:YES];
        [cell setShouldIndentWhileEditing:YES];        
        
        customImage=[[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 78, 60)];
        [customImage setTag:TAG_IMAGE];
        [cell.contentView addSubview:customImage];
        
        customText=[[UILabel alloc] initWithFrame:CGRectMake(90, 3, 230, 50)];
        customText.textColor = [UIColor blackColor];
		customText.font = [UIFont systemFontOfSize:14.0f];
        [customText setTextAlignment:UITextAlignmentLeft];
        [customText setTag:TAG_TEXT];
        [customText setNumberOfLines:3];
        [cell.contentView addSubview:customText];   

        
        customDetailText=[[UILabel alloc] initWithFrame:CGRectMake(90, 56, 230, 15)];
        customDetailText.textColor = [UIColor grayColor];
        [customDetailText setTag:TAG_DETAIL_TEXT];
		customDetailText.font = [UIFont systemFontOfSize:12.0f];
        [cell.contentView addSubview:customDetailText];
        
    }else {
        customImage=(UIImageView *)[cell viewWithTag:TAG_IMAGE];
        customDetailText=(UILabel*)[cell viewWithTag:TAG_DETAIL_TEXT];
        webMainText=(UIWebView*)[cell viewWithTag:TAG_TEXT];
        customText=(UILabel*)[cell viewWithTag:TAG_TEXT];
    }
    
    CDCollectionApp *_app;

    _app=[arrItemsList objectAtIndex:indexPath.row];
    
    customText.text=[NSString stringWithFormat:@"%@   ver %@ ", _app.cdName,_app.cdAppVersion];
    
    if (_app.cdInstalStatus==AppStatusInstall) {
        customDetailText.text=@"Install";
    }else if (_app.cdInstalStatus==AppStatusNotInstall) {
        customDetailText.text=@"Not Install";
    }else if (_app.cdInstalStatus==AppStatusNoURL) {
        customDetailText.text=@"";
    }
    
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue2, ^{
        UIImage *image=[collectionAppWrapper appImage:_app];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [customImage setImage:image];
        });
        
    });
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrItemsList count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
@end
