//
//  CDCollectionApp.m
//  Cowboy Duel 1
//
//  Created by Taras on 26.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CDCollectionApp.h"

@implementation CDCollectionApp

@synthesize cdName;
@synthesize cdDescription;
@synthesize cdIcon;
@synthesize cdURL;
@synthesize cdAppStoreURL;
@synthesize cdInstalStatus;
@synthesize cdAppVersion;

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.cdName forKey:@"NAME"];
    [encoder encodeObject:self.cdDescription forKey:@"DESC"];
    [encoder encodeObject:self.cdIcon forKey:@"ICON"];
    [encoder encodeObject:self.cdURL forKey:@"URL"];
    [encoder encodeObject:self.cdAppVersion forKey:@"VERSION"];
    [encoder encodeObject:self.cdAppStoreURL forKey:@"AppStoreURL"];
    [encoder encodeInteger:self.cdInstalStatus forKey:@"INSTALL"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self.cdName = [decoder decodeObjectForKey:@"NAME"];
    self.cdDescription = [decoder decodeObjectForKey:@"DESC"];
    self.cdIcon = [decoder decodeObjectForKey:@"ICON"];
    self.cdURL = [decoder decodeObjectForKey:@"URL"];
    self.cdAppVersion = [decoder decodeObjectForKey:@"VERSION"];
    self.cdAppStoreURL = [decoder decodeObjectForKey:@"AppStoreURL"];
    self.cdInstalStatus = [decoder decodeIntegerForKey:@"INSTALL"];
    return self;
}

@end
