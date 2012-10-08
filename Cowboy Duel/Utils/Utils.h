//
//  Utils.h
//  ReceiptBank
//
//  Created by Max Odnovolyk on 11/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface Utils : NSObject {

}

+ (NSString *)applicationDocumentsDirectory;

+ (NSData *)md5digest:(NSString *)str;
+ (NSString *)md5:(NSString *)str;

+ (NSString *)encodeBase64WithString:(NSString *)strData;
+ (NSString *)encodeBase64WithData:(NSData *)objData;
+ (NSData *)decodeBase64WithString:(NSString *)strBase64;

+(NSString*)makeStringForPostRequest:(NSDictionary*)pDic;

+(BOOL)isNextDayBegin;
+(BOOL)isNextHourBegin;

+(BOOL)isiPhoneRetina;

+(BOOL)isDeviceMuted;
@end
