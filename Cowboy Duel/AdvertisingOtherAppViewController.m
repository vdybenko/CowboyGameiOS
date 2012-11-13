//
//  AdvertisingOtherAppViewController.m
//  Cowboy Duel 1
//
//  Created by Taras on 05.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdvertisingOtherAppViewController.h"

@interface AdvertisingOtherAppViewController ()
{
    NSMutableArray *_AppsForShow;
}
@end

@implementation AdvertisingOtherAppViewController

- (id)init
{
    self = [super init];
    if (self) {
        NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"AdvertisingAppsForShow"];
        _AppsForShow=[[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data1]];
        
        DLog(@"_AppsForShow %@",_AppsForShow);
        
        CollectionAppWrapper *collectionAppWrapper=[[CollectionAppWrapper alloc] init];
        for (CDCollectionAdvertisingApp *app in _AppsForShow) {
            [collectionAppWrapper checkAllAppForInstall:app];
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

-(BOOL)isAdvertisingNeed;
{
    if (self.advertisingNeed) {
        return YES;
    }else {
        return NO;
    }
}

-(BOOL)isNumberOfShowsLeft
{
    if (appCurentForShow.cdNumberOfShows==0) {
        return NO;
    }else {
        int numberOfShows=appCurentForShow.cdNumberOfShows;
        numberOfShows--;
        appCurentForShow.cdNumberOfShows=numberOfShows;
        return YES;
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
        appCurentForShow=[_AppsForShow objectAtIndex:(orderOfShow-1)];
        
        if (appCurentForShow) {
            if ([self isNumberOfShowsLeft]) {
                self.advertisingNeed=YES;
            }else {
                self.advertisingNeed=NO;
                [CollectionAppWrapper removeContentAdvertisingApps:appCurentForShow];
                [self choseAppFromShow];
            }
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_AppsForShow];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"AdvertisingAppsForShow"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else {
            self.advertisingNeed=NO;
        }
    }else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ORDER_OF_SHOW"];
        self.advertisingNeed=NO;
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
