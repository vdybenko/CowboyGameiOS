//
//  UIImage+Save.m
//  Bounty Hunter 1
//
//  Created by Taras on 18.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Save.h"
#import "Utils.h"

@implementation UIImage (usefull_stuff)

+(NSString*) saveImage:(NSString*) pName URL:(NSString*)pURL{
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [UIImage saveImage:pName URL:pURL directory:docDir];
}

+(NSString*) saveImage:(NSString*) pName URL:(NSString*)pURL directory:(NSString*)dir{
    NSString *nameFile=[NSString stringWithFormat:@"%@.png",pName];
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",dir,nameFile];
    if (![Utils isFileDownloadedForPath:pngFilePath]) {
        if (pURL && ![pURL isEqualToString:@""]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:pURL]];
                UIImage *image = [UIImage imageWithData:imageData];
                NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
                [data1 writeToFile:pngFilePath atomically:YES];
            });
            return nameFile;
        }else{
            return @"";
        }
    }else{
        return nameFile;
    }
}

+(UIImage *) loadImageFromDocumentDirectory:(NSString *) pPath{
    if (pPath) {
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [docDir stringByAppendingPathComponent:pPath];
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:pngData];
        return image;
    }else {
        return nil;
    }
}

+(UIImage *) loadImageFullPath:(NSString *) pPath{
    if (pPath) {
        NSData *pngData = [NSData dataWithContentsOfFile:pPath];
        UIImage *image = [UIImage imageWithData:pngData];
        return image;
    }else {
        return nil;
    }
}

+(void)deleteImageWithPath:(NSString*)path;
{
    if(path && [path length]){
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        
        NSError *error= nil;
        if ([fileMgr removeItemAtPath:path error:&error] != YES)
            DLog(@"Unable to delete file: %@", [error localizedDescription]);
    }
}

@end
