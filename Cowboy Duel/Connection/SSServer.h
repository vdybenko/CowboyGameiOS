//
//  SSServer.h
//  TCPClient
//
//  Created by Sergey Sobol on 16.10.12.
//  Copyright (c) 2012 Sergey Sobol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSServer : NSObject

@property (nonatomic, strong) NSString *displayName;//displayName - string (Device Name)
@property (nonatomic, strong) NSString *serverName; //serverName - string (uid)
@property (nonatomic, strong) NSString *status;  //status - char
@property (nonatomic, strong) NSString *fbImageUrl; //fbImageUrl - string
@property (nonatomic, strong) NSNumber *money; //money - int
@property (nonatomic, strong) NSNumber *rank;  //rank - int
@property (nonatomic) BOOL bot;
@property (nonatomic, strong) NSNumber *duelsWin;
@property (nonatomic, strong) NSNumber *duelsLost;
@end
