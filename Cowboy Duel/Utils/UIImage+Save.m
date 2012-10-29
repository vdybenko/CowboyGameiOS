//
//  UIImage+Save.m
//  Cowboy Duel 1
//
//  Created by Taras on 18.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Save.h"

@implementation UIImage (usefull_stuff)

+(NSString*) saveImage:(NSString*) pName URL:(NSString*)pURL{
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [UIImage saveImage:pName URL:pURL directory:docDir];
}

+(NSString*) saveImage:(NSString*) pName URL:(NSString*)pURL directory:(NSString*)dir{
    if (pURL && ![pURL isEqualToString:@""]) {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:pURL]];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        
        NSString *nameFile=[NSString stringWithFormat:@"%@.png",pName];
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",dir,nameFile];
        NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
        [data1 writeToFile:pngFilePath atomically:YES];
        return nameFile;
    }else{
        return @"";
    }
}

+(BOOL)isFileDownloadedForPath:(NSString*)path{
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        return YES;
    }else{
        return NO;
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
