//
//  LevelCongratViewController.m
//  Bounty Hunter 1
//
//  Created by AlexandrBezpalchuk on 02.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LevelCongratViewController.h"
#import "OGHelper.h"
#import "DuelRewardLogicController.h"
#import "ActiveDuelViewController.h"

@interface LevelCongratViewController ()
{
    AccountDataSource *playerAccount;
    ActivityIndicatorView *activityIndicatorView;
    
    int money;
    double angle;
    
    __weak IBOutlet UIImageView *ivImageForLevel;
    
    //images to animate:
    __weak IBOutlet UIImageView *ivLightRays;
    __weak IBOutlet UIImageView *ivLevelRing;
    __weak IBOutlet UIImageView *ivLevelCoint;
    
    //labels:
    __weak IBOutlet UILabel *lbTitleRankAchieve;
    
    __weak IBOutlet UILabel *lbCongLvlMainText;
    __weak IBOutlet UILabel *lbAgain;
    __weak IBOutlet UILabel *lbMenu;
    __weak IBOutlet UILabel *lbPostOnFB;
    //buttons:
    __weak IBOutlet UIButton *btnAgain;
    __weak IBOutlet UIButton *btnMenu;
    __weak IBOutlet UIButton *btnPost;
    
    UIInterfaceOrientationMask orient;
    BOOL runAnimation;
}
//@property(nonatomic, weak)id<DuelViewControllerDelegate> delegate;
@property(nonatomic, weak)id<ActiveDuelViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *ivLightRays2;
@end

@implementation LevelCongratViewController
@synthesize delegate;
@synthesize ivLightRays2;

- (id) initForNewLevelPlayerAccount:(AccountDataSource *)pPlayerAccount andController:(id)delegateController tryButtonEnable:(BOOL)tryButtonEnable  orientation:(UIInterfaceOrientationMask)pOrient;{
    orient = pOrient;
    if (orient == UIInterfaceOrientationMaskLandscape) {
        self = [super initWithNibName:@"LevelCongratViewControllerLandscape" bundle:[NSBundle mainBundle]];
    }else{
        self = [super initWithNibName:@"LevelCongratViewController" bundle:[NSBundle mainBundle]];
    }
    if (self){
        [super loadView];
        
        [self createControls];
        
        playerAccount=pPlayerAccount;
        
        NSString *Rank=[NSString stringWithFormat:@"%dRank",playerAccount.accountLevel];
        NSString *userRank = NSLocalizedString(Rank, @"");
        lbTitleRankAchieve.text = [NSString stringWithFormat:@"%@",userRank];
        
        NSString *name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel];
        ivImageForLevel.image = [UIImage imageNamed:name];
        
        NSString *st=[NSString stringWithFormat:@"%dRankText",playerAccount.accountLevel];
        lbCongLvlMainText.text = NSLocalizedString(st, @"");
        
        self.delegate = delegateController;
        
        if ([[OGHelper sharedInstance]isAuthorized]){
            [lbPostOnFB setHidden:YES];
            [btnPost setHidden:YES];
            [LevelCongratViewController newLevelNumber:playerAccount.accountLevel];
        }
        btnAgain.enabled = tryButtonEnable;
    }
    return self;
}

