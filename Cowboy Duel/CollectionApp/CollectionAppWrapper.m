//
//  CollectionAppWrapper.m
//  Cowboy Duel 1
//
//  Created by Taras on 26.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CollectionAppWrapper.h"
#import "UIImage+Save.h"

@implementation CollectionAppWrapper

-(void)runApp:(CDCollectionApp *)pAPP;
{
    if (pAPP.cdInstalStatus!=AppStatusNoURL) {
        NSURL *_URL=[NSURL URLWithString:[NSString stringWithFormat:@"%@://",pAPP.cdURL]];
        [[UIApplication sharedApplication] openURL:_URL];
    }
}

-(void)checkAllAppForInstall:(CDCollectionApp *)pAPP;
{
    if ([pAPP.cdURL isEqualToString:@""]) {
        pAPP.cdInstalStatus=AppStatusNoURL;
    }else {
        NSURL *_URL=[NSURL URLWithString:[NSString stringWithFormat:@"%@://",pAPP.cdURL]];
        if ([[UIApplication sharedApplication] canOpenURL:_URL]) {
            pAPP.cdInstalStatus=AppStatusInstall;
        }else {
            pAPP.cdInstalStatus=AppStatusNotInstall;
        }
    }
}

+(void)runAppStore:(NSString *)path;
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
}

-(void) saveImgWithURL:(CDCollectionApp *)pAPP;
{    
    [UIImage saveImage:pAPP.cdURL URL:pAPP.cdIcon];            
}

-(UIImage*) appImage:(CDCollectionApp *)pAPP;
{
    return [UIImage loadImageFromDocumentDirectory:pAPP.cdIcon];
}

+(void)deleteImage:(NSString *) imageName;
{
    if(imageName){
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *FilePath = [NSString stringWithFormat:@"%@/%@",docDir,imageName];
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        
        NSError *error= nil;
        if ([fileMgr removeItemAtPath:FilePath error:&error] != YES)
            DLog(@"CollectionAppWrapper: Unable to delete file: %@", [error localizedDescription]);
    }
}

+(void)removeContentAdvertisingApps:(CDCollectionAdvertisingApp *)app;
{
    [self deleteImage:app.cdIcon];
}

@end
