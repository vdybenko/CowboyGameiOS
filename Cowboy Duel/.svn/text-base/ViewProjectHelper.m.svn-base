//
//  ViewProjectHelper.m
//  Cowboy Duel 1
//
//  Created by Taras on 31.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewProjectHelper.h"


@implementation ViewProjectHelper

+ (NSString *)fuzzyTime:(NSDate *)date {
    NSString *formatted;
//    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
////    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
////    [formatter setTimeZone:gmt];
//    NSDate *date = [formatter dateFromString:datetime];
    NSDate *today = [NSDate date];
    NSInteger minutes = [today minutesAfterDate:date];
    NSInteger hours = [today hoursAfterDate:date];
    NSInteger days = [today daysAfterDate:date];
    NSString *period;
    NSString *ago=NSLocalizedString(@"ago", @"");
    if(days >= 365){
    
        float years = round(days / 365) / 2.0f;
        period = (years > 1) ? NSLocalizedString(@"years", @"") : NSLocalizedString(@"year", @"");
        formatted = [NSString stringWithFormat:@" %i %@ %@", years, period,ago];
    } else if(days < 365 && days >= 30) {
        float months = round(days / 30) / 2.0f;
        period = (months > 1) ? (months == 2 || months == 3 || months == 4 ) ? NSLocalizedString(@"months234", @"") : NSLocalizedString(@"months", @"") : NSLocalizedString(@"month", @"");
        formatted = [NSString stringWithFormat:@"%f %@ %@", months, period,ago];
    } else if(days < 30 && days >= 2) {
        period =(days == 2 || days == 3 || days == 4 ) ? NSLocalizedString(@"days234", @"") : NSLocalizedString(@"days", @"");
        formatted = [NSString stringWithFormat:@"%i %@ %@", days, period,ago];
    } else if(days == 1){
        period = NSLocalizedString(@"day", @"");
        formatted = [NSString stringWithFormat:@"%i %@ %@", days, period,ago];
    } else if(days < 1 && minutes > 60) {
        period = (hours > 1) ? ((hours % 10) == 2 || (hours % 10) == 3 || (hours % 10) == 4 ) ? NSLocalizedString(@"hours234", @"") : NSLocalizedString(@"hours", @"") : NSLocalizedString(@"hour", @"");
        formatted = [NSString stringWithFormat:@"%i %@ %@", hours, period,ago];
    } else {
        period = (minutes < 60 && minutes > 1) ? (minutes == 2 || minutes == 3 || minutes == 4 ) ? NSLocalizedString(@"minutes234", @"") :NSLocalizedString(@"minutes", @"") : NSLocalizedString(@"minute", @"");
        formatted = [NSString stringWithFormat:@"%i %@ %@", minutes, period,ago];
        if(minutes < 1){
            formatted = NSLocalizedString(@"moment", @"");
        }
    }
    return formatted;
}

+(UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor {
    UIGraphicsBeginImageContext(baseImage.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, baseImage.CGImage);
    [theColor set];
    CGContextFillRect(ctx, area);
    CGContextRestoreGState(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, area, baseImage.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
