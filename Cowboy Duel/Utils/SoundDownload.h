//
//  SoundDownload.h
//  Cowboy Duels
//
//  Created by Taras on 29.10.12.
//
//

#import <Foundation/Foundation.h>

@interface SoundDownload : NSObject
+(NSString*) saveSound:(NSString*) pName URL:(NSString*)pURL directory:(NSString*)dir;
+(NSData *) dataForSound:(NSString *) pPath;
@end
