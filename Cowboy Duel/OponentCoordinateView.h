//
//  OponentCoordinateView.h
//  Bounty Hunter
//
//  Created by Sergey Sobol on 18.01.13.
//
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface OponentCoordinateView : NSObject
@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) CLLocation *location;

+ (OponentCoordinateView *)oponentCoordinateWithView:(UIView *)view at:(CLLocation *)location;

@end
