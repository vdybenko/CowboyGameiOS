//
//  UIImage+Save.h
//  Bounty Hunter 1
//
//  Created by Taras on 18.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (usefull_stuff)
    +(NSString*) saveImage:(NSString*) pName URL:(NSString*)pURL;
    +(NSString*) saveImage:(NSString*) pName URL:(NSString*)pURL directory:(NSString*)dir;
    +(UIImage *) loadImageFromDocumentDirectory:(NSString *) pPath;
    +(UIImage *) loadImageFullPath:(NSString *) pPath;
    +(void)deleteImageWithPath:(NSString*)path;
@end
