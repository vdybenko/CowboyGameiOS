//
//  Utils.h
//  ReceiptBank
//
//  Created by Max Odnovolyk on 11/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE_SIMULATOR ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone Simulator" ] )
#define IS_IPOD_SIMULATOR   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPad Simulator" ] )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] || IS_IPHONE_SIMULATOR)
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] || IS_IPOD_SIMULATOR)
#define IS_IPHONE_5 ( (IS_IPHONE || IS_IPOD) && IS_WIDESCREEN )
@interface Utils : NSObject {

}
+ (NSString *)applicationDocumentsDirectory;

+ (NSData *)md5digest:(NSString *)str;
+ (NSString *)md5:(NSString *)str;

+(NSString*)makeStringForPostRequest:(NSDictionary*)pDic;

+(BOOL)isNextDayBegin;
+(BOOL)isNextHourBegin;

+(BOOL)isiPhoneRetina;

+(BOOL)isDeviceMuted;

+(NSString *)deviceType;

+(BOOL)isFileDownloadedForPath:(NSString*)path;

+(UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;

@end
