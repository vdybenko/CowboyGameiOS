//
//  CDCollectionApp.h
//  Bounty Hunter 1
//
//  Created by Taras on 26.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDCollectionApp : NSObject<NSCoding>
{
    NSString * cdName;
    NSString * cdDescription;
    NSString * cdIcon;
    NSString * cdURL;
    NSString * cdAppStoreURL;
    NSString * cdAppVersion;
    NSInteger cdInstalStatus;
}

@property(nonatomic, strong) NSString *cdName;
@property(nonatomic, strong) NSString *cdDescription;
@property(nonatomic, strong) NSString *cdIcon;
@property(nonatomic, strong) NSString *cdURL;
@property(nonatomic, strong) NSString *cdAppStoreURL;
@property(nonatomic, strong) NSString *cdAppVersion;
@property(nonatomic) NSInteger cdInstalStatus;


@end
