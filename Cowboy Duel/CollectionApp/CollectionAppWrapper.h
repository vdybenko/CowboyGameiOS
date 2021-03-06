//
//  CollectionAppWrapper.h
//  Cowboy Duel 1
//
//  Created by Taras on 26.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDCollectionApp.h"
#import "CDCollectionAdvertisingApp.h"

typedef enum {
    AppStatusInstall,
    AppStatusNotInstall,
    AppStatusNoURL
} AppStatus;

@interface CollectionAppWrapper : NSObject
        
-(void)checkForInstal:(CDCollectionApp *)pAPP;
-(void) setImgWithURL:(CDCollectionApp *)pAPP;
-(UIImage*) getPictureImg:(CDCollectionApp *)pAPP;
+(void)runAppStore:(NSString *)path;
-(void)runApp:(CDCollectionApp *)pAPP;
+(void)deleteImage:(NSString *) imageName;
+(void)removeContentAdvertisingApps:(CDCollectionAdvertisingApp *)app;
@end