-(void)createControls;
{
    UIColor *mainColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    UIColor *textColor = [UIColor colorWithRed:97.0f/255.0f green:68.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
    
    UIColor *congColor = [UIColor colorWithRed:255.0f/255.0f green:248.0f/255.0f blue:225.0f/255.0f alpha:1.0f];
    
    lbTitleRankAchieve.textColor = textColor;
    

    lbTitleRankAchieve.textColor = mainColor;
    lbTitleRankAchieve.font = [UIFont fontWithName: @"DecreeNarrow" size:35];
    
    [lbCongLvlMainText setTextColor:congColor];
    [lbCongLvlMainText setFont: [UIFont systemFontOfSize:18.0f]];
    
    lbAgain.text = NSLocalizedString(@"TRY", nil);
    lbAgain.textColor = btnColor;
    lbAgain.font = [UIFont fontWithName: @"DecreeNarrow" size:24];
    
    lbMenu.text = NSLocalizedString(@"BACK", nil); 
    lbMenu.textColor = btnColor;
    lbMenu.font = [UIFont fontWithName: @"DecreeNarrow" size:24];

    lbPostOnFB.font = [UIFont systemFontOfSize:9.0f];
    lbPostOnFB.textColor = [UIColor whiteColor];
    lbPostOnFB.numberOfLines = 2;
    lbPostOnFB.lineBreakMode = UILineBreakModeCharacterWrap;
    lbPostOnFB.text = NSLocalizedString(@"AchievBtnTellFriends", nil);    
}

- (void)viewDidUnload
{
    lbCongLvlMainText = nil;
    [super viewDidUnload];
    btnAgain = nil;
    btnMenu = nil;
    btnPost = nil;
    lbTitleRankAchieve = nil;
    lbAgain = nil;
    lbMenu = nil;
    lbPostOnFB = nil;
    ivLightRays = nil;
    ivLightRays2 = nil;
    ivLevelRing = nil;
    ivImageForLevel = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    if (orient == UIInterfaceOrientationMaskLandscape && [[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
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
													  userInfo:[NSDictionary dictionaryWithObject:@"/LevelCongratVC" forKey:@"page"]];
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    runAnimation = NO;
}

- (void)releaseComponents
{
    playerAccount = nil;
    activityIndicatorView = nil;
    
    ivImageForLevel = nil;
    
    ivLightRays = nil;
    ivLightRays2 = nil;
    ivLevelRing = nil;
    ivLevelCoint = nil;
    lbTitleRankAchieve = nil;
    lbCongLvlMainText = nil;
    lbAgain = nil;
    lbMenu = nil;
    lbPostOnFB = nil;
    
    btnAgain = nil;
    btnMenu = nil;
    btnPost = nil;
    ivLightRays2 = nil;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
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

#pragma mark

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
    ivLevelRing.transform = transform;
    ivLevelCoint.transform = transform;
    
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
    ivLevelRing.transform = transform;
    ivLevelCoint.transform = transform;
    
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
                     ivLightRays2.transform = transform;
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
                     ivLightRays2.transform = transform;
                   } completion:^(BOOL finished) {
                     if (runAnimation)[self shineAnimation];
                   }];
}
#pragma mark -

-(void)blockTryAgain;
{
    btnAgain.enabled = NO;
}
#pragma mark -
#pragma mark IBActions

- (IBAction)btnMenuClicked:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    if ([delegate respondsToSelector:@selector(backButtonClick:)])
    {
        [(ActiveDuelViewController *)delegate backButtonClick:sender];
    }
    [self releaseComponents];
}

- (IBAction)btnAgainClicked:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [activityIndicatorView showView];
    if ([delegate respondsToSelector:@selector(tryButtonClick:)]) 
    {
       [(ActiveDuelViewController *)delegate tryButtonClick:sender];
    }
    [self releaseComponents];
}

- (IBAction) btnPostOnFBClicked:(id)sender
{  
    if ([[OGHelper sharedInstance]isAuthorized]) { 
        [LevelCongratViewController newLevelNumber:playerAccount.accountLevel];
    }else {
        [[StartViewController sharedInstance] clickLogin:Nil];
        [self btnMenuClicked:Nil];
    }    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark  - Facebook methods

+(void)newLevelNumber:(NSInteger)level;
{
    NSString *URL=[[NSString alloc] initWithFormat:@"http://cowboyduel.org/achievment/got/%d",level];
    [[OGHelper sharedInstance ] apiGraphCustomActionPost:URL actionTypeName:@"get" objectTypeName:@"achievement"];
}
@end
