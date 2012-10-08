//
//  LevelCongratViewController.m
//  Cowboy Duel 1
//
//  Created by AlexandrBezpalchuk on 02.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LevelCongratViewController.h"
#import "OGHelper.h"
#import "FinalViewController.h"
#import "DuelRewardLogicController.h"


@interface LevelCongratViewController ()

@end

@implementation LevelCongratViewController
@synthesize delegate;
@synthesize ivLightRays2;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id) initForNewLevelPlayerAccount:(AccountDataSource *)pPlayerAccount andController:(id)delegateController;
{
    self = [super initWithNibName:@"LevelCongratViewController" bundle:[NSBundle mainBundle]];
    if (self){
        [super loadView];
        
        [self createControls];
        
        playerAccount=pPlayerAccount;
        
        NSString *Rank=[NSString stringWithFormat:@"%dRank",playerAccount.accountLevel];
        NSString *userRank = NSLocalizedString(Rank, @"");
        lbTitleRankAchieve.text = [NSString stringWithFormat:@"%@",userRank];
        
        NSString *name = [NSString stringWithFormat:@"fin_img_%drank.png", playerAccount.accountLevel];
        ivImageForLevel.image = [UIImage imageNamed:name];
        
        
        lbCongLvlMainText.text = [NSString stringWithFormat:@"%@%@%@%d%@", NSLocalizedString(@"LvlAchievText1", nil),[NSString stringWithFormat:@"%@",userRank], NSLocalizedString(@"LvlAchievText2", nil),[DuelRewardLogicController countUpBuletsWithPlayerLevel:playerAccount.accountLevel], NSLocalizedString(@"LvlAchievText3", nil)];
        
        self.delegate = delegateController;
        
        if ([[OGHelper sharedInstance]isAuthorized]){
            [lbPostOnFB setHidden:YES];
            [btnPost setHidden:YES];
            [LevelCongratViewController newLevelNumber:playerAccount.accountLevel];
        }
        
    }
    return self;
}

-(void)createControls;
{
    UIColor *mainColor = [UIColor colorWithRed:255.0f/255.0f green:234.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    UIColor *textColor = [UIColor colorWithRed:97.0f/255.0f green:68.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
    
    UIColor *congColor = [UIColor colorWithRed:255.0f/255.0f green:248.0f/255.0f blue:225.0f/255.0f alpha:1.0f];
    UIFont *textFont = [UIFont systemFontOfSize:17.0f];
    
    lbTitleRankAchieve.textColor = textColor;
    
    // Do any additional setup after loading the view from its nib.

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
    //[self shineAnimation];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // Do any additional setup after loading the view from its nib.
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    runAnimation = NO;
}

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
    angle += 1.1415;
    [UIView beginAnimations:@"Shine" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
    [UIView setAnimationDuration:2.0f];
	[UIView setAnimationDelegate:self];
    
    CGAffineTransform transform = ivLightRays2.transform;
    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
    transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
    ivLightRays2.transform = transform;
    
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
    
    CGAffineTransform transform = ivLightRays2.transform;
    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
    transform = CGAffineTransformScale(rotateTransform, 1.0, 1.0);
    ivLightRays2.transform = transform;
    
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
    NSLog(@"tryButtonClick");
    [self dismissModalViewControllerAnimated:YES];
    [activityIndicatorView showView];
    
    if ([delegate respondsToSelector:@selector(tryButtonClick:)]) 
    {
       [(FinalViewController *)delegate tryButtonClick:sender];
    }
    
}

- (IBAction) btnPostOnFBClicked:(id)sender
{  
    if ([[OGHelper sharedInstance]isAuthorized]) { 
        [LevelCongratViewController newLevelNumber:playerAccount.accountLevel];
    }else {
        [[LoginViewController sharedInstance] setLoginFacebookStatus:LoginFacebookStatusLevel];
        [[LoginViewController sharedInstance] fbLoginBtnClick:self];
    }    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark  - Facebook methods

+(void)newLevelNumber:(NSInteger)level;
{
    NSString *URL=[[NSString alloc] initWithFormat:@"http://cowboyduel.org/achievment/got/%d",level];
    [[OGHelper sharedInstance ] apiGraphCustomActionPost:URL actionTypeName:@"get" objectTypeName:@"achievement"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:@"congratulation_new_level" forKey:@"event"]];
}


@end
