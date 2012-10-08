//
//  ViewProjectHelper.h
//  Cowboy Duel 1
//
//  Created by Taras on 31.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate-Utilities.h"

@interface ViewProjectHelper : NSObject

+ (NSString *)fuzzyTime:(NSDate *)date;
+(UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor;

@end
