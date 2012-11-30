//
//  TestViewController.m
//  Test
//
//  Created by Sobol on 11.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DuelViewControllerWithXib.h"
#import "StartViewController.h"
#import "DuelRewardLogicController.h"
#import "GameCenterViewController.h"
#import "UIImage+Save.h"
#import "DuelProductDownloaderController.h"
#import "SoundDownload.h"

@interface DuelViewControllerWithXib()
{
    BOOL attentionMustShow;
}
-(void)verticalMode;
-(void)shotStarAnimationVer;

@end

static NSString *ShotSound = @"%@/shot.mp3";

@implementation DuelViewControllerWithXib
@synthesize _vEarth, _infoButton, _ivGun, _btnNab, _lbBullets, delegate,titleSteadyFire;

-(id)initWithAccount:(AccountDataSource *)userAccount oponentAccount:(AccountDataSource *)oponentAccount;
{
    self = [self initWithNib];
    if (self) { 
        playerAccount = userAccount;
        opAccount = oponentAccount;
        
        attentionMustShow = YES;
    }
    return self;
}

-(id)initWithNib;
{
    self = [super initWithNibName:@"DuelViewControllerWithXib" bundle:[NSBundle mainBundle]];
    if (self) { 
        
    }
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewDidLoad
{
    [super viewDidLoad];
// added    
    startInterval = [NSDate timeIntervalSinceReferenceDate];
// above
    
    UIColor *btnColor = [UIColor colorWithRed:244.0f/255.0f green:222.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/follSound.mp3", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    follPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [follPlayer setVolume:1.0];
    [follPlayer play];
    [follPlayer stop];
    
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Duel.mp3", [[NSBundle mainBundle] resourcePath]]];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [player play];
    [player stop];
    
    url = [NSURL fileURLWithPath:[NSString stringWithFormat:ShotSound, [[NSBundle mainBundle] resourcePath]]];
    
    player1 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [player1 play];
    [player1 stop];
    
    player2 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [player2 play];
    [player2 stop];
    
    player3 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [player3 play];
    [player3 stop];
    
    
//    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60.0)];
//	[[UIAccelerometer sharedAccelerometer] setDelegate:self];	
    
    shotCount = 0;
    shotCountForSound=1;
    LisForShot=YES;
    foll=NO;
    
    accelerometrDataSource = [[AccelerometrDataSource alloc] init];
    
    activityIndicatorView = [[ActivityIndicatorView alloc] init];
    imgFrame = activityIndicatorView.frame;
    imgFrame.origin = CGPointMake(0,0);
    activityIndicatorView.frame=imgFrame;
    [self.view addSubview:activityIndicatorView];

    lbBackButton.text = NSLocalizedString(@"BACK", nil);
    lbBackButton.textColor = btnColor;
    lbBackButton.font = [UIFont fontWithName: @"DecreeNarrow" size:24];  
    
    helpPracticeView=[[UIView alloc] initWithFrame:CGRectMake(12, (([UIScreen mainScreen].bounds.size.height - 172)/2), 290, 172)];
    
    [helpPracticeView setHidden:YES];

    UIImageView *imvArm=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dv_arm.png"]];
    CGRect frame = imvArm.frame;
    frame.origin = CGPointMake(90, 12);
    imvArm.frame = frame;
    [helpPracticeView addSubview:imvArm];
    
    UIImageView *imvArrow=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dv_arm_arrow.png"]];
    frame = imvArrow.frame;
    frame.origin = CGPointMake(37, 24);
    imvArrow.frame = frame;
    [helpPracticeView addSubview:imvArrow];
    
    UIButton *cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    frame=cancelBtn.frame;
    frame.origin=CGPointMake(248, 13);
    frame.size=CGSizeMake(33, 33);
    cancelBtn.frame=frame;
    [cancelBtn setImage:[UIImage imageNamed:@"btn_adcolony.png"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelHelpArmClick:) forControlEvents:UIControlEventTouchUpInside];
    [helpPracticeView addSubview:cancelBtn];
    
    [helpPracticeView setDinamicHeightBackground];
    [self.view addSubview:helpPracticeView];    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([DuelProductAttensionViewController isAttensionNeedForOponent:opAccount] && ![playerAccount isPlayerPlayDuel] && attentionMustShow){
        DuelProductAttensionViewController *duelProductAttensionViewController=[[DuelProductAttensionViewController alloc] initWithAccount:playerAccount parentVC:self];
        [self.navigationController presentViewController:duelProductAttensionViewController animated:NO completion:nil];
        [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
        attentionMustShow = NO;
    }

    steadyScale = 1.0;
    [follPlayer setVolume:1.0];
    [activityIndicatorView hideView];
    [_vEarth setHidden:NO];
    
    [titleReady setHidden:NO];
    [titleSteadyFire setHidden:YES];
    
    titleSteadyFire.transform = CGAffineTransformIdentity;
    
    CGRect frame=titleSteadyFire.bounds;
    frame.origin = CGPointMake(80,80);
    frame.size = CGSizeMake(159, 50);
    titleSteadyFire.bounds = frame;
    
    [titleSteadyFire setImage:[UIImage imageNamed:@"dv_steady.png"]];
    
    [self countUpBulets];
    _lbBullets.text=[NSString stringWithFormat:@"%d", shotCountBullet];
    
    [self checkPlayerGun];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    accelerometerStateSend = NO;
    shotCount = 0;
    shotCountForSound=1;
    foll = NO;
    follAccelCheck = NO;
    duelTimerEnd = NO;
    follViewShow = NO;
    soundStart = NO;
    [accelerometrDataSource reloadFint];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[timer invalidate];
    [follPlayer setVolume:0.0];
    [player stop];
    [player1 stop];
    [player2 stop];
    [player3 stop];
    
    
    [_vEarth setHidden:YES];
}

- (void)dealloc {
}
- (void)viewDidUnload {
    lbBackButton = nil;
    [super viewDidUnload];
}
#pragma mark Earth animation

-(void)setRotationWithAngle:(float)angle andY:(float)y
{
    if (steadyScale >= 1.3) scaleDelta = -0.03;
    if (steadyScale <= 1.0) scaleDelta = 0.03;
    steadyScale += scaleDelta;
    if(duelIsStarted)
        steadyScale = 1.0;
    CGAffineTransform transform = CGAffineTransformMakeRotation(-angle-89.5);
    CGAffineTransform eathTransform = CGAffineTransformTranslate(transform, 0, [self abs:y] * 50);
    _vEarth.transform = eathTransform;
    CGAffineTransform steadyTransform = CGAffineTransformScale(eathTransform, steadyScale, steadyScale);
    titleSteadyFire.transform = steadyTransform;
}

#pragma mark

-(float)abs:(float)d
{
    if (d<0) return -1.0 * d;
    else return d;
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    //[self setRotationWithAngle:atan2(acceleration.y, acceleration.x) andY:acceleration.y];
    
    
    rollingX = (acceleration.x * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
    rollingY = (acceleration.y * kFilteringFactor) + (rollingY * (1.0 - kFilteringFactor));
    rollingZ = (acceleration.z * kFilteringFactor) + (rollingZ * (1.0 - kFilteringFactor));
//    DLog(@"acceleration x= %.1f, y= %.1f, z= %.1f", acceleration.x, acceleration.y, acceleration.z);
//    DLog(@"rolling x= %.1f, y= %.1f, z= %.1f", rollingX, rollingY, rollingZ);
    
    [self setRotationWithAngle:atan2(rollingY, rollingX) andY:rollingY];

//ifs for buttons enable/disable    
    if (rollingX >= -0.2) {
        _infoButton.enabled=YES;
        menuButton.enabled = YES;
    }
    if (rollingZ <= -0.7) {
        _infoButton.enabled=YES;
        menuButton.enabled = YES;
    }
    if (rollingX < -0.2)
        if ((rollingZ > -0.7)) {
            _infoButton.enabled=NO;
            menuButton.enabled = NO;
        }           
//eof ifs    
    
        if ((rollingX >= -0.7)&&(rollingZ > -0.6)&&(rollingY<=-0.7))      
    {
//        Position for Shot
        NSLog(@" Position for Shot");
        accelerometerState = NO;
    }
        
    if (rollingX < -0.7)
        if ((rollingZ > -0.7)) {
//       Posirtion for STEADY
            NSLog(@" Posirtion for STEADY");
            accelerometerState = YES;
        } 
    
    if (duelIsStarted){ 
        if (!accelerometerState) 
            _btnNab.enabled = YES;
        else 
            _btnNab.enabled = NO;
    }
}
-(void)partnerFoll
{
    DLog(@"Partner foll");
    [player stop]; 
}

-(void)duelTimerEndFeedBack
{
    duelTimerEnd = YES;
}

-(void)vibrationStart;
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    CGRect frame=titleSteadyFire.bounds;
    frame.origin = CGPointMake(18, -50);
    frame.size = CGSizeMake(270, 275);
    titleSteadyFire.bounds = frame;
    
    [titleSteadyFire setImage:[UIImage imageNamed:@"dv_fire_label.png"]];
}

-(IBAction)buttonClick
{
if (shotCountBullet!=0) {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //AudioServicesPlaySystemSound(pickerTick);
    [self shotStarAnimationVer];
    
//    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:ShotSound, [[NSBundle mainBundle] resourcePath]]];
    switch (shotCountForSound) {
        case 1:
            [titleSteadyFire setHidden:YES];
            
            [player1 stop];
            [player1 setCurrentTime:0.0];
            
            [player1 play];
            shotCountForSound=2;
            break;    
        case 2:
            [player2 stop];
            [player2 setCurrentTime:0.0];
                        [player2 play];
            shotCountForSound=3;
            break;   
        case 3:
            [player3 stop];
            [player3 setCurrentTime:0.0];
            
            [player3 play];
            shotCountForSound=1;
            break;    
        default:
            break;
    }
    shotCountBullet--;
    _lbBullets.text=[NSString stringWithFormat:@"%d",shotCountBullet];
    
    
    shotCount++;  
    
    
    DLog(@"Shot %d", shotCount); 
    if ((shotCountBullet <= 0) && (shotCount < maxShotCount))
    {
        DLog(@"Shot foll!!! %d", shotTime); 
        follViewShow = YES;
        [activityIndicatorView setText:NSLocalizedString(@"FOLL", @"")];
        [activityIndicatorView showView];
// added timer of shot        
        nowInterval = [NSDate timeIntervalSinceReferenceDate];
        activityInterval = (nowInterval-startInterval)*1000;        
        
        shotTime = (int)activityInterval;
        DLog(@"Shot foll time!! %d", shotTime); 
// above        
        [self performSelector:@selector(follSend) withObject:self afterDelay:2.0];
        [player stop];
        [timer invalidate];
        follAccelCheck = YES;
    } 
}
}

- (IBAction)backButtonClick:(id)sender {

    if ([self.delegate isKindOfClass:[GameCenterViewController class]]) {
        [self.delegate performSelector:@selector(userCancelNutch)];
    }
}

-(IBAction)helpBtnClick:(id)sender;
{   
    HelpViewController *helpView=[[HelpViewController alloc] init];
    [self.navigationController pushViewController:helpView animated:YES];
}

#pragma mark Gun animation
-(void)shotStarAnimationVer
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES]; 
	[UIView setAnimationCurve:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction];
    [UIView setAnimationDuration:0.1f];
	[UIView setAnimationDelegate:self];
    CGAffineTransform gunTransform;
    CGAffineTransform transform = CGAffineTransformMakeRotation(0.05);
    gunTransform = CGAffineTransformTranslate(transform, 23, 0);
    _ivGun.transform = gunTransform;
    [UIView setAnimationDidStopSelector:@selector(shotStopAnimationVer)];
    [UIView commitAnimations];
}

-(void)shotStopAnimationVer
{
    CGAffineTransform gunTransform;
    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
    gunTransform = CGAffineTransformTranslate(transform, 0, 0);
    _ivGun.transform = gunTransform;
}

#pragma mark

-(void)startDuel{
    [helpPracticeView setHidden:YES];
    
    [titleReady setHidden:YES];
    [titleSteadyFire setHidden:NO];
}

-(void)restartCountdown;
{
    NSLog(@"restartCountdown");
    _infoButton.enabled=NO;
    
    follAccelCheck = NO;
    accelerometerState = NO;
    soundStart = NO;
    
    [timer invalidate];
    [player stop];
    [player setCurrentTime:0.0];
    [follPlayer setCurrentTime:0.0];
    [follPlayer play];
    
    [titleReady setHidden:NO];
    [titleSteadyFire setHidden:YES];
    
    [helpPracticeView setHidden:NO]; 
}

-(void)hideHelpViewWithArm;
{
    [helpPracticeView setHidden:YES];
}

-(void)countUpBulets;
{
    
    int countBullets = [DuelRewardLogicController countUpBuletsWithOponentLevel:opAccount.accountLevel defense:opAccount.accountDefenseValue playerAtack:playerAccount.accountWeapon.dDamage];
    
    shotCountBullet =  countBullets;
    maxShotCount = countBullets;
}

-(void)checkPlayerGun;
{
    if (playerAccount.accountWeapon.dName && [playerAccount.accountWeapon.dName length]) {
        NSString *path=[NSString stringWithFormat:@"%@/%@",[DuelProductDownloaderController getSavePathForDuelProduct],playerAccount.accountWeapon.dImageGunLocal];
        NSLog(@"path %@",path);
        
        if ([Utils isFileDownloadedForPath:path]) {
            _ivGun.image = [UIImage loadImageFullPath:path];
        }
        
        path=[NSString stringWithFormat:@"%@/%@",[DuelProductDownloaderController getSavePathForDuelProduct],playerAccount.accountWeapon.dSoundLocal];
        if ([Utils isFileDownloadedForPath:path]) {
            NSError *error;
            player1 = [[AVAudioPlayer alloc] initWithData:[SoundDownload dataForSound:path] error:&error];
            [player1 play];
            [player1 stop];
            
            player2 = [[AVAudioPlayer alloc] initWithData:[SoundDownload dataForSound:path] error:&error];
            [player2 play];
            [player2 stop];
            
            player3 = [[AVAudioPlayer alloc] initWithData:[SoundDownload dataForSound:path] error:&error];
            [player3 play];
            [player3 stop];
        }
        if (playerAccount.accountWeapon.dID == -1) {
            _ivGun.image = [UIImage imageNamed:@"dv_img_gun1.png"];
            NSError *error;
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/shot.mp3", [[NSBundle mainBundle] resourcePath]]];
            player1 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            [player1 play];
            [player1 stop];
            
            player2 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            [player2 play];
            [player2 stop];
            
            player3 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            [player3 play];
            [player3 stop];
        }
    }
}

#pragma mark - IBAction
- (void)cancelHelpArmClick:(id)sender {
    [self hideHelpViewWithArm ];
}

@end
