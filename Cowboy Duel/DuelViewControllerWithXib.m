//
//  TestViewController.m
//  Test
//
//  Created by Sobol on 11.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DuelViewControllerWithXib.h"
#import "StartViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DuelRewardLogicController.h"
#import "GameCenterViewController.h"

@interface DuelViewControllerWithXib (PrivateMethods)

-(void)verticalMode;
-(void)shotStarAnimationVer;

@end

static NSString *ShotSound = @"%@/shot.mp3";

@implementation DuelViewControllerWithXib
@synthesize _vEarth, _infoButton, _ivGun, _btnNab, _lbBullets, _vBackground, delegate,titleSteadyFire;

-(id)initWithAccount:(AccountDataSource *)userAccount oponentAccount:(AccountDataSource *)oponentAccount;
{
    self = [self initWithNib];
    if (self) { 
        playerAccount = userAccount;
        opAccount = oponentAccount;
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
    imgFrame.origin = CGPointMake(-80,0);
    activityIndicatorView.frame=imgFrame;
    [self.view addSubview:activityIndicatorView];

    lbBackButton.text = NSLocalizedString(@"BACK", nil);
    lbBackButton.textColor = btnColor;
    lbBackButton.font = [UIFont fontWithName: @"DecreeNarrow" size:24];  
    
    UIFont *fontShot=[UIFont fontWithName: @"MyriadPro-Semibold" size:18];
    UIFont *fontSound=[UIFont fontWithName: @"MyriadPro-Semibold" size:15];

//    Shots
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"disableShotsHelp"]) {
        [helpViewShots removeFromSuperview];
    }else {
        [viewDinamicHeight setDinamicHeightBackground];
        [lbWait setFont:fontShot];
        [lbCountOfShots setFont:fontShot];
        lbWait.text=NSLocalizedString(@"WAIT", @"");
        
        lbDisabledShots.text = NSLocalizedString(@"ENABLED_HELP", @"");
    }
    
//     Sound    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"disableSoundHelp"]) {
        [helpViewSound removeFromSuperview];
    }else {
        
        MPMusicPlayerController *iPod = [MPMusicPlayerController applicationMusicPlayer];
        float volumeLevel = iPod.volume;
        
        BOOL showHelpMessage=NO;
        if ([Utils isDeviceMuted]) {
            showHelpMessage = YES;
        }else {
            if (volumeLevel < 0.2){
                showHelpMessage = YES;
            }
        }
        if (showHelpMessage) {
            [helpViewSound setDinamicHeightBackground];
            [lbWarningSound setFont:fontSound];
            lbWarningSound.text=NSLocalizedString(@"SOUND_WARNING", @"");
            lbDisabledSound.text = NSLocalizedString(@"ENABLED_HELP", @"");
            
            [iPod setShuffleMode:MPMusicShuffleModeOff];
            [iPod setRepeatMode:MPMusicRepeatModeNone];
            
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(handle_itemChanged:) 
                                                         name:MPMusicPlayerControllerVolumeDidChangeNotification 
                                                       object:nil];
            [iPod beginGeneratingPlaybackNotifications];
        }else {
            [helpViewSound removeFromSuperview];
        }
    }
    
    helpPracticeView=[[UIView alloc] initWithFrame:CGRectMake(12, 480, 290, 320)];
    
    UIImageView *imvArm=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dv_arm.png"]];
    CGRect frame = imvArm.frame;
    frame.origin = CGPointMake(24, 11);
    frame.size= CGSizeMake(242, 298);
    imvArm.frame = frame;
    [helpPracticeView addSubview:imvArm];
    
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
    
    [self countUpBuletsWithLevel:playerAccount.accountLevel oponentLevel:opAccount.accountLevel];
    _lbBullets.text=[NSString stringWithFormat:@"%d", shotCountBullet];
    
    [self setTextToMessageShot];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    accelerometerStateSend = NO;
    shotCount = 0;
    shotCountForSound=1;
    soundStart = NO; 
    foll = NO;
    follAccelCheck = NO;
    duelTimerEnd = NO;
    follViewShow = NO;
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
#pragma mark 

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
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:ShotSound, [[NSBundle mainBundle] resourcePath]]];
    switch (shotCountForSound) {
        case 1:
            [titleSteadyFire setHidden:YES];
            
            [player1 stop];
            [player1 setCurrentTime:0.0];
            
            player1 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
            [player1 play];
            shotCountForSound=2;
            break;    
        case 2:
            [player2 stop];
            [player2 setCurrentTime:0.0];
            //                url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Shot.aif", [[NSBundle mainBundle] resourcePath]]];
            player2 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
            [player2 play];
            shotCountForSound=3;
            break;   
        case 3:
            [player3 stop];
            [player3 setCurrentTime:0.0];
            //                url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Shot.aif", [[NSBundle mainBundle] resourcePath]]];
            player3 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
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



-(void)startDuel{
    [helpViewShots removeFromSuperview];
    [helpViewSound removeFromSuperview];
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

-(void)countUpBuletsWithLevel:(int)playerLevel oponentLevel:(int)oponentLevel;
{
    int countBullets = [DuelRewardLogicController countUpBuletsWithPlayerLevel:oponentLevel];
    
    shotCountBullet =  countBullets;
    maxShotCount = countBullets;
}

-(void)setTextToMessageShot;
{
    lbWaitDescription.text = NSLocalizedString(@"SHOTS_DES", @"");
    lbCountOfShots.text=[NSString stringWithFormat:@"%@ %d %@",NSLocalizedString(@"SHOTS1", @""),shotCountBullet,NSLocalizedString(@"SHOTS2", @"")];
}

#pragma mark - IBAction
- (IBAction)checkSoundClick:(id)sender {
    UIButton *soundChecker=(UIButton *)sender;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"disableSoundHelp"]) {
        [soundChecker setImage:[UIImage imageNamed:@"cheker_uncheck.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"disableSoundHelp"];

    }else {
        [soundChecker setImage:[UIImage imageNamed:@"cheker_check.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"disableSoundHelp"];
    }
}
- (IBAction)cancelSoundClick:(id)sender {
    [helpViewSound removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:nil];
}
- (IBAction)checkShotsClick:(id)sender {
    UIButton *shotsChecker=(UIButton *)sender;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"disableShotsHelp"]) {
        [shotsChecker setImage:[UIImage imageNamed:@"cheker_uncheck.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"disableShotsHelp"];
        
    }else {
        [shotsChecker setImage:[UIImage imageNamed:@"cheker_check.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"disableShotsHelp"];
    }
}

- (IBAction)cancelShotsClick:(id)sender {
    [helpViewShots removeFromSuperview];   
    
    [UIView animateWithDuration:ANIMATION_TIME
                     animations:^{
                         CGRect frame=helpViewSound.frame;
                         frame.origin.y=72;
                         helpViewSound.frame=frame;
                         
                     }];

}

#pragma mark MPMusicPlayerController delegate
-(void)handle_itemChanged:(id)sender{
    MPMusicPlayerController *iPod = [MPMusicPlayerController applicationMusicPlayer];
    float volumeLevel = iPod.volume;
    if (volumeLevel > 0.2) {
        [helpViewSound removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:nil];
    }
}

@end
