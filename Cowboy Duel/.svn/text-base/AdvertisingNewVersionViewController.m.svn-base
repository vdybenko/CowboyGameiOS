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
    self = [super init];
    if (self) {
        // Custom initialization
//        CDCollectionAdvertisingApp *app1=[[CDCollectionAdvertisingApp alloc] init];
//        
//        app1.cdIcon=@"50px-Tango_style_Wikipedia_Icon.svg.png";
//        app1.cdAppStoreURL=@"";
//        app1.cdDescription=@"Desc1";
//        app1.cdName=@"App1_launchme";
//        app1.cdURL=@"launchme";
//        app1.cdAppVersion=@"1.5";
//        app1.cdNumberOfShows=3;
//        
//        [_collectionAppWrapper checkForInstal:app1];
        
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:app1];
//        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"AdvertisingNewVersion"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
                        
        NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"AdvertisingNewVersion"];
        NSMutableArray *arr=[[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data1]];
        if ([arr count]!=0) {
            _AppCurentForShow=[[CDCollectionAdvertisingApp alloc] init];
            _AppCurentForShow=[arr objectAtIndex:0];
            NSString *curentVersionApp = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

            if ([_AppCurentForShow.cdAppVersion isEqualToString:curentVersionApp]) {
                advertisingNeed=NO;
                [self removeContent];
            }else {
                advertisingNeed=YES;
            }
        }else {
            advertisingNeed=NO;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];  
    
    [_btnAppStore setTitleByLabel:NSLocalizedString(@"NewVersionBtn", @"")];
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    [_btnAppStore changeColorOfTitleByLabel:btnColor];
    
    titleView.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
    [webBody setOpaque:NO];
    [webBody.scrollView setScrollEnabled:NO];
    [webBody setBackgroundColor:[UIColor clearColor]];
    [webBody loadHTMLString:NSLocalizedString(@"NewVersionMainText", @"") baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]; 

    
    [super setInformationAboutApp];
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

-(BOOL)isAdvertisingNeed;
{
    if (advertisingNeed) {
        return YES;
    }else {
        return NO;
    }
}

-(void)removeContent
{
    [CollectionAppWrapper deleteImage:_AppCurentForShow.cdIcon];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AdvertisingNewVersion"];
}

-(BOOL)isNumberOfShowsLeft
{
    if (_AppCurentForShow.cdNumberOfShows==0) {
        return NO;
    }else {
        int numberOfShows=_AppCurentForShow.cdNumberOfShows;
        numberOfShows--;
        _AppCurentForShow.cdNumberOfShows=numberOfShows;
        
        NSMutableArray *arr=[[NSMutableArray alloc] init];
        [arr addObject:_AppCurentForShow];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arr];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"AdvertisingNewVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
