//
//  RefreshContentDataController.m
//  Cowboy Duel 1
//
//  Created by Taras on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RefreshContentDataController.h"
#import "CollectionAppWrapper.h"
#import "NSString+isNumeric.h"
//real URL
NSString  *const URL_CONTENT_FILE_DEFULT   = @"http://bidoncd.s3.amazonaws.com/info.xml"; 
//Test URL
//NSString  *const URL_CONTENT_FILE_DEFULT   = @"http://taras.webkate.com/cowboy_duel_synchro/info.xml"; 

NSString  *const USER_DEFULTS_KEY_NEW_VERSION_APP   = @"AdvertisingNewVersion";
NSString  *const USER_DEFULTS_KEY_OTHER_APP   = @"AdvertisingAppsForShow";
NSString  *const USER_DEFULTS_KEY_COLLECTION_APPS   = @"colectionApp";



@interface RefreshContentDataController (Private)
    -(NSString*)downloadFileURL:(NSString *)pUrl;
    -(void)compareDBvsServerFiles;  
@end


@implementation RefreshContentDataController

@synthesize deledate;

+(BOOL) isRefreshEvailable:(int)serverRevision;
{
    int _numberRevision;
    NSUserDefaults *userDef=[NSUserDefaults standardUserDefaults];
    if (![userDef objectForKey:@"revisionServer"]) {
        _numberRevision=NUMBER_REVISION_DEFAULT;
        [userDef setInteger:_numberRevision forKey:@"revisionServer"];
    }else {
        _numberRevision=[userDef integerForKey:@"revisionServer"];
    }
        
    if (serverRevision>_numberRevision){
        _numberRevision=serverRevision;
        
        [userDef setInteger:_numberRevision forKey:@"revisionServer"];
        
        return YES;
    }else {
        return NO;
    }
}


-(void) refreshContent;
{
    [self downloadFileURL:URL_CONTENT_FILE_DEFULT];
}

-(NSString*)downloadFileURL:(NSString *)pUrl;
{    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:pUrl]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
    }
    return nil;
}

-(NSString*)downloadImageFromDocumentDirectory:(NSString *)pUrl;
{    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *pName=[pUrl lastPathComponent];
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:pName];
    
    NSFileManager *filemgr;
    
    filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: folderPath ] == YES){
        DLog (@"File exists %@",folderPath);
        return pName;
    }
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:pUrl]];
    [data writeToFile:folderPath atomically:YES];
    
    return pName;
}



#pragma mark NSURLConnection handlers

- (void)connectionDidFinishLoading:(NSURLConnection *)connection1 {
    @synchronized(self){
            
            NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        DLog(@"jsonString %@",jsonString);

            NSDictionary *jsonDictionary = ValidateObject([jsonString JSONValue], [NSDictionary class]);
            NSArray *arrKeys=[jsonDictionary allKeys];
            for (NSString *key in arrKeys) {
                keyForUserDefualts=key;
                id element=[jsonDictionary objectForKey:keyForUserDefualts];
                if ([element isKindOfClass:[NSMutableArray class]]) {
                    
                    arrToInput=[[NSMutableArray alloc] init];
                    for (int i=0; i<[element count]; i++) {
                        
                        elementOfArray=[element objectAtIndex:i];
                        keyOfElement=[[elementOfArray allKeys] objectAtIndex:0];
                        
                        if ([keyOfElement isEqualToString:@"string"]) {
                            NSString *stringElement=[elementOfArray valueForKey:keyOfElement];
                            [arrToInput addObject:stringElement];
                        }else {
                            if([keyForUserDefualts isEqualToString:USER_DEFULTS_KEY_NEW_VERSION_APP]){
                                if (![self isVersionOfCurentAppValid]) {
                                    [self refreshListWithSimpleObject];
                                }
                            }else{
                                [self refreshListWithSimpleObject];
                            }   
                        }
                    }
                    DLog(@"Refresh Complite for key <%@> array %@",keyForUserDefualts,arrToInput);
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arrToInput];
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:keyForUserDefualts];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }else if ([element isKindOfClass:[NSString class]]){
                    
                    if ([keyForUserDefualts isEqualToString:@"img"]) {
                        [self downloadImageFromDocumentDirectory:element];
                         DLog(@"Download Complite for key <%@> image",keyForUserDefualts);
                    }else if ([keyForUserDefualts isEqualToString:@"img_delete"]) {
                        [CollectionAppWrapper deleteImage:element];
                        DLog(@"Delete Image for key <%@>",keyForUserDefualts);
                    }else {
                        //                        to user def
                        [[NSUserDefaults standardUserDefaults] setObject:element forKey:keyForUserDefualts];
                         DLog(@"Refresh Complite for key <%@> element %@",keyForUserDefualts,element);
                    }
                }
            }
        }
    [deledate finishRefresh];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [deledate finishWithError];
    // inform the user
    DLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

