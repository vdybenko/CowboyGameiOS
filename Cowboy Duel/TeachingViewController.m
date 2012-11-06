//
//  TeachingViewController.m
//  Test
//
//  Created by Sobol on 25.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TeachingViewController.h"
#import "FinalViewController.h"
#import "HelpViewController.h"

static NSString *ShotSound = @"%@/shot.mp3";


@implementation TeachingViewController
@synthesize mutchNumber, mutchNumberWin, mutchNumberLose;

-(id)initWithTime:(int)randomTime andAccount:(AccountDataSource *)userAccount andOpAccount:(AccountDataSource *)oponentAccount
{
    self = [super initWithAccount:userAccount oponentAccount:oponentAccount];
    if (self) { 

        if([[NSUserDefaults standardUserDefaults] boolForKey:@"FirstRunForGun"] )
            firstRun = YES;
        else
            firstRun = NO;
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"FirstRunForGun"];
        
        time = randomTime + 5;
        
        mutchNumber = 0;
        mutchNumberLose = 0;
        mutchNumberWin = 0;
        
        
        LisForShot=YES;
        accelerometrDataSource = [[AccelerometrDataSource alloc] init];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    if ([helpViewSound isDescendantOfView:super.view]) {
        [helpPracticeView setHidden:YES];
    }else{
        [self cancelSoundClick:Nil];
    }
    
    if(firstRun){
        lbBackButton.text = NSLocalizedString(@"SKIP", nil);
    }
    
    opAccount.accountDefenseValue = 5;
    
    if([DuelProductAttensionViewController isAttensionNeedForOponent:opAccount]){
        DuelProductAttensionViewController *duelProductAttensionViewController=[[DuelProductAttensionViewController alloc] initWithAccount:playerAccount parentVC:self];
        [self.navigationController presentViewController:duelProductAttensionViewController animated:NO completion:nil];
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(3.0 / 60.0)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    if (![helpViewShots isDescendantOfView:super.view]) {
        [self cancelShotsClick:self];
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [accelerometrDataSource reloadFint];
    duelIsStarted = NO;
    fireSound = NO;
    acelStayt = YES;
    shotCount = 0;
    shotCountForSound=1;   
    
    deaccelTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(follSound) userInfo:nil repeats:NO];
//added for main menu sound disappear:    
    [[self.navigationController.viewControllers objectAtIndex:1] playerStop];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}
#pragma mark -
-(void)increaseMutchNumberLose
{
    mutchNumberLose++;   
}
-(void)increaseMutchNumber
{
    mutchNumber++;
    DLog(@"Match number %d", mutchNumber);
}
-(void)increaseMutchNumberWin
{
    mutchNumberWin++;
}

-(int)fMutchNumberLose
{
    return mutchNumberLose;   
}
-(int)fMutchNumber
{
    return mutchNumber;
}
-(int)fMutchNumberWin
{
    return mutchNumberWin;
}

-(void)follSound
{
    DLog(@"foll sound");
    if (!soundStart) {
        [follPlayer play];
    }
}

-(void)shotTimer
{
    nowInterval = [NSDate timeIntervalSinceReferenceDate];
    activityInterval = (nowInterval - startInterval) * 1000;
    
    shotTime = (int)activityInterval;
    
    if ((shotTime*0.001 >= time)&&(!duelIsStarted)) {
        DLog(@"Timer");
        duelIsStarted = YES;
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fire.mp3", [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        [player stop];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [player play];
        [self vibrationStart];
    }    
}


-(IBAction)buttonClick
{
    [super buttonClick]; 
    
    if (duelIsStarted){    
        [self hideHelpViewWithArm];
        
        if (shotCount == maxShotCount) 
        {
            DLog(@"Kill!!!");
            DLog(@"Shot Time = %d.%d", (shotTime - time * 1000) / 1000, (shotTime - time * 1000));
            
                            
            [follPlayer stop];
            int opponentTime;
            opponentTime=3000;
        
            FinalViewController *finalViewController = [[FinalViewController alloc] initWithUserTime:(shotTime - time * 1000) andOponentTime:opponentTime andGameCenterController:self andTeaching:YES andAccount: playerAccount andOpAccount:opAccount];
            //                [activityIndicatorView setText:NSLocalizedString(@"FOLL", @"")];
            [activityIndicatorView setText:@""];
            [activityIndicatorView showView];
            [self.navigationController pushViewController:finalViewController animated:YES];
            //                [button setEnabled:NO];
            [timer invalidate];
        } 
    }else{
        if (soundStart) {
            DLog(@"Foll!!!");
        } 
        shotCount--;
    }
}

- (IBAction)backButtonClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"FirstRunForPractice"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    [super accelerometer:accelerometer didAccelerate:acceleration];

    if (duelIsStarted && acelStayt) {
        fintType = [accelerometrDataSource setPositionWithX:acceleration.x andY:acceleration.y andZ:acceleration.z];
        switch (fintType) {
            case FirstFint:
                
                DLog(@"first fint");
                
                maxShotCount = 1;
                
                break;
            case SecondFint:
                DLog(@"second fint");
                break;    
            default:
                break;
        }
        
    }
    
    if ((accelerometerState)&&(!soundStart)) {
        _infoButton.enabled=NO;
        [self startDuel];
    }
    
    if ((!accelerometerState) && (soundStart) && (!duelIsStarted)) {
        if(!follAccelCheck){
            [self restartCountdown];
        }
    }
}

-(void)follSend
{
    FinalViewController *finalViewController = [[FinalViewController alloc] initWithUserTime:999999.0 andOponentTime:0 andGameCenterController:self andTeaching:YES andAccount: playerAccount andOpAccount:opAccount];
    
    [self.navigationController pushViewController:finalViewController animated:YES];
}

-(void)startDuel
{
    [super startDuel];
    NSLog(@"startDuel");
    soundStart = YES;    
    startInterval = [NSDate timeIntervalSinceReferenceDate];
    [player stop];
    [player setCurrentTime:0.0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Duel.mp3", [[NSBundle mainBundle] resourcePath]]];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player play];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.111 target:self selector:@selector(shotTimer) userInfo:nil repeats:YES];
    duelIsStarted = NO;
    fireSound = NO;
    acelStayt = YES;
    shotTime = 0;
    
    if (([[NSUserDefaults standardUserDefaults] integerForKey:@"FirstRunForPractice"] != 1)&&([[NSUserDefaults standardUserDefaults] integerForKey:@"FirstRunForPractice"] != 2))
    {
        [self hideHelpViewWithArm];
    }
}

#pragma mark - IBAction

- (IBAction)cancelShotsClick:(id)sender {
    [super cancelShotsClick:sender];
    
    [UIView animateWithDuration:ANIMATION_TIME
                     animations:^{
                         [helpPracticeView setHidden:NO];
                         CGRect frame=helpPracticeView.frame;
                         if ([helpViewSound isDescendantOfView:self.view]) {
                             frame.origin.y=210;
                         }else {
                             frame.origin.y=72;
                         }
                         helpPracticeView.frame = frame;
                     }];
}

- (IBAction)cancelSoundClick:(id)sender {
    [super cancelSoundClick:sender];
    
    [UIView animateWithDuration:ANIMATION_TIME
                     animations:^{
                         [helpPracticeView setHidden:NO];
                         CGRect frame=helpPracticeView.frame;
                         if ([helpViewShots isDescendantOfView:self.view]) {
                             frame.origin.y=320;                             
                         }else {
                             frame.origin.y=72;
                         }
                         helpPracticeView.frame=frame;
                     }];
}


@end
