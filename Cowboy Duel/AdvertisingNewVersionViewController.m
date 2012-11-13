//
//  AdvertisingNewVersionViewController.m
//  Cowboy Duel 1
//
//  Created by Taras on 05.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdvertisingNewVersionViewController.h"

@implementation AdvertisingNewVersionViewController
- (id)init
{
    self = [super initWithNib];
    if (self) {
        NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"AdvertisingNewVersion"];
        NSMutableArray *arr=[[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data1]];
        if ([arr count]!=0) {
            appCurentForShow
            
            =[[CDCollectionAdvertisingApp alloc] init];
            appCurentForShow=[arr objectAtIndex:0];
            NSString *curentVersionApp = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

            if ([appCurentForShow.cdAppVersion isEqualToString:curentVersionApp]) {
                self.advertisingNeed=NO;
                [self removeContent];
            }else {
                self.advertisingNeed=YES;
            }
        }else {
            self.advertisingNeed=NO;
        }
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.btnAppStore setTitleByLabel:NSLocalizedString(@"NewVersionBtn", @"")];
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    [self.btnAppStore changeColorOfTitleByLabel:btnColor];
    
    self.titleView.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
    [self.webBody setOpaque:NO];
    [self.webBody.scrollView setScrollEnabled:NO];
    [self.webBody setBackgroundColor:[UIColor clearColor]];
    [self.webBody loadHTMLString:NSLocalizedString(@"NewVersionMainText", @"") baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];

    
    
    
    //[super setInformationAboutApp];

}

-(void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];  
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark interface metods

-(IBAction)btnSkipClick:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)btnAppStoreClick:(id)sender;
{
    [super btnAppStoreClick:sender];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/new_Version_app" forKey:@"event"]];
}

-(void)removeContent
{
    [CollectionAppWrapper deleteImage:appCurentForShow.cdIcon];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AdvertisingNewVersion"];
}

-(BOOL)isNumberOfShowsLeft
{
    if (appCurentForShow.cdNumberOfShows==0) {
        return NO;
    }else {
        int numberOfShows=appCurentForShow.cdNumberOfShows;
        numberOfShows--;
        appCurentForShow.cdNumberOfShows=numberOfShows;
        
        NSMutableArray *arr=[[NSMutableArray alloc] init];
        [arr addObject:appCurentForShow];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arr];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"AdvertisingNewVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
