
#import "IconDownloader.h"
#import <QuartzCore/QuartzCore.h>

#define kAppIconHeight 70

@implementation IconDownloader

@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize namePlayer;
@synthesize avatarURL;
@synthesize imageDownloaded;
#pragma mark

- (void)startDownloadFBIcon
{
    [[OGHelper sharedInstance] apiGraphGetImageForList:namePlayer didFinishBlock:^(UIImage *image){
        imageDownloaded = image;
        [delegate appImageDidLoad:self.indexPathInTableView];
        
        NSString *path = [NSString stringWithFormat:@"%@/icon_%@.png",[[OGHelper sharedInstance] getSavePathForList],namePlayer];
        [UIImagePNGRepresentation(imageDownloaded) writeToFile:path atomically:YES];
    }];
}

- (void)startDownloadSimpleIcon
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:avatarURL]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    NSURLConnection *theConnection=[NSURLConnection connectionWithRequest:theRequest delegate:self];
    if (theConnection) {
        receivedData = [[NSMutableData alloc] init];
    }
}

-(void)releaseComponents
{
    indexPathInTableView = nil;
    namePlayer = nil;
    avatarURL = nil;
    imageDownloaded = nil;
    indexPathInTableView = nil;
   	namePlayer = nil;
    avatarURL = nil;
    imageDownloaded = nil;
    receivedData = nil;
}
/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    DLog(@"IconDownloader didFailWithError: %@ /n error %@ /n namePlayer %@"  , request,[error description],namePlayer);
}

#pragma mark CustomNSURLConnection handlers

- (void)connectionDidFinishLoading:(NSURLConnection *)connection1 {
    imageDownloaded = [UIImage imageWithData:receivedData];
    [delegate appImageDidLoad:self.indexPathInTableView];
    
    NSString *path = [NSString stringWithFormat:@"%@/icon_%@.png",[[OGHelper sharedInstance] getSavePathForList],namePlayer];
    [UIImagePNGRepresentation(imageDownloaded) writeToFile:path atomically:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    DLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

@end
