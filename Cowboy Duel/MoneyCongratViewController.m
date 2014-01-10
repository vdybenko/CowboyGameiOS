//
//  MoneyCongratViewController.m
//  Bounty Hunter 1
//
//  Created by AlexandrBezpalchuk on 02.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoneyCongratViewController.h"
#import "OGHelper.h"
#import "UIButton+Image+Title.h"
#import "ActiveDuelViewController.h"

@interface MoneyCongratViewController ()
{
    AccountDataSource *playerAccount;
    ActivityIndicatorView *activityIndicatorView;
    
    NSString *moneyLabel;
    
    double angle;
    
    BOOL runAnimation;
    
    //images to animate:
    __weak IBOutlet UIImageView *ivAchieveRing;
    __weak IBOutlet UIImageView *ivLight;
    __weak IBOutlet UIImageView *ivRing;
    
    //labels:
    __weak IBOutlet UILabel *lbTitleCongratulation;
    
    __weak IBOutlet UILabel *lbPlusMoney;
    __weak IBOutlet UILabel *lbCongMainText;
    
    __weak IBOutlet UIButton *btnBack;
    __weak IBOutlet UIButton *btnTryAgain;
    __weak IBOutlet UIButton *btnPost;
    
    __weak IBOutlet UILabel *lbPostOnFB;
    
    UIInterfaceOrientationMask orient;
}
@property(nonatomic, weak)id<ActiveDuelViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *ivLight2;

@end

@implementation MoneyCongratViewController
@synthesize delegate;
@synthesize ivLight2;
- (id) initForAchivmentPlayerAccount:(AccountDataSource *)pPlayerAccount withLabel:(NSString*)pLabel andController:(id)delegateController tryButtonEnable:(BOOL)tryButtonEnable orientation:(UIInterfaceOrientationMask)pOrient;
{
    orient = pOrient;
    if (orient == UIInterfaceOrientationMaskLandscape) {
        self = [super initWithNibName:@"MoneyCongratViewControllerLandscape" bundle:[NSBundle mainBundle]];
    }else{
        self = [super initWithNibName:@"MoneyCongratViewController" bundle:[NSBundle mainBundle]];
    }
    if (self){
        [super loadView];
        moneyLabel=pLabel;
        playerAccount=pPlayerAccount;
        
        [self initMainControls];
        
        self.delegate = delegateController;
        
        if ([[OGHelper sharedInstance]isAuthorized]){
            [lbPostOnFB setHidden:YES];
            [btnPost setHidden:YES];
            [MoneyCongratViewController achivmentMoney:playerAccount.money];
        }
        
        btnTryAgain.enabled = tryButtonEnable;
    }
    return self;
}

