//
//  CustomNSURLConnection.m
//  Cowboy Duel 1
//
//  Created by Taras on 12.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomNSURLConnection.h"

static CustomNSURLConnection *connection;

@implementation CustomNSURLConnection
@synthesize requestURL, requestHTTP;

+(id)sharedInstance
{
    if (!connection) {
        connection = [[CustomNSURLConnection alloc] init];
    }
    return connection;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    self = [super initWithRequest:request delegate:delegate];
    if (self) {
        self.requestURL = [[NSURL alloc] init];
        self.requestURL = request.URL;
        NSData *receivedData=request.HTTPBody;
        self.requestHTTP = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    }
    return self;
}
@end
