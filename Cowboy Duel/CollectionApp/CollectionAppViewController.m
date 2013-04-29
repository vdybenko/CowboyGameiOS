//
//  ListOfCategoriesViewController.m
//  platfor
//
//  Created by Taras on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "CollectionAppViewController.h"

@interface CollectionAppViewController (){
    IBOutlet UITableView * tableView;
    IBOutlet UIButton *btnBack;
    IBOutlet UILabel *lbBackBtn;
    ItemsDataSource *itemsDataSource;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@end

@implementation CollectionAppViewController
@synthesize btnBack;
@synthesize tableView;

-(id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {              
        }
    return self;
}

-(void)reloadController;
{
    [itemsDataSource reloadDataSource];
    [tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tableView.delegate=self;
    itemsDataSource=[[ItemsDataSource alloc] init];
    tableView.dataSource=itemsDataSource;
    
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    lbBackBtn.text = NSLocalizedString(@"BACK", nil);
    lbBackBtn.textColor = btnColor;
    lbBackBtn.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
}

- (void)viewDidUnload
{
    lbBackBtn = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CDCollectionApp *_app=[itemsDataSource.arrItemsList objectAtIndex:indexPath.row];
    return;
    if (_app.cdInstalStatus!=AppStatusInstall) {
        [itemsDataSource.collectionAppWrapper runApp:_app];
    }else if (_app.cdInstalStatus==AppStatusNotInstall) {
        [CollectionAppWrapper runAppStore:_app.cdAppStoreURL];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

#pragma mark - Interface methods

-(IBAction)backToMenu:(id)sender;
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {

}
@end
