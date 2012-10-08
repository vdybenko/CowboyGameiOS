//
//  NetworkActivityIndicatorManager.m
//  iFish
//
//  Created by Max Odnovolyk on 10/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetworkActivityIndicatorManager.h"


@implementation NetworkActivityIndicatorManager

static NetworkActivityIndicatorManager *manager = nil;

+ (NetworkActivityIndicatorManager *)sharedInstance {
	
	@synchronized (self) {
		if (!manager)
			[[self alloc] init];
	}
	
	return manager;
}


- (id)init {
	
	self = [super init];
	
	manager = self;
	counter = 0;
	
	return self;
}




- (void)show {
	
	counter++;
	
	if (counter > 0)
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


- (void)hide {

	counter--;
	
	if (counter <= 0)
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
