//
//  ListOfCategoriesViewController.m
//  platfor
//
//  Created by Taras on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CollectionAppViewController.h"

@implementation CollectionAppViewController

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
    // Do any additional setup after loading the view from its nib.
    
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - table delegated methods
//table view

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
