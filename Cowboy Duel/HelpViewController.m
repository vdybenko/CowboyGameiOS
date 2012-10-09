//
//  HelpViewController.m
//  Test
//
//  Created by Taras on 16.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"
#import <UIKit/UIKit.h>
#import "StartViewController.h"
#import "UIButton+Image+Title.h"
#import "UIView+Dinamic_BackGround.h"
#import "HCYoutubeParser.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation HelpViewController
@synthesize scrollView, pageControl, viewControllers;
@synthesize _btnVideo, _vBackground, _btnBack, _webViewMessage;

MPMoviePlayerViewController *mp;
NSString *const URL_CONTACN_US=@"http://cowboyduel.com/"; 


- (id)init:(BOOL)firstStart startVC:(id)startVCl;
{
    self = [super initWithNibName:@"HelpViewController" bundle:[NSBundle mainBundle]];
    if (self) { 
        firstRun=firstStart;
        startVC=startVCl;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [_btnBack setImage:@"pv_btn_back.png" title:NSLocalizedString(@"BACK", nil)];
//    [_btnVideo setImage:@"st_btn.png" title:NSLocalizedString(@"VIDEO MANUAL", nil)];
    
    UIColor *mainColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    
    lbTitleHelp.text = NSLocalizedString(@"HelpTitle", @"");
    lbTitleHelp.textColor = mainColor;
    lbTitleHelp.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    lbBackBtn.text = NSLocalizedString(@"BACK", nil);
    lbBackBtn.textColor = btnColor;
    lbBackBtn.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    lbVideoBtn.text = NSLocalizedString(@"manual", nil);
    lbVideoBtn.textColor = btnColor;
    lbVideoBtn.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    lbContactButton.text = NSLocalizedString(@"ContactUs", nil);
    lbContactButton.textColor = btnColor;
    lbContactButton.font = [UIFont fontWithName: @"DecreeNarrow" size:24];

    
    [_webViewMessage setOpaque:NO];
    [_webViewMessage setBackgroundColor:[UIColor clearColor]];
    [_webViewMessage loadHTMLString:[NSString stringWithFormat:@"%@%@%@",
                                     NSLocalizedString(@"HTML_HEAD", @""),
                                     NSLocalizedString(@"HV_TEXT_NEW", @""),
                                     NSLocalizedString(@"HTML_ASS", @"")] 
                            baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

-(void) viewWillAppear:(BOOL)animated
{
    [mainView setDinamicHeightBackground];
}

- (void)viewDidUnload
{
    lbBackBtn = nil;
    lbVideoBtn = nil;
    lbTitleHelp = nil;
    btnContact = nil;
    lbContactButton = nil;
    mainView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)backButtonClick
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop,
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

-(IBAction)btnFB{
    
    NSDictionary *videos = [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:btnFBHelp]];
    mp = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[videos objectForKey:@"medium"]]];
    
    if ([mp.moviePlayer respondsToSelector:@selector(setFullscreen:animated:)]) {  
        // Use the new 3.2 style API
        mp.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;  
        mp.moviePlayer.shouldAutoplay = YES;
        mp.moviePlayer.repeatMode = MPMovieRepeatModeNone;
       
        [self presentMoviePlayerViewControllerAnimated:mp];
        
        [mp.moviePlayer setFullscreen:YES animated:YES];  
    } else {  
        // Use the old 2.0 style API  
        mp.moviePlayer.movieControlMode = MPMovieControlModeHidden;  
        [mp.moviePlayer play]; 
    }      
    if([startVC connectedToWiFi]) [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                                                      object:self
                                                                                    userInfo:[NSDictionary dictionaryWithObject:@"/help_video" forKey:@"event"]];
}

-(IBAction)btnContactClicked{
    NSURL *url=[NSURL URLWithString:URL_CONTACN_US];
    [[UIApplication sharedApplication] openURL:url];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {  
   
    mp.moviePlayer.initialPlaybackTime = -1; 
    
    [mp.moviePlayer stop]; 
   
    [self dismissMoviePlayerViewControllerAnimated];
}  

@end
