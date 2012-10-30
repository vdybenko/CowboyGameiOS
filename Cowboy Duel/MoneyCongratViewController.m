//
//  MoneyCongratViewController.m
//  Cowboy Duel 1
//
//  Created by AlexandrBezpalchuk on 02.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoneyCongratViewController.h"
#import "OGHelper.h"
#import "UIButton+Image+Title.h"
#import "FinalViewController.h"

@interface MoneyCongratViewController ()
{
    AccountDataSource *playerAccount;
    ActivityIndicatorView *activityIndicatorView;
    
    NSString *moneyLabel;
    
    double angle;
    
    BOOL runAnimation;
    
    //images to animate:
    IBOutlet UIImageView *ivAchieveRing;
    IBOutlet UIImageView *ivLight;
    IBOutlet UIImageView *ivLight2;
    IBOutlet UIImageView *ivRing;
    
    //labels:
    IBOutlet UILabel *lbTitleCongratulation;
    
    IBOutlet UILabel *lbPlusMoney;
    IBOutlet UILabel *lbCongMainText;
    
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnTryAgain;
    IBOutlet UIButton *btnPost;
    
    IBOutlet UILabel *lbPostOnFB;
}
@property(nonatomic, strong)id<DuelViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIImageView *ivLight2;

@end

@implementation MoneyCongratViewController
@synthesize delegate;
@synthesize ivLight2;
- (id) initForAchivmentPlayerAccount:(AccountDataSource *)pPlayerAccount withLabel:(NSString*)pLabel andController:(id)delegateController tryButtonEnable:(BOOL)tryButtonEnable;
{
    self = [super initWithNibName:@"MoneyCongratViewController" bundle:[NSBundle mainBundle]];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    angle = 0;
    runAnimation = YES;
    [self performSelector:@selector(scaleAnimation) withObject:self afterDelay:0.3];
    [self shineAnimation];
    [((FinalViewController *)delegate).view setHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    runAnimation = NO;
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
    angle += 1.1415;
    [UIView beginAnimations:@"Shine" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
    [UIView setAnimationDuration:2.0f];
	[UIView setAnimationDelegate:self];
    
    CGAffineTransform transform = ivLight2.transform;
    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
    transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
    ivLight2.transform = transform;
    
    if (runAnimation)[UIView setAnimationDidStopSelector:@selector(shineSecondAnimation)];
    [UIView commitAnimations];
}

-(void)shineSecondAnimation
{
    angle += 1.1415;
    [UIView beginAnimations:@"ShineSecond" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
    [UIView setAnimationDuration:2.0f];
	[UIView setAnimationDelegate:self];
    
    CGAffineTransform transform = ivLight2.transform;
    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
    transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
    ivLight2.transform = transform;
    
    if (runAnimation)[UIView setAnimationDidStopSelector:@selector(shineAnimation)];
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)btnMenuClicked:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    if ([delegate respondsToSelector:@selector(backButtonClick:)])
    {
        [(FinalViewController *)delegate backButtonClick:sender];
    }
}

- (IBAction)btnAgainClicked:(id)sender
{    
    [activityIndicatorView showView];
    [self dismissModalViewControllerAnimated:YES];
    if ([(FinalViewController *)delegate respondsToSelector:@selector(tryButtonClick:)])
    {
        [(FinalViewController *)delegate tryButtonClick:sender];
    }
}

- (IBAction) btnPostOnFBClicked:(id)sender
{  
    if ([[OGHelper sharedInstance]isAuthorized]) { 
        [MoneyCongratViewController achivmentMoney:playerAccount.money];
    }else {
        [[LoginViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusMoney];
        [[LoginViewController sharedInstance] fbLoginBtnClick:self];
    }
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark  - Facebook methods 

+(void)achivmentMoney:(NSUInteger)money;
{
    [[OGHelper sharedInstance] apiGraphScorePost:money];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"/congratulation_achivment" forKey:@"event"]];
}
@end
