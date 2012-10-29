//
//  SoundDownload.m
//  Cowboy Duels
//
//  Created by Taras on 29.10.12.
//
//

#import "SoundDownload.h"

@implementation SoundDownload
+(NSString*) saveSound:(NSString*) pName URL:(NSString*)pURL directory:(NSString*)dir;
{
    
    if (pURL && [pURL length]) {
        NSString *nameFile=[NSString stringWithFormat:@"%@.mp3",pName];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSData *soundData = [NSData dataWithContentsOfURL:[NSURL URLWithString:pURL]];
            NSString *soundFilePath = [NSString stringWithFormat:@"%@/%@",dir,nameFile];
            [soundData writeToFile:soundFilePath atomically:YES];
        });
        return nameFile;
    }else{
        return @"";
    }
}

+(NSData *) dataForSound:(NSString *) pPath;
{
    return [NSData dataWithContentsOfFile:pPath];
}

@end
