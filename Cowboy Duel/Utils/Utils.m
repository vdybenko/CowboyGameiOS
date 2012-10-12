//
//  Utils.m
//  ReceiptBank
//
//  Created by Max Odnovolyk on 11/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>


@implementation Utils

#pragma mark -
#pragma mark App docs dir

+ (NSString *)applicationDocumentsDirectory {
	
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark MD5

+ (NSData *)md5digest:(NSString *)str {
	
	const char *src = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(src, strlen(src), result);
	
	NSData *dataObj = [NSData dataWithBytes:&result length:CC_MD5_DIGEST_LENGTH];
	
	return dataObj;
}


+ (NSString *) md5:(NSString *)str {
	
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	
	CC_MD5(cStr, strlen(cStr), result);
	
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]]; 
}

+(NSString*)makeStringForPostRequest:(NSDictionary*)pDic;
{
    NSMutableString *st=[[NSMutableString alloc] init];
    NSArray *allKeys=[pDic allKeys];
    for (NSString *key in allKeys) {
        NSString *stForParametr=[NSString stringWithFormat:@"%@=%@&",key,[pDic objectForKey:key]];
        [st appendString:stForParametr];
    }
    return [st substringToIndex:[st length]-1];
}
+(BOOL)isNextDayBegin;
{
    int savedDate=[[NSUserDefaults standardUserDefaults] integerForKey:@"checkNextDays"];
    if (savedDate==0) {
        NSDate *startDate=[Utils midnightUTC ];
            
        [[NSUserDefaults standardUserDefaults] setInteger:[startDate timeIntervalSince1970] forKey:@"checkNextDays"];
        
        return NO;
    }else {
        
        NSDate *startDate=[[NSDate alloc] initWithTimeIntervalSince1970:savedDate];
        
        NSDateComponents* oneDay = [[NSDateComponents alloc] init];
        [oneDay setDay: 1];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDate* endOfDate = [calendar dateByAddingComponents: oneDay toDate: startDate options: 0];
        
        NSDate *curentDate=[NSDate date];
        
        NSComparisonResult endCompare = [endOfDate compare: curentDate];
        
        if (endCompare == NSOrderedAscending)
        {
            NSDate *startDate=[Utils midnightUTC ];
            
            [[NSUserDefaults standardUserDefaults] setInteger:[startDate timeIntervalSince1970] forKey:@"checkNextDays"];
            
           return YES;
        } else {
            return NO;
        }
    }
}

+(BOOL)isNextHourBegin;
{
    int savedDate=[[NSUserDefaults standardUserDefaults] integerForKey:@"checkNextHour"];
    if (savedDate==0) {
        NSDate *startDate=[NSDate date];
        
        [[NSUserDefaults standardUserDefaults] setInteger:[startDate timeIntervalSince1970] forKey:@"checkNextHour"];
        
        return YES;
    }else {
        
        NSDate *startDate=[[NSDate alloc] initWithTimeIntervalSince1970:savedDate];
        
        NSDateComponents* oneDay = [[NSDateComponents alloc] init];
        [oneDay setHour:1];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDate* endOfDate = [calendar dateByAddingComponents: oneDay toDate: startDate options: 0];
        
        NSDate *curentDate=[NSDate date];
        
        NSComparisonResult endCompare = [endOfDate compare: curentDate];
        
        if (endCompare == NSOrderedAscending)
        {
            NSDate *startDate=[NSDate date];
            
            [[NSUserDefaults standardUserDefaults] setInteger:[startDate timeIntervalSince1970] forKey:@"checkNextHour"];
            
            return YES;
        } else {
            return NO;
        }
    }
}


+(NSDate *)midnightUTC {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                   fromDate:[NSDate date]];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    NSDate *midnightUTC = [calendar dateFromComponents:dateComponents];
    [calendar release];
    
    return midnightUTC;
}

+(BOOL)isiPhoneRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))?1:0;
}

+(BOOL)isDeviceMuted
{    
    CFStringRef state;
    UInt32 propertySize = sizeof(CFStringRef);
    OSStatus audioStatus = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state);
    if (audioStatus == kAudioSessionNoError) {
        return (CFStringGetLength(state) <= 0);
    }
    return NO;
}

#pragma mark device type

+ (NSString *)deviceTypeCode {
    size_t size;
    
    // Set 'oldp' parameter to NULL to get the size of the data
    // returned so we can allocate appropriate amount of space
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    // Allocate the space to store name
    char *name = malloc(size);
    
    // Get the platform name
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    // Place name into a string
    NSString *deviceTypeCode = [NSString stringWithCString:name encoding: NSUTF8StringEncoding];
    
    
    // Done with this
    free(name);
    
    return deviceTypeCode;
}

+ (NSString *)deviceType {
    
    NSString *deviceTypeCode=[Utils deviceTypeCode];
    if ([deviceTypeCode isEqualToString: @"i386"]) {
        return @"iPhone Simulator";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone1,1"]) {
        return @"iPhone";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone1,2"]) {
        return @"iPhone3G";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone2,1"]) {
        return @"iPhone3GS";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone3,1"]) {
        return @"iPhone4";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone3,3"]||
             [deviceTypeCode isEqualToString: @"iPhone3,2"]) {
        return @"iPhone4CDMA";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone4,1"]) {
        return @"iPhone4S";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone5,1"]) {
        return @"iPhone5GSM";
    }
    else if ([deviceTypeCode isEqualToString: @"iPhone5,2"]) {
        return @"iPhone5CDMA";
    }
    else if ([deviceTypeCode isEqualToString: @"iPod1,1"]) {
        return @"iPod1";
    }
    else if ([deviceTypeCode isEqualToString: @"iPod2,1"]) {
        return @"iPod2";
    }
    else if ([deviceTypeCode isEqualToString: @"iPod2,2"]) {
        return @"iPod2.5";
    }
    else if ([deviceTypeCode isEqualToString: @"iPod3,1"]) {
        return @"iPod3";
    }
    else if ([deviceTypeCode isEqualToString: @"iPod4,1"]) {
        return @"iPod4";
    }
    else if ([deviceTypeCode isEqualToString: @"iPod5,1"]) {
        return @"iPod5";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad1,1"]) {
        return @"iPad1";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad1,2"]) {
        return @"iPad1GSM";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad2,1"]) {
        return @"iPad2";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad2,2"]) {
        return @"iPad2GSM";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad2,3"]) {
        return @"iPad2CDMA";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad3,1"]) {
        return @"iPad3WiFi";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad3,2"]) {
        return @"iPad3GSM";
    }
    else if ([deviceTypeCode isEqualToString: @"iPad3,3"]) {
        return @"iPad3CDMA";
    }
    else {
        return deviceTypeCode;
    }
}
@end
