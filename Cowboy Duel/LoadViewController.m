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
    UIImageView *imgBackground;
    NSMutableData *receivedData;
}
@end

static const char *A_URL =  BASE_URL"api/authorization";

@implementation LoadViewController

-(id)initWithPush:(NSDictionary *)notification
{
    if(self==[super init])
    {
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"AlreadyRun"] ) {
            firstRun = YES;
            [self login];
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
    
        CGRect frame = [[UIScreen mainScreen]bounds];
        
        if (frame.size.height > 480) {
            imgBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h.png"]];
        }
        else imgBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
        
        [self.view addSubview:imgBackground];
        
        NSString *version = @"Version ";
        if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] != nil) {
            version = [version stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
            version = [version stringByAppendingString:@"."];
            version = [version stringByAppendingString:kRevisionNumber];
        } else {
            version = @"";
        }
        
        UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.size.height - 40, 150, 40)];
        [versionLabel setTextColor:[UIColor whiteColor]];
        [versionLabel setFont:[UIFont systemFontOfSize:10]];
        [versionLabel setBackgroundColor:[UIColor clearColor]];
        versionLabel.text = version;
        [versionLabel setHidden:NO];
        [self.view addSubview:versionLabel];

        if (!firstRun) {
            [self performSelector:@selector(closeWindow) withObject:self afterDelay:3.0]; 
        }
    }
    return self;
}

- (void) viewDidLoad 
{
     
    UIImageView *gunLeftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Gun.png"]];
    [gunLeftImage setFrame:CGRectMake(32-gunLeftImage.frame.size.width, 
                                      self.view.frame.size.height, 
                                      gunLeftImage.frame.size.width, 
                                      gunLeftImage.frame.size.height)];
    [imgBackground addSubview:gunLeftImage];
    
   
    UIImageView *gunRightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Gun.png"]];
    CGAffineTransform transform = CGAffineTransformScale(gunRightImage.transform, -1, 1);
    gunRightImage.transform = transform;
       
    [gunRightImage setFrame:CGRectMake(imgBackground.frame.size.width-32, 
                                      self.view.frame.size.height, 
                                      gunLeftImage.frame.size.width, 
                                      gunLeftImage.frame.size.height)];
    [imgBackground addSubview:gunRightImage];
    
    [self animationWithGunsFirst:gunLeftImage andSecond:gunRightImage];
}

//animation of guns:
- (void) animationWithGunsFirst:  (UIImageView *)imageLeft andSecond:(UIImageView *)imageRight
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES]; 
	[UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
    [UIView setAnimationDuration:1.2f];
	[UIView setAnimationDelegate:self];
   
    
    CGPoint centerPtLeft = CGPointMake(imageLeft.center.x, imageLeft.center.y);
    centerPtLeft.x += imageLeft.frame.size.width; 
    centerPtLeft.y -= imageLeft.frame.size.height;
    imageLeft.center = centerPtLeft;
   
    CGPoint centerPtRight = CGPointMake(imageRight.center.x, imageRight.center.y);
    centerPtRight.x -= imageLeft.frame.size.width;
    centerPtRight.y -= imageLeft.frame.size.height;
    
    imageRight.center = centerPtRight; 
    
        
    [UIView commitAnimations];    
}
//eof animation*/


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)closeWindow {
    [player stop];
    [self.navigationController pushViewController:startViewController animated:NO];
//    // First run message
	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"AlreadyRun"] ) {
		[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"AlreadyRun"];
    }
}

-(void)login
{    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithCString:A_URL encoding:NSUTF8StringEncoding]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:10.0];
    
    [theRequest setHTTPMethod:@"POST"]; 
    
    NSDictionary *dicBody=[NSDictionary dictionaryWithObjectsAndKeys:
                           [[AccountDataSource sharedInstance] verifyAccountID],@"id",
                           nil];
    NSString *stBody=[Utils makeStringForPostRequest:dicBody];
	[theRequest setHTTPBody:[stBody dataUsingEncoding:NSUTF8StringEncoding]]; 
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    if (theConnection) {
        //        [receivedData setLength:0];
        receivedData = [[NSMutableData alloc] init];
    } else {
    }
    
}

#pragma mark CustomNSURLConnection handlers

- (void)connectionDidFinishLoading:(NSURLConnection *)connection1 {    
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSDictionary *responseObject = ValidateObject([jsonString JSONValue], [NSDictionary class]);
    if (![responseObject objectForKey:@"refresh_content"]) {
        DLog(@"get Refresh");
        int revisionNumber=[[responseObject objectForKey:@"refresh_content"] intValue];
        if ([RefreshContentDataController isRefreshEvailable:revisionNumber]) {
            
            RefreshContentDataController *refreshContentDataController=[[RefreshContentDataController alloc] init];
            [refreshContentDataController setDeledate:self];
            [refreshContentDataController refreshContent];
        }else {
            [self closeWindow];
        }
        NSString *sesion =[[NSString alloc] initWithString:[responseObject objectForKey:@"session_id"]];
        [[AccountDataSource sharedInstance] setSessionID:sesion];
        DLog(@"get sesion %@",sesion);
        return;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self closeWindow];
    DLog(@"Start Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}
#pragma mark RefreshContentDataControllerDelegate

-(void)finishRefresh;
{
    [self closeWindow];
}
-(void)finishWithError;
{
    [self closeWindow];
}

@end
