//
//  OponentCoordinateView.m
//  Bounty Hunter
//
//  Created by Sergey Sobol on 18.01.13.
//
//

#import "OponentCoordinateView.h"

@implementation OponentCoordinateView
@synthesize view;
@synthesize location;

- (id)init
{
    self = [super init];
    if (self) {
        view = nil;
        location = nil;
    }
    return self;
}

+ (OponentCoordinateView *)oponentCoordinateWithView:(UIView *)view at:(CLLocation *)location
{
	OponentCoordinateView *poi = [[OponentCoordinateView alloc] init];
	poi.view = view;
	poi.location = location;
	return poi;
}

@end
