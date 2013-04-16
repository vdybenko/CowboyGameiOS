//
//  LoadViewController.m
//  Test
//
//  Created by Sobol on 13.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface LoadViewController()
{
    AVAudioPlayer *player;
    StartViewController  *startViewController;
    BOOL firstRun;
    NSMutableData *receivedData;
    __weak IBOutlet UILabel *versionLabel;
    __weak IBOutlet UIImageView *imgBackground;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
}
@end

static const char *A_URL =  BASE_URL"api/authorization";

@implementation LoadViewController

-(id)initWithPush:(__weak NSDictionary *)notification
{
    self = [super initWithNibName:@"LoadViewContoller" bundle:[NSBundle mainBundle]];
    if(self){
        [self loadView];
        [AccountDataSource sharedInstance];
        [activityIndicator stopAnimating];
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"AlreadyRun"] ) {
            firstRun = YES;
            [self login];
//            [startViewController checkNetworkStatus:Nil];
        }else{
            firstRun = NO;
        }

        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Back1start.mp3", [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [player play];
        
        startViewController = [StartViewController sharedInstance];
        [[GCHelper sharedInstance] setPresentingViewController:startViewController];
        [[GCHelper sharedInstance] setDelegate2:startViewController];
        
        NSDictionary *remoteNotif =
        [notification objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotif){
            startViewController.pushNotification = remoteNotif;
        }
        
        CGRect frame = [[UIScreen mainScreen]bounds];
        
        if (frame.size.height > 480) {
            imgBackground.image = [UIImage imageNamed:@"Default-568h.png"];
        }
        else{
            imgBackground.image = [UIImage imageNamed:@"Default.png"];
        }
        NSString *version = @"Version ";
        if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] != nil) {
            version = [version stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
            version = [version stringByAppendingString:@"."];
            version = [version stringByAppendingString:kRevisionNumber];
        } else {
            version = @"";
        }
        
        [versionLabel setTextColor:[UIColor whiteColor]];
        [versionLabel setFont:[UIFont systemFontOfSize:10]];
        [versionLabel setBackgroundColor:[UIColor clearColor]];
        versionLabel.text = version;
        [versionLabel setHidden:NO];
        versionLabel = nil;
        
        if (!firstRun || ![startViewController connectedToWiFi]) {
            [self performSelector:@selector(closeWindow) withObject:self afterDelay:3.0];
        }
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/LoadVC" forKey:@"page"]];
}

-(void)releaseComponents
{
    player = nil;
    startViewController = nil;
    imgBackground = nil;
    receivedData = nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)closeWindow {
    [player stop];
    [self.navigationController pushViewController:startViewController animated:NO];
//    // First run message
	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"AlreadyRun"] ) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AlreadyRun"];
    }
    [self releaseComponents];
}

-(void)login
{
    [activityIndicator startAnimating];
    activityIndicator.hidden = NO;
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:A_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:5.0];
    
    [theRequest setHTTPMethod:@"POST"]; 
    
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                           [[AccountDataSource sharedInstance] verifyAccountID],@"id",
                           nil];
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
	[theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    
    NSURLConnection *theConnection=[NSURLConnection connectionWithRequest:theRequest delegate:self];
    if (theConnection) {
        //        [receivedData setLength:0];
        receivedData = [[NSMutableData alloc] init];
    } else {
    }
}

#pragma mark CustomNSURLConnection handlers

- (void)connectionDidFinishLoading:(NSURLConnection *)connection1 {    
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    DLog(@"LoadViewController connectionDidFinishLoading %@",jsonString);
    NSDictionary *responseObject = ValidateObject([jsonString JSONValue], [NSDictionary class]);
    if ([responseObject objectForKey:@"refresh_content"]) {
        DLog(@"get Refresh");
        int revisionNumber=[[responseObject objectForKey:@"refresh_content"] intValue];
        
        int revisionProductListNumber=[[responseObject objectForKey:@"v_of_store_list"] intValue];
        if ([DuelProductDownloaderController isRefreshEvailable:revisionProductListNumber]) {
            [startViewController.duelProductDownloaderController refreshDuelProducts];
        }
        
        if ([RefreshContentDataController isRefreshEvailable:revisionNumber]) {
            
            RefreshContentDataController *refreshContentDataController=[[RefreshContentDataController alloc] init];
            [refreshContentDataController setDeledate:self];
            [refreshContentDataController refreshContent];
        }else {
            [self closeWindow];
        }
        if ([responseObject objectForKey:@"session_id"])
        {
            DLog(@"Session id error!!");
            return;
        }
         NSString *sesion =[[NSString alloc] initWithString:[responseObject objectForKey:@"session_id"]];
        [[AccountDataSource sharedInstance] setSessionID:sesion];
        DLog(@"get sesion %@",sesion);
    }else
    {
        [self closeWindow];
    }
    
    [activityIndicator stopAnimating];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [activityIndicator stopAnimating];
    [self closeWindow];
    DLog(@"Start Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

-(void)openSaloon
{
    [startViewController performSelector:@selector(startDuel) withObject:nil afterDelay:5.0];
}


#pragma mark RefreshContentDataControllerDelegate

-(void)finishRefresh;
{
    [activityIndicator stopAnimating];
    [self closeWindow];
}
-(void)finishWithError;
{
    [activityIndicator stopAnimating];
    [self closeWindow];
}

- (void)viewDidUnload {
    versionLabel = nil;
    imgBackground = nil;
    activityIndicator = nil;
    [super viewDidUnload];
}
@end
