//
//  AdvertisingAppearController.m
//  Cowboy Duel 1
//
//  Created by Taras on 14.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdvertisingAppearController.h"
#import "Utils.h"

@implementation AdvertisingAppearController
+(void)advertisingCountIncrease;
{
    BOOL advertisingWillShow=[[NSUserDefaults standardUserDefaults] boolForKey:@"advertisingWillShow"];
    if(!advertisingWillShow){
        
        int countOfDuels=[[NSUserDefaults standardUserDefaults] integerForKey:@"countOfDuels"];
        int movieWatched=[[NSUserDefaults standardUserDefaults] integerForKey:@"movieWatched"];
        int kFrequencyOfAdvertising=[[NSUserDefaults standardUserDefaults] integerForKey:@"kFrequencyOfAdvertising"];
        
        if (kFrequencyOfAdvertising==0) {
            kFrequencyOfAdvertising = kFrequencyOfAdvertisingDefault;
            [[NSUserDefaults standardUserDefaults] setInteger:kFrequencyOfAdvertising forKey:@"kFrequencyOfAdvertising"];
        }
        
        countOfDuels++;
        if (countOfDuels==1){
            countOfDuels=kFrequencyOfAdvertising;
        }
        if ( countOfDuels%kFrequencyOfAdvertising == 0){
            if ((movieWatched < kNumberOfAdvertisingPerDay)) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"advertisingWillShow"];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setInteger:countOfDuels forKey:@"countOfDuels"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
+(BOOL)advertisingCheckForAppearWithFirstDayWithOutAdvertising:(BOOL)firstDayWithOutAdvertising;
{
    NSUserDefaults *userDefDuelsCount = [NSUserDefaults standardUserDefaults];
        
    int countOfDuels=[userDefDuelsCount integerForKey:@"countOfDuels"];
    int movieWatched=[userDefDuelsCount integerForKey:@"movieWatched"];
    BOOL advertisingWillShow=[[NSUserDefaults standardUserDefaults] boolForKey:@"advertisingWillShow"];
    
    if ([Utils isNextDayBegin]) {
        firstDayWithOutAdvertising=NO;
        countOfDuels=0;
        movieWatched=0;
        advertisingWillShow=NO;
        [[NSUserDefaults standardUserDefaults] setInteger:movieWatched forKey:@"movieWatched"];
        [[NSUserDefaults standardUserDefaults] setInteger:countOfDuels forKey:@"countOfDuels"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"advertisingWillShow"];
    }
    return firstDayWithOutAdvertising;
}
@end
