//
//  TestViewController.m
//  Test
//
//  Created by Sobol on 11.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DuelViewController.h"
#import "StartViewController.h"

#define FOLL_TIME 999999

static NSString *ShotSound = @"%@/shot.mp3";


@implementation DuelViewController

@synthesize delegate, time, notFirstStart, startDuelTime;

-(id)initWithTime:(int)randomTime Account:(AccountDataSource *)userAccount oponentAccount:(AccountDataSource *)pOponentAccount;
{
    self = [super initWithAccount:userAccount oponentAccount:pOponentAccount];
    if (self) {
        time = randomTime + 5.0;
        startDuelTime = [NSDate timeIntervalSinceReferenceDate];
        BOOL notFirstStartBOOL = [[NSUserDefaults standardUserDefaults] boolForKey:@"DUEL_VIEW_NOT_FIRST"];
        if (notFirstStartBOOL) {
            notFirstStart = YES;
        }else{
            notFirstStart = NO;
        }

    }
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];    
}

-(void)viewDidLoad
{    
    [super viewDidLoad];
  /*if (notFirstStart) {
        [helpViewShots removeFromSuperview];
        [helpViewSound removeFromSuperview];
    }else{
        if (![helpViewShots isDescendantOfView:self.view]) {
            CGRect frame=helpViewSound.frame;
            frame.origin.y=72;
            helpViewSound.frame=frame;
        }
    }
    */
    [self hideHelpViewWithArm];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(3.0 / 60.0)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    [super viewWillAppear:animated];
    [super._infoButton setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

#pragma mark -
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    [super accelerometer:accelerometer didAccelerate:acceleration];
    
//    if (duelIsStarted && acelStayt) {
//        fintType = [accelerometrDataSource setPositionWithX:acceleration.x andY:acceleration.y andZ:acceleration.z];
//        switch (fintType) {
//            case FirstFint:
//                DLog(@"first fint");
//                maxShotCount = 1;
//                [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
//                                                                    object:self
//                                                                  userInfo:[NSDictionary dictionaryWithObject:@"/Trick" forKey:@"event"]];
//                break;
//            case SecondFint:
//                DLog(@"second fint");
//                break;    
//            default:
//                break;
//        }
//        
//    }

    
    if((accelerometerState)&& (!soundStart)){
        if ((!accelerometerStateSend) ) {
            if ([delegate respondsToSelector:@selector(setAccelStateTrue)]) 
                [delegate setAccelStateTrue];
            accelerometerStateSend = YES;
        }else {
            [self startDuel];
        }
    }
    else {
        if ([delegate respondsToSelector:@selector(setAccelStateFalse)]) 
            [delegate setAccelStateFalse];
        accelerometerStateSend = NO;
    }
    
    if ((!accelerometerState) && (soundStart) && (!duelIsStarted)) {
        if(!follAccelCheck){
            [self restartCountdown];
        }
    }
}

-(void)setTime:(int)randomTime{
    time = randomTime;
    label.text = [NSString stringWithFormat:@"%d",time];
}

-(void)shotTimer
{
    nowInterval = [NSDate timeIntervalSinceReferenceDate];
    activityInterval = (nowInterval-startInterval)*1000;
    shotTime = (int)activityInterval;
    
    UIViewController *curentVC=[self.navigationController visibleViewController];
    if ((shotTime * 0.001 >= time) && (!duelIsStarted) && (!foll)&&([curentVC isEqual:self])) {
        DLog(@"FIRE !!!!!");
        duelIsStarted = YES;
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fire.mp3", [[NSBundle mainBundle] resourcePath]]];
        NSError *error;
        [player stop];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [player play];
        [self vibrationStart];
    }
    if ((shotTime * 0.001 >= 30.0) && (!duelTimerEnd) && (soundStart)) {
        if ([delegate respondsToSelector:@selector(duelTimerEnd)]) 
            [delegate duelTimerEnd];
        duelTimerEnd = YES;
        [timer invalidate];
    }
}

-(void)duelTimerEndFeedBack
{
    duelTimerEnd = YES;
}

-(void)follSend
{
    DLog(@"Foll send");
    if ([delegate respondsToSelector:@selector(sendShotTime:)]) 
        [delegate sendShotTime:-shotTime];
    
}

-(IBAction)buttonClick
{   
    [super buttonClick];
    DLog(@"shotCountBullet %d shotCount %d maxShotCount %d",shotCountBullet,shotCount,maxShotCount);
    if (duelIsStarted) 
    {
        if ((shotCount == maxShotCount) && (duelIsStarted)) 
        {
            DLog(@"Kill!!!");
            
            [follPlayer stop];
       
            DLog(@"Shot Time = %d.%d", (shotTime - time * 1000) / 1000, (shotTime - time * 1000) % 1000);
//            if (shotTime == 0) {
//                shotTime = [NSDate timeIntervalSinceReferenceDate] - startDuelTime;
//                if ([delegate respondsToSelector:@selector(sendShotTime:)]) 
//                    [delegate sendShotTime:(-shotTime)];
//
//            } else {
                if ([delegate respondsToSelector:@selector(sendShotTime:)]) 
                    [delegate sendShotTime:(shotTime - time * 1000)];
//            }
            [activityIndicatorView showView];
            super._btnNab.enabled = NO;
            acelStayt = NO;
            [timer invalidate];
        } 
    }
    else
    {
        if (soundStart) {
            foll = YES;
            [self performSelector:@selector(follSend) withObject:self afterDelay:2.0];

            [activityIndicatorView setText:NSLocalizedString(@"FOLL", @"")];
            [activityIndicatorView showView];
            [player stop];
            [timer invalidate];
            soundStart = NO;
            
            DLog(@"Foll!!!");
        }
        shotCount--;
    }

}

#pragma mark DuelViewControllerDelegate Methods
-(BOOL)accelerometerSendPositionSecond
{
    return accelerometerState;
}

-(void)startDuel
{   
    if (!follViewShow) {
         DLog(@"Duel started");
        [super startDuel];
        soundStart = YES;
        foll = NO;
        [player stop];
        [player setCurrentTime:0.0];
        startInterval = [NSDate timeIntervalSinceReferenceDate];
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Duel.mp3", [[NSBundle mainBundle] resourcePath]]];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [player prepareToPlay];
        [player play];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(shotTimer) userInfo:nil repeats:YES];
        duelIsStarted = NO;
        acelStayt = YES;
        shotTime = 0;
    }
}   

-(void)restartCountdown
{
    [super showHelpViewWithArm];
    
    foll = YES;
    [super restartCountdown];
    NSLog(@"%@",self.view.subviews);
}
-(IBAction)backButtonClick:(id)sender;
{
    [super backButtonClick:sender];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAnalyticsTrackEventNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:@"/Duel_back" forKey:@"event"]];
    
}

-(void)shutDownTimer;
{
    [timer invalidate];
}
@end