-(void)initMainControls;
{
    UIColor *mainColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    UIColor *congColor = [UIColor colorWithRed:255.0f/255.0f green:248.0f/255.0f blue:225.0f/255.0f alpha:1.0f];
    
    lbTitleCongratulation.text = NSLocalizedString(@"AchievTitle", nil);
    lbTitleCongratulation.textColor = mainColor;
    lbTitleCongratulation.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    lbTitleCongratulation.hidden=NO;
    
    lbPlusMoney.text = moneyLabel;
    [lbPlusMoney setAdjustsFontSizeToFitWidth:YES];
    [lbPlusMoney setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    lbPlusMoney.textColor = mainColor;
    lbPlusMoney.font = [UIFont fontWithName: @"DecreeNarrow" size:45];
    
    [lbCongMainText setTextColor:congColor];
    [lbCongMainText setFont: [UIFont systemFontOfSize:18.0f]];
    lbCongMainText.text = [NSString stringWithFormat:@"%@%@%d%@%@", NSLocalizedString(@"GoldAchievText1", nil),
                           NSLocalizedString(@"GoldAchievText2", nil),
                           playerAccount.money,
                           NSLocalizedString(@"GoldAchievText3", nil),
                           NSLocalizedString(@"GoldAchievText4", nil)];

    [btnTryAgain setTitleByLabel:@"TRY"];
    [btnTryAgain changeColorOfTitleByLabel:btnColor];
    
    [btnBack setTitleByLabel:@"BACK"];
    [btnBack changeColorOfTitleByLabel:btnColor];
    
    lbPostOnFB.font = [UIFont systemFontOfSize:9.0f];
    lbPostOnFB.textColor = [UIColor whiteColor];
    lbPostOnFB.numberOfLines = 2;
    lbPostOnFB.lineBreakMode = UILineBreakModeCharacterWrap;
    lbPostOnFB.text = NSLocalizedString(@"AchievBtnTellFriends", nil);
}

- (void)viewDidUnload
{
    lbTitleCongratulation = nil;
    lbPlusMoney = nil;
    lbCongMainText = nil;
    
    lbPostOnFB = nil;
    ivAchieveRing = nil;
    ivLight = nil;
    ivLight2 = nil;
    ivRing = nil;
    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    angle = 0;
    runAnimation = YES;
    [self performSelector:@selector(scaleAnimation) withObject:self afterDelay:0.3];
    [self shineAnimation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/MoneyCongratVC" forKey:@"page"]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    runAnimation = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    if (orient == UIInterfaceOrientationMaskLandscape && [[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
}


-(void)releaseComponents
{
    lbTitleCongratulation = nil;
    lbPlusMoney = nil;
    lbCongMainText = nil;
    
    lbPostOnFB = nil;
    ivAchieveRing = nil;
    ivLight = nil;
    ivLight2 = nil;
    ivRing = nil;
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return NO;
}

-(NSUInteger) supportedInterfaceOrientations{
    if(orient==UIInterfaceOrientationMaskLandscape){
        return UIInterfaceOrientationMaskLandscape;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation{
    if(orient==UIInterfaceOrientationMaskLandscape){
        return UIInterfaceOrientationLandscapeRight;
    }else{
        return UIInterfaceOrientationPortrait;
    }
}

#pragma mark -
#pragma mark animations

-(void)scaleAnimation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
    [UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(scaleStopAnimation)];
    
    CGAffineTransform transform;
    transform = CGAffineTransformMakeScale(1.2, 1.2);
    ivRing.transform = transform;
    ivAchieveRing.transform = transform;
    
    [UIView commitAnimations];
}

-(void)scaleStopAnimation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
    [UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
    CGAffineTransform transform;
    transform = CGAffineTransformMakeScale(1.0, 1.0);
    ivRing.transform = transform;
    ivAchieveRing.transform = transform;
    
    [UIView commitAnimations];
}

-(void)shineAnimation
{
  [UIView animateWithDuration:1.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     angle += 5.0;
                     CGAffineTransform transform;
                     CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
                     transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
                     ivLight2.transform = transform;
                     
                     
                   } completion:^(BOOL finished) {
                     if (runAnimation)[self shineSecondAnimation];
                   }];
}

-(void)shineSecondAnimation
{
  [UIView animateWithDuration:1.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     angle += 5.0;
                     CGAffineTransform transform;
                     CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
                     transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
                     ivLight2.transform = transform;
                  } completion:^(BOOL finished) {
                     if (runAnimation)[self shineAnimation];
                   }];
}

#pragma mark -

-(void)blockTryAgain;
{
    btnTryAgain.enabled = NO;
}
#pragma mark -

#pragma mark IBActions

- (IBAction)btnMenuClicked:(id)sender
{
    if ([delegate respondsToSelector:@selector(backButtonClick:)])
    {
        [(ActiveDuelViewController *)delegate backButtonClick:sender];
    }
    [self dismissModalViewControllerAnimated:YES];
    [self releaseComponents];
}

- (IBAction)btnAgainClicked:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [activityIndicatorView showView];
    if ([(ActiveDuelViewController *)delegate respondsToSelector:@selector(tryButtonClick:)])
    {
        [(ActiveDuelViewController *)delegate tryButtonClick:sender];
    }
    [self releaseComponents];
}

- (IBAction) btnPostOnFBClicked:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    if ([[OGHelper sharedInstance]isAuthorized]) {
        [MoneyCongratViewController achivmentMoney:playerAccount.money];
    }else {
        [[StartViewController sharedInstance] clickLogin:Nil];
        [self btnMenuClicked:Nil];
    }
    [self releaseComponents];
}
#pragma mark  - Facebook methods

+(void)achivmentMoney:(NSUInteger)money;
{
    [[OGHelper sharedInstance] apiGraphScorePost:money];
}
@end
