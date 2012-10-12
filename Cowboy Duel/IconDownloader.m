
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
    [[OGHelper sharedInstance] apiGraphGetImageForList:namePlayer delegate:self];
}

- (void)startDownloadSimpleIcon
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:avatarURL]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:kTimeOutSeconds];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    if (theConnection) {
        receivedData = [[NSMutableData alloc] init];
    }
}

#pragma mark FConnect Methods

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    
    if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
        result = [result objectAtIndex:0];
    }
    
    imageDownloaded = [[UIImage alloc] initWithData:result];
    [delegate appImageDidLoad:self.indexPathInTableView];

    NSString *path = [NSString stringWithFormat:@"%@/icon_%@.png",[[OGHelper sharedInstance] getSavePathForList],namePlayer];
    [UIImagePNGRepresentation(imageDownloaded) writeToFile:path atomically:YES];
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
    imageDownloaded = [[UIImage alloc] initWithData:receivedData];
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
