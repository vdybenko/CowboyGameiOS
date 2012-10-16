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

#define videoHelp @"http://www.youtube.com/watch?v=HZST2wcGAr4"

@interface HelpViewController () {
    id startVC;
    
    IBOutlet UIButton *_btnVideo;
    IBOutlet UIView *mainView;
    IBOutlet UIButton *_btnBack;
    IBOutlet UIButton *btnContact;
    IBOutlet UIWebView *_webViewMessage;
    IBOutlet UIView *_vBackground;
    IBOutlet UILabel *lbBackBtn;
    IBOutlet UILabel *lbVideoBtn;
    IBOutlet UILabel *lbContactButton;
    
    IBOutlet UILabel *lbTitleHelp;
}
@property (strong, nonatomic) IBOutlet UIButton *_btnVideo;
@property (strong, nonatomic) IBOutlet UIButton *_btnBack;
@property (strong, nonatomic) IBOutlet UIWebView *_webViewMessage;
@property (strong, nonatomic) IBOutlet UIView *_vBackground;
@end

@implementation HelpViewController
@synthesize _btnVideo, _vBackground, _btnBack, _webViewMessage;

MPMoviePlayerViewController *mp;
NSString *const URL_CONTACN_US=@"http://cowboyduel.com/"; 

- (id)initWithStartVC:(id)startVCl;
{
    self = [super initWithNibName:@"HelpViewController" bundle:[NSBundle mainBundle]];
    if (self) { 
        startVC=startVCl;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    
    NSURL *url = [NSURL URLWithString:videoHelp];
    NSDictionary *qualities = [HCYoutubeParser h264videosWithYoutubeURL:url];
    
    NSURL *urlVideo = [NSURL URLWithString:[qualities objectForKey:@"medium"]];

    MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] initWithContentURL:urlVideo];
    
    mp.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    mp.moviePlayer.shouldAutoplay = YES;
    mp.moviePlayer.repeatMode = MPMovieRepeatModeNone;
    
    [self presentMoviePlayerViewControllerAnimated:mp];
    
    [mp.moviePlayer setFullscreen:YES animated:YES];
    
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