#pragma mark -

-(void)refreshListWithSimpleObject
{
    Class elementToAdd = NSClassFromString(keyOfElement);
    NSObject *elementToAddObject=[[elementToAdd alloc] init];

    NSDictionary *elementWithProperties=[elementOfArray valueForKey:keyOfElement];
    [self fillProperties:elementWithProperties toObject:elementToAddObject];   

    [arrToInput addObject:elementToAddObject];
}

-(void)refreshListWithObjectForApps
{
//    Init element to add
    Class elementToAdd = NSClassFromString(keyOfElement);
    NSObject *elementToAddObject=[[elementToAdd alloc] init];
    
//    Take array of elements on device
    NSString *nameOfAppToAdd=[[NSString alloc] init];
    NSString *versionOfAppToAdd=[[NSString alloc] init];
    
    NSDictionary *elementWithProperties=[elementOfArray valueForKey:keyOfElement];
    
    nameOfAppToAdd=[elementWithProperties objectForKey:@"CdName"];
    versionOfAppToAdd=[elementWithProperties objectForKey:@"CdAppVersion"];
    
    CDCollectionApp *elementFromDevice=[[CDCollectionApp alloc] init];
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:keyForUserDefualts];
    NSMutableArray *elementsOnDevice=[[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data1]];

    NSUInteger indexOfFindApp=[self findObjectByName:nameOfAppToAdd inArray:elementsOnDevice];
    if (indexOfFindApp!=-1) {
        elementFromDevice=[elementsOnDevice objectAtIndex:indexOfFindApp];
        if ([elementFromDevice.cdAppVersion isEqualToString:versionOfAppToAdd]) {
            [arrToInput addObject:elementFromDevice]; 
            return;
        }
    }
    
    [CollectionAppWrapper removeContentAdvertisingApps:(CDCollectionAdvertisingApp*)elementFromDevice];

//    Fill properties of element
    [self fillProperties:elementWithProperties toObject:elementToAddObject];   
    [arrToInput addObject:elementToAddObject]; 
}

-(void)fillProperties:(NSDictionary *)elementWithProperties toObject:(NSObject *)elementToAddObject;
{
    for (NSString *keyParametr in [elementWithProperties allKeys]) {
        NSString *stringElement;
        NSString *nameProcedure=[NSString stringWithFormat:@"set%@:",keyParametr];
        
        if ([[elementWithProperties objectForKey:keyParametr] isKindOfClass:[NSDictionary class]]) {
            stringElement=[self downloadImageFromDocumentDirectory:[[elementWithProperties objectForKey:keyParametr] objectForKey:@"img"]];
        }else {
            stringElement=[elementWithProperties objectForKey:keyParametr];
            if ([stringElement isAllDigits]&&![stringElement isEqualToString:@""]) {
                NSUInteger intValueToAdd=[stringElement intValue];
                [elementToAddObject performSelector:NSSelectorFromString(nameProcedure) withObject:[NSNumber numberWithInt:intValueToAdd]];
                continue;
            }
        }
        
        [elementToAddObject performSelector:NSSelectorFromString(nameProcedure) withObject:stringElement];
    }
}
-(BOOL)isVersionOfCurentAppValid
{
    NSDictionary *elementWithProperties=[elementOfArray valueForKey:keyOfElement];    
    NSString *versionOfAppToAdd=[elementWithProperties objectForKey:@"CdAppVersion"];
    
    NSString *curentVersionApp = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if ([versionOfAppToAdd isEqualToString:curentVersionApp]) {
        return YES;
    }else {
        return NO;
    }
}

-(NSUInteger)findObjectByName:(NSString *)nameApp inArray:(NSMutableArray *) appsOnDevice
{
    if ([appsOnDevice count] != 0) {
        for (CDCollectionApp *app in appsOnDevice) {
            if ([app.cdName isEqualToString:nameApp]) {
                return [appsOnDevice indexOfObject:app];
            }
        }
    }
    return -1;
}

@end
