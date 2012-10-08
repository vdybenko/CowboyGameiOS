//
//  CustomNSURLConnection.m
//  Cowboy Duel 1
//
//  Created by Taras on 12.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomNSURLConnection.h"

@implementation CustomNSURLConnection
@synthesize requestURL;
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    self = [super initWithRequest:request delegate:delegate];
            if (self) {
                self.requestURL = [[NSURL alloc] init];
                self.requestURL = request.URL;
            }
            return self;
            }
@end
