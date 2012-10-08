//
//  AdvertisingOtherAppViewController.m
//  Cowboy Duel 1
//
//  Created by Taras on 05.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdvertisingOtherAppViewController.h"

@interface AdvertisingOtherAppViewController ()

@end

@implementation AdvertisingOtherAppViewController

- (id)init
{
    self = [super init];
    if (self) {
        
//   Objects for Test     
        
//        NSMutableArray *arr=[[NSMutableArray alloc] init];
//        
//        CDCollectionAdvertisingApp *app1=[[CDCollectionAdvertisingApp alloc] init];
//        
//        app1.cdIcon=@"50px-Tango_style_Wikipedia_Icon.svg.png";
//        app1.cdAppStoreURL=@"";
//        app1.cdDescription=@"Desc2";
//        app1.cdName=@"App1_launchme1";
//        app1.cdURL=@"launchme";
//        app1.cdAppVersion=@"1.5";
//        app1.cdNumberOfShows=1;
//        
//        [_collectionAppWrapper checkForInstal:app1];
//        [arr addObject:app1];
//        
//        CDCollectionAdvertisingApp *app2=[[CDCollectionAdvertisingApp alloc] init];
//        
//        app2.cdIcon=@"50px-Tango_style_Wikipedia_Icon.svg.png";
//        app2.cdAppStoreURL=@"";
//        app2.cdDescription=@"Desc2";
//        app2.cdName=@"App1_launchme2";
//        app2.cdURL=@"launchme";
//        app2.cdAppVersion=@"1.5";
//        app2.cdNumberOfShows=2;
//        
//        [_collectionAppWrapper checkForInstal:app2];
//        [arr addObject:app2];
//        
//        CDCollectionAdvertisingApp *app3=[[CDCollectionAdvertisingApp alloc] init];
//        
//        app3.cdIcon=@"50px-Tango_style_Wikipedia_Icon.svg.png";
//        app3.cdAppStoreURL=@"";
//        app3.cdDescription=@"Desc2";
//        app3.cdName=@"App1_launchme3";
//        app3.cdURL=@"launchme";
//        app3.cdAppVersion=@"1.5";
//        app3.cdNumberOfShows=2;
//        
//        [_collectionAppWrapper checkForInstal:app3];
//        [arr addObject:app3];
//        
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arr];
//        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"AdvertisingAppsForShow"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
//        end Objects for Test
        
        NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"AdvertisingAppsForShow"];
        _AppsForShow=[[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data1]];
        
        NSLog(@"_AppsForShow %@",_AppsForShow);
        
        CollectionAppWrapper *collectionAppWrapper=[[CollectionAppWrapper alloc]init];

        
        for (CDCollectionAdvertisingApp *app in _AppsForShow) {
            [collectionAppWrapper checkForInstal:app];
            if (app.cdInstalStatus==AppStatusInstall) {
                app.cdNumberOfShows=0;
                [CollectionAppWrapper removeContentAdvertisingApps:app];

            }
        }
        
        [self choseAppFromShow];        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [super setInformationAboutApp];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark interface metods

-(BOOL)isAdvertisingNeed;
{
    if (advertisingNeed) {
        return YES;
    }else {
        return NO;
    }
}

-(BOOL)isNumberOfShowsLeft
{
    if (_AppCurentForShow.cdNumberOfShows==0) {
        return NO;
    }else {
        int numberOfShows=_AppCurentForShow.cdNumberOfShows;
        numberOfShows--;
        _AppCurentForShow.cdNumberOfShows=numberOfShows;
    }
}

-(void)choseAppFromShow{
    int numberofElementsInApps=[_AppsForShow count];
    int numberOfShowsInAllApps = [self countShowsInAllApps];
    if ((numberOfShowsInAllApps!=0)&&(numberofElementsInApps!=0)) {
        
        int orderOfShow=[[NSUserDefaults standardUserDefaults] integerForKey:@"ORDER_OF_SHOW"];
        if (!orderOfShow) {
            orderOfShow=numberofElementsInApps;
        }else {
            if (orderOfShow>=numberofElementsInApps) {
                orderOfShow=1;
            }else {
                orderOfShow++;
            }
        }
                
        [[NSUserDefaults standardUserDefaults] setInteger:orderOfShow forKey:@"ORDER_OF_SHOW"];
        _AppCurentForShow=[_AppsForShow objectAtIndex:(orderOfShow-1)];
        
        if (_AppCurentForShow) {
            if ([self isNumberOfShowsLeft]) {
                advertisingNeed=YES;
            }else {
                advertisingNeed=NO;
                [CollectionAppWrapper removeContentAdvertisingApps:_AppCurentForShow];
                [self choseAppFromShow];
            }
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_AppsForShow];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"AdvertisingAppsForShow"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else {
            advertisingNeed=NO;
        }
    }else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ORDER_OF_SHOW"];
        advertisingNeed=NO;
    }

}

-(int)countShowsInAllApps
{
    int s=0;
    for (CDCollectionAdvertisingApp *app in _AppsForShow) {
        
        s+=app.cdNumberOfShows;
    }
    return s;
}
@end
